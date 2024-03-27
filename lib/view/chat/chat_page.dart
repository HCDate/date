import 'dart:io';
import 'dart:ui';

import 'package:bilions_ui/bilions_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import '../../controller/audio_controller.dart';
import '../../controller/message_controller.dart';
import '../../controller/profile_controller.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:audioplayers/audioplayers.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final String currentUserId;
  final String uid;
  const ChatPage(
      {super.key,
      required this.chat,
      required this.currentUserId,
      required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ChatController _chatController = ChatController();
  bool _showEmojiPicker = false, _isUploading = false;
  String imageProfile = '';
  String name = '';
  String token = '';
  bool status = false;

  bool isCurrentlyPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  ScrollController _scrollController = new ScrollController();
  AudioController audioController = Get.put(AudioController());
  final FocusNode focusNode = FocusNode();
  String audioURL = "";
  final ProfileController _profileController = ProfileController();
  int _limit = 100;
  int _limitIncrement = 20;
  List<QueryDocumentSnapshot> listMessage = [];
  // void _initialize() async {
  //   try {
  //     await _audioRecorder.openAudioSession();
  //   } catch (e) {
  //     print('Error initializing recorder: $e');
  //   }
  // }

  void _scrollToBottom() {
    // if (_scrollController.hasClients) {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void setStatus(bool status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .update({"online": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus(true);
    } else {
      setStatus(false);
    }
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();
      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }

  void stopRecord() async {
    bool stop = RecordMp3.instance.stop();
    audioController.end.value = DateTime.now();
    audioController.calcDuration();
    var ap = AudioPlayer();
    await ap.play(AssetSource("Notification.mp3"));
    ap.onPlayerComplete.listen((a) {});
    if (stop) {
      audioController.isRecording.value = false;
      audioController.isSending.value = true;
      await uploadAudio();
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }

  uploadAudio() async {
    final recordFile = File(recordFilePath);

    // Check audio file size before upload
    if (recordFile.lengthSync() > 5 * 1024 * 1024) {
      // Check for 5MB size limit (adjust as needed)
      // Display a message indicating the file is too large
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Audio file exceeds 5MB limit.")),
      );
      return; // Exit the function if file size is too large
    }

    // Continue with upload process as usual
    UploadTask uploadTask = _chatController.uploadAudio(recordFile,
        "audio/${DateTime.now().millisecondsSinceEpoch.toString()}");
    // ... existing upload and error handling code ...
  }

  late String recordFilePath;

  retrieveUserInfo() async {
    print('user widget:$widget.uid');
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          imageProfile = snapshot.data()!["imageProfile"];
          name = snapshot.data()!["name"];
          token = snapshot.data()!['userDeviceToken'];
          status = snapshot.data()!['online'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserInfo();

    _chatController.updateSeenStatusOnChatEnter(widget.chat.id);
    WidgetsBinding.instance!.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the ScrollController after the frame is drawn
      _scrollController = ScrollController();
      _scrollController.addListener(_scrollListener);
    });
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn);
      }
    });
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
            child: WillPopScope(
                onWillPop: () {
                  if (_showEmojiPicker) {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                    return Future.value(false);
                  } else {
                    return Future.value(true);
                  }
                },
                child: Scaffold(
                  appBar: AppBar(
                    actions: [
                      PopupMenuButton(
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            onTap: () async {
                              confirm(
                                context,
                                ConfirmDialog(
                                  'Are you sure to block?',
                                  message: 'It going to block?',
                                  variant: Variant.warning,
                                  confirmed: () async {
                                    // do something here
                                    await _profileController
                                        .retrieveUserInfo(widget.uid);
                                    alert(
                                      context,
                                      'Block User',
                                      'It blocked succeeded',
                                      variant: Variant.warning,
                                    );
                                  },
                                ),
                              );
                            },
                            value: 'Option 1',
                            child: const Text('Block'),
                          ),
                        ],
                      ),
                    ],
                    automaticallyImplyLeading: false,
                    flexibleSpace: _appBar(),
                    leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(child: _buildMessageList()),
                      if (_isUploading)
                        const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                      _buildMessageInput(),
                      if (_showEmojiPicker)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .35,
                          child: EmojiPicker(
                            textEditingController: _messageController,
                            config: Config(),
                          ),
                        )
                    ],
                  ),
                ))));
  }

  Widget _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black54,
            )),
        const SizedBox(
          width: 10,
        ),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(MediaQuery.of(context).size.height * .3),
          child: CachedNetworkImage(
            width: MediaQuery.of(context).size.height * .05,
            height: MediaQuery.of(context).size.height * .05,
            imageUrl: imageProfile,
            errorWidget: (context, url, error) => const CircleAvatar(
              child: Icon(CupertinoIcons.person),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
            status == true
                ? Text(
                    'Online',
                    style: TextStyle(color: Colors.blueAccent),
                  )
                : Text(
                    'Offline',
                    style: TextStyle(color: Colors.black),
                  )
          ],
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Message>>(
      stream: _chatController.getMessages(widget.chat.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Messages Yet'));
        }
        // listMessage = snapshot.data.length;

        final messages = snapshot.data!;

        // Debug: Print messages to see if data is coming from the stream
        print('Received Messages: ${messages.length}');
        for (var message in messages) {
          print('Message Content: ${message.senderId}');
        }

        return ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var alignment = (messages[index].senderId == widget.currentUserId)
                  ? Alignment.centerRight
                  : Alignment.centerLeft;
              return InkWell(
                onTap: () {
                  _showButtomSheet(messages[index].type,
                      messages[index].content, messages[index].id);
                },
                child: Container(
                    alignment: alignment,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                          crossAxisAlignment: (messages[index].senderId ==
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisAlignment: (messages[index].senderId ==
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            index == 0
                                ? Center(
                                    child: Text(DateFormat('MMMM dd').format(
                                        messages[index].timestamp.toDate())),
                                  )
                                : DateFormat('MMMM dd').format(
                                            messages[index - 1]
                                                .timestamp
                                                .toDate()) ==
                                        DateFormat('MMMM dd').format(
                                            messages[index].timestamp.toDate())
                                    ? const Text('')
                                    : Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(DateFormat('MMMM dd')
                                              .format(messages[index]
                                                  .timestamp
                                                  .toDate())),
                                        ),
                                      ),
                            messages[index].type == 'text'
                                ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color: (messages[index].senderId ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            ? Colors.grey
                                            : Colors.pinkAccent),
                                    child: Text(
                                      messages[index].content,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  )
                                : messages[index].type == 'voice'
                                    ? _audio(
                                        message: messages[index].content,
                                        isCurrentUser:
                                            messages[index].senderId ==
                                                    widget.currentUserId
                                                ? true
                                                : false,
                                        index: index,
                                        time: messages[index]
                                            .timestamp
                                            .toString(),
                                        duration:
                                            messages[index].duration.toString())
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          width: 250,
                                          imageUrl: messages[index].content,
                                          placeholder: (context, url) =>
                                              const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.image, size: 70),
                                        ),
                                      ),
                            Text(DateFormat('hh:mm a')
                                .format(messages[index].timestamp.toDate())),
                            messages[index].seen
                                ? const Icon(
                                    Icons.done_all_rounded,
                                    color: Colors.blue,
                                    size: 20,
                                  )
                                : const Icon(
                                    Icons.done,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                          ]),
                    )),
              );
            }
            // ListTile(
            //   title: Text(messages[index].content),
            // ),

            );
      },
    );
  }

  void _showButtomSheet(String type, String content, String id) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .015,
                    horizontal: MediaQuery.of(context).size.height * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              type == "text"
                  ? OptionsItem(
                      icon: const Icon(
                        Icons.copy_all_outlined,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: content))
                            .then((value) {
                          Navigator.pop(context);
                          Get.snackbar("Text", "Text copied");
                        });
                      })
                  : OptionsItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                      ),
                      name: "Save Image",
                      onTap: () async {
                        try {
                          http.Response response =
                              await http.get(Uri.parse(imageProfile));
                          Uint8List bytes = response.bodyBytes;

                          // await ImageGallerySaver.saveImage(bytes);

                          // Show a success message
                          Get.snackbar("Image Download",
                              "Image downloaded successfully");
                        } catch (error) {
                          // Show an error message
                          Get.snackbar(
                              "Image Download", "Image failed downloaded ");
                        }
                      },
                    ),
              const Divider(),
              OptionsItem(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: "Delete Message",
                  onTap: () async {
                    await _chatController
                        .deleteMessage(
                            widget.chat.id, id, type == 'text' ? "" : content)
                        .then((value) {
                      Navigator.pop(context);
                    });
                  })
            ],
          );
        });
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: const Icon(Icons.mic, color: Colors.pink),
              onLongPress: () async {
                var audioPlayer = AudioPlayer();
                await audioPlayer.play(AssetSource("Notification.mp3"));
                audioPlayer.onPlayerComplete.listen((a) {
                  audioController.start.value = DateTime.now();
                  startRecord();
                  audioController.isRecording.value = true;
                });
              },
              onLongPressEnd: (details) {
                stopRecord();
              },
            ),
            const SizedBox(
              width: 3,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.emoji_emotions),
                    onPressed: () {
                      setState(() {
                        _showEmojiPicker =
                            !_showEmojiPicker; // Toggle emoji picker visibility
                      });
                    },
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () async {
                  await _chatController.pickImageFileFromGallery();
                  // setState(() {
                  //   _isUploading = true;
                  // });
                  await _chatController.sendMessageWithImage(widget.chat.id,
                      FirebaseAuth.instance.currentUser!.uid, token);
                  // setState(() {
                  //   _isUploading = false;
                  // });
                },
                icon: const Icon(Icons.image, color: Colors.blueAccent)),
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _chatController.sendMessage(
                      widget.chat.id,
                      FirebaseAuth.instance.currentUser!.uid,
                      _messageController.text,
                      token);
                  _messageController.clear();
                  setState(() {
                    _showEmojiPicker = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              child: const Text(
                'Send',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _audio({
    required String message,
    required bool isCurrentUser,
    required int index,
    required String time,
    required String duration,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.pink : Colors.pink.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              audioController.onPressedPlayButton(index, message);
              // changeProg(duration: duration);
            },
            onSecondaryTap: () {
              audioPlayer.stop();
              //   audioController.completedPercentage.value = 0.0;
            },
            child: Obx(
              () => (audioController.isRecordPlaying &&
                      audioController.currentId == index)
                  ? Icon(
                      Icons.cancel,
                      color: isCurrentUser ? Colors.white : Colors.pink,
                    )
                  : Icon(
                      Icons.play_arrow,
                      color: isCurrentUser ? Colors.white : Colors.pink,
                    ),
            ),
          ),
          Obx(
            () => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Text(audioController.completedPercentage.value.toString(),style: TextStyle(color: Colors.white),),
                    LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrentUser ? Colors.white : Colors.pink,
                      ),
                      value: (audioController.isRecordPlaying &&
                              audioController.currentId == index)
                          ? audioController.completedPercentage.value
                          : audioController.totalDuration.value.toDouble(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // Text(
          //   duration,
          //   style: TextStyle(
          //       fontSize: 12, color: isCurrentUser ? Colors.white : mainColor),
          // ),
        ],
      ),
    );
  }
}

class OptionsItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionsItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .05,
            top: MediaQuery.of(context).size.width * .015,
            bottom: MediaQuery.of(context).size.height * .025),
        child: Row(
          children: [icon, Flexible(child: Text("  $name"))],
        ),
      ),
    );
  }
}
