import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';
import 'package:date/models/chat.dart'; // Import your Chat model or relevant model
import '../../controller/message_controller.dart';
import 'chat_page.dart'; // Import the ChatPage

class NewChatPage extends StatelessWidget {
  final ChatController _chatController = ChatController();

  NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chat'),
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
      body: FutureBuilder<List<Map<String, dynamic>?>>(
        future: _chatController
            .getUsersWithoutChat(FirebaseAuth.instance.currentUser!.uid),
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
                  const Text(
                    'You have no chats Maches',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            );
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 1,
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .04,
                  vertical: 4),
              child: Slidable(
                startActionPane:
                    ActionPane(motion: const StretchMotion(), children: [
                  SlidableAction(
                    onPressed: (context) => _onDismissed(),
                    icon: Icons.share,
                    backgroundColor: Colors.green,
                    label: 'Share',
                  )
                ]),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(users[index]!['imageProfile']),
                  ),
                  title: Text(users[index]!['name']),
                  onTap: () async {
                    // Generate a unique chat ID using the member IDs and UUID
                    // Extract the user ID from the map
                    String selectedUserId = users[index]!['id'];

                    // Generate a unique chat ID using the member IDs and UUID
                    String newChatId =
                        '${FirebaseAuth.instance.currentUser!.uid}_$selectedUserId${Uuid().v4()}';

                    // Create a new chat using the provided details
                    Chat newChat = Chat(
                        id: newChatId,
                        memberIds: [
                          FirebaseAuth.instance.currentUser!.uid,
                          users[index]!['id']
                        ],
                        messages: [],
                        seen: false);

                    // Create the new chat in Firestore
                    await _chatController.createChat(newChat);

                    // Navigate to the ChatPage with the newly created Chat object
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chat: newChat,
                          currentUserId: FirebaseAuth.instance.currentUser!.uid,
                          uid: users[index]!['id'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onDismissed() {}
}
