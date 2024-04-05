import 'package:bilions_ui/bilions_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BlockList extends StatefulWidget {
  const BlockList({super.key});

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  List<String> blockList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveBlockList();
  }

  Future<void> retrieveBlockList() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      blockList = List<String>.from(snapshot.get('blockList') ?? []);
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> retrieveUserInfo(
      String userId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  Future<void> unblockUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'blockList': FieldValue.arrayRemove([userId]),
    });
    setState(() {
      blockList.remove(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blocked List',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: blockList == null
          ? const Center(child: CircularProgressIndicator())
          : blockList.isEmpty
              ? const Center(
                  child: Text('No users blocked'),
                )
              : ListView.builder(
                  itemCount: blockList.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<
                        DocumentSnapshot<Map<String, dynamic>>>(
                      future: retrieveUserInfo(blockList[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        } else if (!snapshot.hasData) {
                          return const ListTile(
                            title: Text('User data not available'),
                          );
                        } else {
                          Map<String, dynamic> userData =
                              snapshot.data!.data()!;
                          String userName = userData['name'];
                          String userImage = userData['imageProfile'];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userImage),
                            ),
                            title: Text(userName),
                            trailing: IconButton(
                                icon: const Icon(Icons.block),
                                onPressed: () {
                                  confirm(
                                    context,
                                    ConfirmDialog(
                                      'Are you sure to unblock?',
                                      message: 'It going to unblock?',
                                      variant: Variant.warning,
                                      confirmed: () async {
                                        // do something here
                                        unblockUser(blockList[index]);

                                        alert(
                                          context,
                                          'Block User',
                                          'It unblocked succefully',
                                          variant: Variant.warning,
                                        );
                                      },
                                    ),
                                  );
                                }),
                            // You can add more details about the blocked user if needed
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
