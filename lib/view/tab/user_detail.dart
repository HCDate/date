import 'dart:ui';

import 'package:bilions_ui/bilions_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/controller/profile_controller.dart';
import 'package:date/global.dart';
import 'package:date/view/home/home_screen.dart';
import 'package:date/view/settings/account_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_slider/carousel.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../controller/auth_controller.dart';
import '../auth/login/login_screen.dart';

// ignore: must_be_immutable
class UserDetailScreen extends StatefulWidget {
  String? userID;
  UserDetailScreen({super.key, this.userID});
  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with TickerProviderStateMixin {
  var authenticationController =
      AuthenticationController.authenticationController;
  List interests = [];
  String name = '';
  String age = '';
  String phoneNo = '';
  String city = '';
  String country = "";
  String bio = '';
  String profilePicture = '';

  String profession = "";
  String employmentStatus = "";
  String? lookingFor = "";
  String nationality = "";
  String eduation = '';
  String languageSpoken = "";
  String religion = '';
  String ethnicity = "";

  String urlImage1 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage2 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage3 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage4 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage5 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";

  retrieveUserInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (kDebugMode) {
          print(snapshot.data()!['']);
        }
        if (snapshot.data()!["urlImage1"] != null) {
          setState(() {
            urlImage1 = snapshot.data()!["urlImage1"];
            urlImage2 = snapshot.data()!["urlImage2"];
            urlImage3 = snapshot.data()!["urlImage3"];
            urlImage4 = snapshot.data()!["urlImage4"];
            urlImage5 = snapshot.data()!["urlImage5"];
          });
        }
        setState(() {
          profilePicture = snapshot.data()!["imageProfile"];
          name = snapshot.data()!["name"];
          age = snapshot.data()!["age"].toString();
          phoneNo = snapshot.data()!["phoneNo"];
          bio = snapshot.data()!["bio"];
          city = snapshot.data()!["city"];
          country = snapshot.data()!["country"];
          interests = List<String>.from(snapshot.get('interests') ?? []);
          religion = snapshot.data()!["religion"];
          profession = snapshot.data()!['profession'];
          lookingFor = snapshot.data()!['lookingFor'];
        });
        print(bio);
      }
    });
  }

  final ProfileController _profileController = ProfileController();
  String favorited = '';
  String liked = '';
  String favorites = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserInfo();
    count();
    likeCount();
    favoritescount();
    if (kDebugMode) {
      print(bio);
    }
  }

  void count() async {
    int counted = await _profileController.getFavoriteCount(widget.userID);

    setState(() {
      favorited = counted.toString();
    });
  }

  void likeCount() async {
    int counted = await _profileController.getLikeCount(currentUserID);
    setState(() {
      liked = counted.toString();
    });
  }

  void favoritescount() async {
    int counted = await _profileController.getFavoritesCount(widget.userID);

    setState(() {
      favorites = counted.toString();
    });
  }

  Map<String, bool> menuItemStates = {
    'Option 1': false,
    'Option 2': false,
    'Option 3': false,
  };

  void handleMenuItemClick(String menuItemValue) async {
    setState(() {
      menuItemStates[menuItemValue] = true;
    });

    // Perform action based on the clicked menu item
    if (menuItemValue == 'Option 1') {
      // Navigate to Edit User Detail screen
      Get.to(const AccountSettingScreen());
    } else if (menuItemValue == 'Option 2') {
      // Update profile photo
      await authenticationController.pickImageFileFromGallery();
      if (authenticationController.imageProfileController.text
          .trim()
          .isNotEmpty) {
        updateProfilePhoto(
            authenticationController.imageProfileController.text.trim());
      }
    } else if (menuItemValue == "Option 3") {
      confirm(
        context,
        ConfirmDialog(
          'Are you sure?',
          message: 'Are you sure to Log out?',
          variant: Variant.warning,
          confirmed: () async {
            // do something here
            logout();
          },
        ),
      );
    }
  }

  updateProfilePhoto(String imageProfile) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .update({
      'imageProfile': imageProfile.toString(),
    });
    toast(context, 'Profile Changed', variant: Variant.success);
    setState(() {
      profilePicture = imageProfile;
    });
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  void logout() async {
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(const LoginScreen());
    } catch (error) {
      // Handle logout error
      print("Error during logout: $error"); // Log the error for debugging
      // You can also show a user-friendly error message using a snackbar or dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,

          title: const Text(
            "User Profile",
            style: TextStyle(color: Colors.pink),
          ),
          centerTitle: true,
          // automaticallyImplyLeading: widget.userID==currentUserID?false:true,
          leading: widget.userID != FirebaseAuth.instance.currentUser!.uid
              ? InkWell(
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
                )
              : Container(),
          actions: [
            widget.userID == FirebaseAuth.instance.currentUser!.uid
                ? Row(
                    children: [
                      PopupMenuButton(
                        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                          PopupMenuItem(
                            onTap: () async {
                              if (menuItemStates['Option 1'] != null &&
                                  !menuItemStates['Option 1']!) {
                                handleMenuItemClick('Option 1');
                              }
                            },
                            value: 'Option 1',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                                Text("Edit User Detail")
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () async {
                              if (menuItemStates['Option 2'] != null &&
                                  !menuItemStates['Option 2']!) {
                                handleMenuItemClick('Option 2');
                              }
                            },
                            value: 'Option 2',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 20,
                                ),
                                Text("Set Profile Photo")
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () async {
                              if (menuItemStates['Option 3'] != null &&
                                  !menuItemStates['Option 3']!) {
                                handleMenuItemClick('Option 3');
                              }
                            },
                            value: 'Option 3',
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () async {},
                                    icon: const Icon(
                                      Icons.logout,
                                      size: 20,
                                    )),
                                Text("Log out")
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Container()
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(profilePicture.toString()),
                  backgroundColor: Colors.black,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name + ',' + age,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Center(child: Text(profession.toUpperCase()))
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                widget.userID != FirebaseAuth.instance.currentUser!.uid
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Looking For",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(lookingFor!)
                        ],
                      )
                    : SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          favorited,
                          style:
                              const TextStyle(color: Colors.pink, fontSize: 20),
                        ),
                        const Text("Favorited")
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          liked == '' ? '0' : liked,
                          style:
                              const TextStyle(color: Colors.pink, fontSize: 20),
                        ),
                        const Text("Liked")
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          favorites == '' ? '0' : liked,
                          style:
                              const TextStyle(color: Colors.pink, fontSize: 20),
                        ),
                        const Text("Favorites")
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  child: TabBar(
                      labelColor: Colors.black,
                      controller: tabController,
                      isScrollable: true,
                      indicatorColor: Colors.pink,
                      tabs: const [
                        Tab(
                          text: "About",
                        ),
                        Tab(
                          text: "Gallery",
                        )
                      ]),
                ),
                SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: TabBarView(controller: tabController, children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Location",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(city + ',' + country)
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Profession",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(profession.toUpperCase())
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Bio",
                              maxLines: 6,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(bio)
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          'Interests',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                        SizedBox(
                          height: 60, // Set the desired height
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: interests.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    // color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors
                                          .pink, // Change the border color to pink
                                    ),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        interests[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.pink,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    ImageSlider([
                      urlImage1,
                      urlImage2,
                      urlImage3,
                      urlImage4,
                      urlImage5
                    ]),
                  ]),
                ),
              ],
            ),
          ),
        ));
  }
}
