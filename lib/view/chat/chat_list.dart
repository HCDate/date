import 'package:date/models/chat.dart';
import 'package:date/models/message.dart';
import 'package:date/view/chat/chat_page.dart';
import 'package:date/view/chat/new_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart';

import '../../controller/message_controller.dart';

class ChatListPage extends StatefulWidget {
  ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatController _chatController = ChatController();
  late String currentUserId;
  TextEditingController searchController = TextEditingController();
  List<Chat> filteredChats = [];
  List<Chat> allChats = [];
  List blocklist = [];
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    retrieveUserInfo();
  }

  retrieveUserInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          blocklist = List<String>.from(snapshot.get('blockList') ?? []);
          print(blocklist);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.pink),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 40,
            child: TextField(
              controller: searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: 'Search Chats',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: _chatController
                  .getChats(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.pink,
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Display a user-friendly message when the chat list is empty

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('You have no chats yet.'),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(NewChatPage());
                          },
                          child: const Text('Start a New Chat'),
                        ),
                      ],
                    ),
                  );
                } else {
                  allChats = snapshot.data!;
                  final chats =
                      filteredChats.isNotEmpty ? filteredChats : allChats;
                  return chats.isEmpty
                      ? const Center(
                          child: Text('User not found'),
                        )
                      : ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            // Get the ID of the other member in the chat
                            Chat chat = chats[index];
                            Message lastMessage = chat.messages.isNotEmpty
                                ? chat.messages.last
                                : Message(
                                    id: '',
                                    content: '',
                                    seen: false,
                                    type: '',
                                    senderId: '',
                                    timestamp: Timestamp.now(),
                                    duration: '');
                            String otherMemberId = chats[index]
                                .memberIds
                                .firstWhere((id) => id != currentUserId);

                            // Retrieve the user information from Firestore
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(otherMemberId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(child: Text(''));
                                } else if (!userSnapshot.hasData) {
                                  return const ListTile(
                                    title: Text('Loading...'),
                                  );
                                } else {
                                  // Get the user data from the DocumentSnapshot
                                  Map<String, dynamic> userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  String userName = userData['name'];
                                  String userImage = userData['imageProfile'];
                                  if (blocklist.contains(otherMemberId)) {
                                    // If the other member is in the blocklist, return an empty SizedBox
                                    return SizedBox();
                                  } else {
                                    bool hasContent =
                                        lastMessage.content.isNotEmpty;
                                    bool check = lastMessage.type == 'text' &&
                                        lastMessage.content.isNotEmpty;
                                    String textToDisplay =
                                        lastMessage.type == 'text' &&
                                                lastMessage.content.isNotEmpty
                                            ? lastMessage.content
                                            : '';
                                    if (check &&
                                        lastMessage.content.length > 10) {
                                      textToDisplay =
                                          '${lastMessage.content.substring(0, 10)}...';
                                    }

                                    return hasContent
                                        ? Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            elevation: 1,
                                            margin: EdgeInsets.symmetric(
                                                horizontal:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        .04,
                                                vertical: 4),
                                            child: Slidable(
                                              startActionPane: ActionPane(
                                                  motion: const StretchMotion(),
                                                  children: [
                                                    SlidableAction(
                                                      onPressed: (context) =>
                                                          _onDismissed(chat.id),
                                                      icon: Icons.delete,
                                                      backgroundColor:
                                                          Colors.red,
                                                      label: 'Delete',
                                                    )
                                                  ]),
                                              child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(userImage),
                                                  ),
                                                  title: Text(userName),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      lastMessage.type == 'text'
                                                          ? Text(textToDisplay)
                                                          : lastMessage.type ==
                                                                  "voice"
                                                              ? lastMessage
                                                                          .senderId ==
                                                                      currentUserId
                                                                  ? const Text(
                                                                      'you sent a voice')
                                                                  : const Text(
                                                                      'you have a voice')
                                                              : lastMessage
                                                                          .senderId ==
                                                                      currentUserId
                                                                  ? const Text(
                                                                      'you sent a picture')
                                                                  : const Text(
                                                                      'you have a picture'),
                                                    ],
                                                  ),
                                                  trailing: Column(
                                                    children: [
                                                      Text(
                                                          formatMessageTimestamp(
                                                              lastMessage
                                                                  .timestamp
                                                                  .toDate())),
                                                      chat.seen
                                                          ? const Icon(
                                                              Icons.done_all,
                                                              color: Colors
                                                                  .pink) // Seen icon
                                                          : lastMessage
                                                                      .senderId !=
                                                                  currentUserId
                                                              ? Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .pink,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                10),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.pink)),
                                                                    child:
                                                                        const Text(
                                                                      'new',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const Icon(
                                                                  Icons.done,
                                                                  color: Colors
                                                                      .grey),
                                                    ],
                                                  ), // Unseen icon
                                                  // Add more details or customize the ListTile as needed

                                                  onTap: () => Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatPage(
                                                            chat: chats[index],
                                                            currentUserId:
                                                                currentUserId,
                                                            uid: otherMemberId,
                                                          ),
                                                        ),
                                                      )),
                                            ),
                                          )
                                        : SizedBox();
                                  }
                                }
                              },
                            );
                          },
                        );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(NewChatPage());
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  void _onDismissed(String chatId) async {
    await _chatController.deleteChat(chatId);
  }

  void _filterChats(String query) async {
    List<Chat> filtered = await _chatController.filterChatsByQuery(
      currentUserId,
      query,
      allChats,
    );

    setState(() {
      filteredChats = filtered;
    });
  }

  String formatMessageTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        // Less than one hour, show minutes
        return '${difference.inMinutes}m ago';
      } else {
        // Less than one day, show hours
        return '${difference.inHours}h ago';
      }
    } else {
      // More than one day, show date
      return DateFormat('MMMM dd').format(timestamp);
    }
  }
}
