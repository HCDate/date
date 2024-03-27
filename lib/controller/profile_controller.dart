import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';
import '../models/person.dart';
import '../services/notification_service.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;
  NotificationService notificationService = NotificationService();
  String gender = '';
  String lookingFor = '';
  getResults() async {
    onInit();
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    String currentGender = currentUserDoc['gender'];
    String currentLookingFor = currentUserDoc['lookingFor'];

    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(currentUserID)
    //     .get()
    //     .then((dataSnapshot) {

    //   gender = dataSnapshot.data()!["gender"].toString();
    //   lookingFor = dataSnapshot.data()!["lookingFor"].toString();
    // });

    usersProfileList.bindStream(
      FirebaseFirestore.instance
          .collection("users")
          .where("lookingFor", isEqualTo: currentLookingFor.toString())
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

  ViewSentAndViewReceived(
      String toUserID, String senderName, String receiverToken) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('viewReceived')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (document.exists) {
      print('already in view list');
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
              "key=AAAAwe9tmkg:APA91bGI9ACjGc3NuMC4FHIDyP2SbNzdoBZsLCL3cy_Savr_8TJ51cxfJI3ROrwyqYgizOJT2KNlDmEbZJLUoWXS1LCFfTT4TYumembJkxNG6f8vpk1K9W-fd8PHJ7GgHVF8s6IcOewN"
        },
        body: jsonEncode(body),
      );
      print('response $response');
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
