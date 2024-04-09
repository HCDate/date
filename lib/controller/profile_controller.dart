import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../models/person.dart';
import '../services/notification_service.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;
  NotificationService notificationService = NotificationService();
  final Rx<Set<String>> _likedUserIds = Rx<Set<String>>({});
  final Rx<Set<String>> _favoritedUserIds = Rx<Set<String>>({});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String gender = '';
  String lookingFor = '';
  getResults() async {
    onInit();
  }

  @override
  void onInit() async {
    super.onInit();
    fetchLikedUserIds();
    fetchFavoritedUserIds();
    DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    String currentGender = currentUserDoc['gender'];
    String currentLookingFor = currentUserDoc['lookingFor'];

    if (chosenAge == null) {
      usersProfileList.bindStream(
        FirebaseFirestore.instance
            .collection("users")
            .where("lookingFor", whereIn: [currentLookingFor.toUpperCase(), currentLookingFor.toLowerCase()])
            .orderBy("publishedDateTime", descending: true)
            .snapshots()
            .map((QuerySnapshot queryDataSnapshot) {
          List<Person> profileList = [];

          for (var eachProfile in queryDataSnapshot.docs) {
            if (eachProfile["uid"] != FirebaseAuth.instance.currentUser!.uid) {
              var person = Person.fromDataSnapshot(eachProfile);

              // Apply additional filtering based on 'gender'
              if (person.gender!.toLowerCase() != currentGender.toLowerCase()) {
                profileList.add(person);
              }
            }
          }

          return profileList;
        }),
      );
    } else {
      usersProfileList.bindStream(
        FirebaseFirestore.instance
            .collection("users")
            .where("lookingFor", whereIn: [currentLookingFor.toUpperCase(), currentLookingFor.toLowerCase()])
            .where("age", isGreaterThanOrEqualTo: int.parse(chosenAge.toString()))
            .snapshots()
            .map((QuerySnapshot queryDataSnapshot) {
          List<Person> profileList = [];

          for (var eachProfile in queryDataSnapshot.docs) {
            if (eachProfile["uid"] != FirebaseAuth.instance.currentUser!.uid) {
              var person = Person.fromDataSnapshot(eachProfile);

              // Apply additional filtering based on 'gender'
              if (person.gender!.toLowerCase() != currentGender.toLowerCase()) {
                profileList.add(person);
              }
            }
          }

          return profileList;
        }),
      );
    }
  }

  favoriteSentAndFavoriteReceived(
      String toUserID, String senderName, String receiverToken) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('favoriteReceived')
        .doc(currentUserID)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserID)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection('favoriteSent')
          .doc(toUserID)
          .delete();
      Get.snackbar("UnFavorite successful", "UnFavorite  successfully");
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('favoriteSent')
          .doc(toUserID)
          .set({});

      sendPushNotification(
          receiverToken, senderName, 'New Favorite', 'Favorited you');
      // notificationService.sendNotificationToUser(
      //     toUserID, "favorite", senderName);
      Get.snackbar("Favorite successful", "Favorite Added successfully");
    }
  }

  likeSentAndFavoriteReceived(
      String toUserID, String senderName, String receiverToken) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('likeReceived')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('likeSent')
          .doc(toUserID)
          .delete();
      Get.snackbar("UnLike successful", "UnLike  successfully");
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('likeSent')
          .doc(toUserID)
          .set({});
      sendPushNotification(receiverToken, senderName, 'New Like', 'Like you');
      // notificationService.sendNotificationToUser(toUserID, "like", senderName);
      Get.snackbar("Like successful", "Like Added successfully");
    }
  }

  // ignore: non_constant_identifier_names
  ViewSentAndViewReceived(
      String toUserID, String senderName, String receiverToken) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('viewReceived')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (document.exists) {
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("viewReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('viewSent')
          .doc(toUserID)
          .set({});
      sendPushNotification(receiverToken, senderName, 'New View', 'Viewed You');
      // notificationService.sendNotificationToUser(toUserID, "view", senderName);
      Get.snackbar("View successful", "View Added successfully");
    }
  }

  Future<void> fetchLikedUserIds() async {
    final likedDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection('likeSent')
        .get();

    final likedUserIds = likedDocs.docs.map((doc) => doc.id).toSet();
    _likedUserIds.value = likedUserIds;
  }

  Future<void> fetchFavoritedUserIds() async {
    final favoritedDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection('favoriteSent')
        .get();

    final favoritedUserIds = favoritedDocs.docs.map((doc) => doc.id).toSet();
    _favoritedUserIds.value = favoritedUserIds;
  }

  Future<List<bool>> checkUserActions(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final likeDoc = await _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection('likeSent')
        .doc(userId)
        .get();
    final favoriteDoc = await _firestore
        .collection("users")
        .doc(currentUser.uid)
        .collection('favoriteSent')
        .doc(userId)
        .get();
    return [likeDoc.exists, favoriteDoc.exists];
  }

  Future<void> toggleLikedStatus(String userId) async {
    if (_likedUserIds.value.contains(userId)) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection('likeSent')
          .doc(userId)
          .delete();
      _likedUserIds.value.remove(userId);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection('likeSent')
          .doc(userId)
          .set({});
      _likedUserIds.value.add(userId);
    }
  }

  Future<void> toggleFavoritedStatus(String userId) async {
    if (_favoritedUserIds.value.contains(userId)) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection('favoriteSent')
          .doc(userId)
          .delete();
      _favoritedUserIds.value.remove(userId);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection('favoriteSent')
          .doc(userId)
          .set({});
      _favoritedUserIds.value.add(userId);
    }
  }

  bool isLiked(String userId) {
    return _likedUserIds.value.contains(userId);
  }

  bool isFavorited(String userId) {
    return _favoritedUserIds.value.contains(userId);
  }

  Future<bool> hasLiked(String userId) async {
    DocumentSnapshot likedDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('likeSent')
        .doc(userId)
        .get();
    return likedDoc.exists;
  }

  Future<bool> hasFavorited(String userId) async {
    DocumentSnapshot favoritedDocs = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favoriteSent')
        .doc(userId)
        .get();
    return favoritedDocs.exists;
  }

  Future<void> sendPushNotification(token, senderName, title, content) async {
    try {
      final body = {
        "to": token,
        // "fjcUE_ZqQrqsxhK6a4BqfC:APA91bE8VPBLKcRLoluzWZ_xoALhWXrK2K7jBCLpaGnZr4Lt-aT0BYDpnA53-zdVhYdG_27RS6TSSqF-FmyP8am_MtSTS6kJDP6V4OXqEdER4m0lr-j81isn7xYbxuEKEvgtvsIZZ7i6",
        "notification": {"title": title, "body": "$senderName " " $content"}
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

  Future<int> getFavoriteCount(String? currentUserID) async {
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection('favoriteReceived')
        .get();

    return snapshot.size; // Returns the number of documents in the collection
  }

  Future<int> getFavoritesCount(String? currentUserID) async {
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection('favoriteSent')
        .get();

    return snapshot.size; // Returns the number of documents in the collection
  }

  Future<int> getLikeCount(String? currentUserID) async {
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .collection('likeReceived')
        .get();

    return snapshot.size; // Returns the number of documents in the collection
  }

  List<String> blockList = [];
  retrieveUserInfo(String userIdToAddToBlockList) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        blockList = List<String>.from(snapshot.get('blockList') ?? []);
        if (!blockList.contains(userIdToAddToBlockList)) {
          blockList.add(userIdToAddToBlockList);
          addToBlockList(blockList);
          blockList.clear();
          // Update the blocklist in Firestore
        }
      }
    });
  }

  void addToBlockList(List<String> blockList) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the current user's blocklist

    // Add the user ID to the blocklist if it's not already there

    // Update the blocklist in Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserId)
        .update({'blockList': blockList});
  }
}
