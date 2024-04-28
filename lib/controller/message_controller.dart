import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/chat.dart';
import '../models/message.dart';
import '../models/person.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  late Rx<File?> pickedFile;
  late Rx<User?> firebaseCurrentUser;
  XFile? imageFile;
  File? get profileImage => pickedFile.value;
  pickImageFileFromGallery() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      Get.snackbar(
          "Chat Image", "You have uploaded an image successfully!");
    }
    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  captureImageFromPhone() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Get.snackbar("Chat Image",
          "you have successfully picked your profile image using camera");
    }
    pickedFile = Rx<File?>(File(imageFile!.path));
  }
  
  Stream<List<Chat>> getChats(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('memberIds', arrayContains: userId)
          .snapshots()
          .map((querySnapshot) {
            final chats = querySnapshot.docs.map((chatDoc) {
              // Convert each chat document to a Chat object
              final chat = Chat.fromFirestore(chatDoc);
              return chat;
            }).toList();

            // Sort chats by the last message timestamp in descending order
            chats.sort((a, b) {
              final aTimestamp = a.messages.last.timestamp;
              final bTimestamp = b.messages.last.timestamp;
              return bTimestamp.compareTo(aTimestamp);
            });

            return chats;
          });
    } catch (error) {
      // You might want to handle the error differently based on your needs
      rethrow;
    }
  }

// Stream<List<Chat>> getSingleChat(String userId, String friendId) {
//   try {
//     return _firestore
//         .collection('chats')
//         .where('memberIds', arrayContains: userId)
//         .snapshots()
//         .map((querySnapshot) {
//           final chats = querySnapshot.docs.where((doc) {
//             // Check if the document contains both userId and friendId
//             return doc['memberIds'].contains(userId) && doc['memberIds'].contains(friendId);
//           }).toList();

//           if (chats.isNotEmpty) {
//             // If there are chats, return the chatId of the first chat
//             return chats;
//           } else {
//             // If there are no chats, return null
//             return [];
//           }
//         });
//   } catch (error) {
//     // You might want to handle the error differently based on your needs
//     rethrow;
//   }
// }

Future<DocumentSnapshot<Object?>?> getSingleChatById(String chatId) async {
  try {
    DocumentSnapshot<Object?> chatDoc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get();

    // Check if the document exists
    if (chatDoc.exists) {
      return chatDoc;
    } else {
      // If the document doesn't exist, return null
      return null;
    }
  } catch (error) {
    // You might want to handle the error differently based on your needs
    print("Error fetching chat: $error");
    return null;
  }
}
  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      // Check file size before upload
      if (imageFile.lengthSync() > 4 * 1024 * 1024) {
        return "";
      } else {
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("Images")
            .child(Uuid().v4());

        UploadTask task = reference.putFile(imageFile);

        // Monitor upload progress
        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        });

        TaskSnapshot snapshot = await task;
        String downloadUrlOfImage = await snapshot.ref.getDownloadURL();
        return downloadUrlOfImage;
      }
    } catch (e) {
      // Handle upload errors appropriately, e.g., display user-friendly messages
      return '';
    }
  }

  Future<void> sendMessageWithImage(
      String chatId, String senderId, String token) async {
    try {
      // Reference to the specific collection of messages within the chat
      String urlOfDownloadedImage = await uploadImageToStorage(profileImage!);
      if (urlOfDownloadedImage != '') {
        CollectionReference messagesCollection =
            _firestore.collection('chats').doc(chatId).collection('messages');

        // Add the new message to the collection and get the automatically generated ID
        DocumentReference newMessageRef = await messagesCollection.add({
          'content': urlOfDownloadedImage,
          'type': 'image',
          'seen': false,
          'senderId': senderId,
          'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
          'duration': ''
        });

        // Get the automatically generated message ID
        Message newMessage = Message(
            id: newMessageRef.id,
            content: urlOfDownloadedImage,
            seen: false,
            type: 'image',
            senderId: FirebaseAuth.instance.currentUser!.uid,
            timestamp: Timestamp.now(),
            duration: '');

        String name = await getUserNameFromMemberId(
            FirebaseAuth.instance.currentUser!.uid);

        await addMessageToChat(chatId, newMessage);
        sendPushNotification(token, name, 'have image');
      } else {
        Get.snackbar(
            "Chat Image", "Your image exceed 4mb.please choice low.");
      }
    } catch (error) {
      throw error; // Handle the error as per your requirement
    }
  }

  Future<void> sendMessageWithVoice(String chatId, String senderId, String url,
      String duration, String token) async {
    try {
      // Reference to the specific collection of messages within the chat
      // String urlOfDownloadedImage = await uploadImageToStorage(profileImage!);

      CollectionReference messagesCollection =
          _firestore.collection('chats').doc(chatId).collection('messages');

      // Add the new message to the collection and get the automatically generated ID
      DocumentReference newMessageRef = await messagesCollection.add({
        'content': url,
        'type': 'voice',
        'seen': false,
        'senderId': senderId,
        'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
        'duration': duration
      });

      // Get the automatically generated message ID
      String messageId = newMessageRef.id;
      Message newMessage = Message(
          id: newMessageRef.id,
          content: url,
          seen: false,
          type: 'image',
          senderId: FirebaseAuth.instance.currentUser!.uid,
          timestamp: Timestamp.now(),
          duration: duration);

      // await addMessageToChat(chatId, newMessage);
      String name =
          await getUserNameFromMemberId(FirebaseAuth.instance.currentUser!.uid);

      await addMessageToChat(chatId, newMessage);
      sendPushNotification(token, name, 'have voice');
    } catch (error) {
      throw error; // Handle the error as per your requirement
    }
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message(
            // Build your Message object based on the document data
            id: doc.id,
            content: doc['content'],
            seen: doc['seen'],
            type: doc['type'],
            senderId: doc['senderId'],
            timestamp: doc['timestamp'],
            duration: doc['duration']);
      }).toList();
    });
  }

  Future<Message> getMessageAndUpdateSeenStatus(
      String chatId, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    try {
      // Check if the current user is the sender
      final isCurrentUserSender =
          doc['senderId'] == FirebaseAuth.instance.currentUser!.uid;

      // Determine the initial 'seen' status based on whether the current user is the sender
      final initialSeenStatus = isCurrentUserSender ? doc['seen'] : true;

      // Update 'seen' only if the sender is not the current user and the message is not seen
      if (!isCurrentUserSender && !initialSeenStatus) {
        // Call the updateMessageSeenStatus function to handle the update
        await updateMessageSeenStatus(chatId, doc.id);
      }

      // Retrieve the updated document after the update
      final updatedDoc = await doc.reference.get();

      // Create a Message object from the updated document
      final updatedMessage = Message(
          id: updatedDoc.id,
          content: updatedDoc['content'],
          type: updatedDoc['type'],
          seen: updatedDoc['seen'],
          senderId: updatedDoc['senderId'],
          timestamp: updatedDoc['timestamp'],
          duration: updatedDoc['duration']);

      return updatedMessage;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMessageSeenStatus(String chatId, String messageId) async {
    try {
      final messageReference = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      final messageSnapshot = await messageReference.get();

      if (messageSnapshot.exists) {
        final isCurrentUserSender = messageSnapshot['senderId'] ==
            FirebaseAuth.instance.currentUser!.uid;

        // Update 'seen' only if the sender is not the current user and the message is not seen
        if (!isCurrentUserSender && !messageSnapshot['seen']) {
          await messageReference.update({'seen': true});
        }
      } else {
        if (kDebugMode) {
          print('Message does not exist.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating message seen status: $e');
      }
    }
  }

  Future<void> updateSeenStatusOnChatEnter(String chatId) async {
    try {
      final messagesReference =
          _firestore.collection('chats').doc(chatId).collection('messages');

      final messagesSnapshot = await messagesReference.get();

      // Prepare a batch to update "seen" status for all messages
      final batch = _firestore.batch();

      for (final messageDoc in messagesSnapshot.docs) {
        // Check if the message is not sent by the current user and not seen
        if (messageDoc['senderId'] != FirebaseAuth.instance.currentUser!.uid &&
            !messageDoc['seen']) {
          // Update "seen" status for the message in the batch
          batch.update(messageDoc.reference, {'seen': true});
          await updateSeenStatus(chatId);
        }
      }

      // Commit the batch to Firestore
      await batch.commit();
      // await _firestore.collection('chats').doc(chatId).update({'seen': true});
    } catch (e) {}
  }

  Future<void> sendMessage(
      String chatId, String senderId, String content, String token) async {
    try {
      // Reference to the specific collection of messages within the chat
      CollectionReference messagesCollection =
          _firestore.collection('chats').doc(chatId).collection('messages');

      // Add the new message to the collection and get the automatically generated ID
      DocumentReference newMessageRef = await messagesCollection.add({
        'content': content,
        'type': 'text',
        'seen': false,
        'senderId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
        'duration': ''
      });

      // Get the automatically generated message ID
      String messageId = newMessageRef.id;
      Message newMessage = Message(
          id: newMessageRef.id,
          content: content,
          seen: false,
          type: 'text',
          senderId: FirebaseAuth.instance.currentUser!.uid,
          timestamp: Timestamp.now(),
          duration: '');
      String name =
          await getUserNameFromMemberId(FirebaseAuth.instance.currentUser!.uid);

      await addMessageToChat(chatId, newMessage);
      String notificationContent = await fetchNotificationContent(content);
      sendPushNotification(token, name, notificationContent);
    } catch (error) {
      throw error; // Handle the error as per your requirement
    }
  }

  Future<String> fetchNotificationContent(String content) async {
    try {
      // Your asynchronous logic to fetch the notification content
      // For example, making a network request or accessing data
      // Replace this with your actual implementation
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate async operation
      return content;
    } catch (error) {
      // Handle errors here, like logging or providing a default message
      return "Error: Notification unavailable"; // Example default message
    }
  }

  Future<String> getUserNameFromMemberId(String memberId) async {
    try {
      // Retrieve the user information from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String userName = userData['name'];
        return userName;
      } else {
        return 'Unknown User'; // Placeholder if user data doesn't exist
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Chat>> filterChatsByQuery(String currentUserId, String query, List<Chat> chats) async {
    query = query.toLowerCase();

    List<Chat> filteredChats = [];

    await Future.wait(chats.map((chat) async {
      // Filter based on chat members' names
      for (String memberId in chat.memberIds) {
        String userName = await getUserNameFromMemberId(memberId);
        if (userName.toLowerCase().contains(query)) {
          filteredChats.add(chat);
          break; // Break out of the inner loop once a match is found
        }
      }

      // Add additional filtering logic if needed
    }));

    return filteredChats;
  }

  Future<void> addMessageToChat(String chatId, Message newMessage) async {
    try {
      // Reference to the specific chat document
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Update the 'messages' field with a list containing the new message
      await chatRef.update({
        'messages': [newMessage.toJson()],
        'seen': false
      });
    } catch (error) {
      rethrow; // Handle the error as per your requirement
    }
  }

  Future<List<Map<String, dynamic>?>> getAllUsersExceptCurrent(
      String currentUserId) async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>?> usersList = usersSnapshot.docs
          .map((doc) {
            if (doc.id != currentUserId) {
              return {
                'id': doc.id,
                'name': doc[
                    'name'], // Assuming 'name' is a field in your 'users' collection
                'imageProfile': doc[
                    'imageProfile'], // Assuming 'imageProfile' is a field in your 'users' collection
              };
            } else {
              return null;
            }
          })
          .where((user) => user != null)
          .toList();
      return usersList;
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>?>> getUsersWithoutChat(
    String currentUserId,
  ) async {
    try {
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      String currentGender = currentUserDoc['gender'];
      // String currentLookingFor = currentUserDoc['lookingFor'];

      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      List<Map<String, dynamic>?> usersList = [];

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        if (userDoc.id != currentUserId) {
          // Check if the current user does not have a chat with this user
          var person = Person.fromDataSnapshot(userDoc);

          // Apply additional filtering based on 'gender'
          if (person.gender!.toLowerCase() != currentGender.toLowerCase()) {
            bool doesNotHaveChat =
                await currentUserDoesNotHaveChat(currentUserId, userDoc.id);

            if (doesNotHaveChat) {
              usersList.add({
                'id': userDoc.id,
                'name': userDoc['name'],
                'imageProfile': userDoc['imageProfile'],
              });
            }
          }
        }
      }

      return usersList;
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> currentUserDoesNotHaveChat(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      // Check if there's a chat where both users are members
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('memberIds', arrayContains: currentUserId)
          .get();

      // Check if there's any chat with the other user
      for (QueryDocumentSnapshot chatDoc in chatSnapshot.docs) {
        List<dynamic> memberIds = chatDoc['memberIds'];
        if (memberIds.contains(otherUserId)) {
          // A chat between current user and other user exists
          return false;
        }
      }

      // No chat found between current user and other user
      return true;
    } catch (error) {
      rethrow;
    }
  }

  UploadTask uploadAudio(var audioFile, String fileName) {
    Reference reference = _storage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(audioFile);
    return uploadTask;
  }

  Future<void> deleteMessage(
      String chatId, String messageId, String? imageUrl) async {
    try {
      // Delete the message entry from Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Delete the image from storage
      if (imageUrl != null) {
        await deleteImageFromStorage(imageUrl);
      }
    } catch (error) {
      rethrow; // Handle the error as per your requirement
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
    } catch (error) {
      rethrow; // Handle the error as per your requirement
    }
  }

  Future<File> downloadImage(String imagePath) async {
    try {
      // Get the download URL for the image
      String downloadURL =
          await _storage.ref().child(imagePath).getDownloadURL();

      // Download the image using http
      http.Response response = await http.get(Uri.parse(downloadURL));

      // Save the file to a temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final File file = File('$tempPath/temp_image.jpg');
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createChat(Chat newChat) async {
    try {
      // Add the new chat document to the Firestore 'chats' collection
      await _firestore.collection('chats').doc(newChat.id).set({
        'id': newChat.id,
        'memberIds': newChat.memberIds,
        'messages':
            newChat.messages.map((message) => message.toJson()).toList(),
        'seen': newChat
            .seen // Assuming you have a method toJson() in your Message model
      });
    } catch (error) {
      rethrow; // Handle the error as per your requirement
    }
  }

  Future<void> updateSeenStatus(
    String chatId,
  ) async {
    try {
      // Update the 'seen' field in the Firestore document
      await _firestore.collection('chats').doc(chatId).update({
        'seen': true,
      });
    } catch (error) {
      rethrow; // Handle the error as per your requirement
    }
  }

  Future<void> sendPushNotification(token, senderName, content) async {
    try {
      final body = {
        "to": token,
        // "fjcUE_ZqQrqsxhK6a4BqfC:APA91bE8VPBLKcRLoluzWZ_xoALhWXrK2K7jBCLpaGnZr4Lt-aT0BYDpnA53-zdVhYdG_27RS6TSSqF-FmyP8am_MtSTS6kJDP6V4OXqEdER4m0lr-j81isn7xYbxuEKEvgtvsIZZ7i6",
        "notification": {
          "title": "new message",
          "body": "$senderName " " $content"
        }
      };
      var response = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAmQs8YSM:APA91bEs344qRhwI_T056DlF6pUiOwhmjiwhsRWEXZP2e83YLI3BUkjxGWe-7k_FXokfMeUiUP2k1Z44UaoABDZ_mkeREjSCPu4NgOliVtU37ctcYyUaDpa52DgU8u3y73kDsQN3QpSg"
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      // Handle errors here
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      // Delete the chat document from the Firestore 'chats' collection
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (error) {
      rethrow; // Handle the error as per your requirement
    }
  }
}
