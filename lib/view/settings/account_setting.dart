import 'dart:io';

import 'package:bilions_ui/bilions_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/auth_controller.dart';
import '../../controller/message_controller.dart';
import '../../services/interest.dart';
import '../../widgets/custom_text_field.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});
  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  List<Interest> availableInterests = [
    Interest(name: 'Photography', image: 'assets/images/camera.png'),
    Interest(name: 'Shopping', image: 'assets/images/weixin-market.png'),
    Interest(name: 'Cooking', image: 'assets/images/noodles.png'),
    Interest(name: 'Tennis', image: 'assets/images/tennis.png'),
    Interest(name: 'Run', image: 'assets/images/sport.png'),
    Interest(name: 'Swimming', image: 'assets/images/ripple.png'),
    Interest(name: 'Art', image: 'assets/images/platte.png'),
    Interest(name: 'Traveling', image: 'assets/images/outdoor.png'),
    Interest(name: 'Extreme', image: 'assets/images/parachute.png'),
    Interest(name: 'Drink', image: 'assets/images/goblet-full.png'),
    Interest(name: 'Music', image: 'assets/images/music.png'),
    Interest(name: 'Video games', image: 'assets/images/game-handle.png'),
    // Add
  ];
  var authenticationController =
      AuthenticationController.authenticationController;
  bool uploading = false, next = false;
  final ChatController _chatController = ChatController();
  final List<File> _image = [];
  List<String> urlsList = [];
  List interests = [];
  FocusNode focusNode = FocusNode();
  String phoneNumber = "";
  double val = 0;
  String name = "";
  String age = "";
  String phoneNo = "";
  String email = "";
  String password = "";
  String city = "";
  String country = "";
  String bio = '';

  String profession = "";

  String religion = "";
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
  String? selectedGender;
  chooseImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
  }

  uploadImages() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      await _chatController.deleteImageFromStorage(urlImage1);
      await _chatController.deleteImageFromStorage(urlImage2);
      await _chatController.deleteImageFromStorage(urlImage3);
      await _chatController.deleteImageFromStorage(urlImage4);
      await _chatController.deleteImageFromStorage(urlImage5);
      var refImage = FirebaseStorage.instance.ref().child(
          "images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
      await refImage.putFile(img).whenComplete(() async {
        await refImage.getDownloadURL().then((urlImage) {
          urlsList.add(urlImage);
          i++;
        });
      });
    }
  }

  retrieveUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!["name"];
          authenticationController.nameController.text = name;
          age = snapshot.data()!["age"].toString();
          email = snapshot.data()!['email'].toString();
          authenticationController.emailController.text = email;
          authenticationController.ageController.text = age;
          selectedGender = snapshot.data()!['gender'].toString();
          phoneNo = snapshot.data()!["phoneNo"].toString();
          authenticationController.phoneController.text = phoneNo;
          city = snapshot.data()!["city"].toString();
          authenticationController.cityController.text = city;
          country = snapshot.data()!["country"].toString();
          authenticationController.countryController.text = country;

          religion = snapshot.data()!["religion"].toString();
          authenticationController.religionController.text = religion;
          profession = snapshot.data()!["profession"];
          authenticationController.professionController.text = profession;
          bio = snapshot.data()!["bio"];
          authenticationController.bioController.text = bio;
          List<String> interests =
              List<String>.from(snapshot.get('interests') ?? []);
          authenticationController.selectedInterests = interests;
          urlImage1 = snapshot.data()!["urlImage1"];
          urlImage2 = snapshot.data()!["urlImage2"];
          urlImage3 = snapshot.data()!["urlImage3"];
          urlImage4 = snapshot.data()!["urlImage4"];
          urlImage5 = snapshot.data()!["urlImage5"];
        });
      }
    });
  }

  updateUserData(String name, String phoneNo, List interests) async {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.pink,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Uploading images...')
                  ],
                ),
              ),
            ),
          );
        });
    await uploadImages();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': name,
      'phoneNo': phoneNo,
      'urlImage1': urlsList[0].toString(),
      'urlImage2': urlsList[1].toString(),
      'urlImage3': urlsList[2].toString(),
      'urlImage4': urlsList[3].toString(),
      'urlImage5': urlsList[4].toString(),
      'interests': interests
    });
    // Get.snackbar("Updated", "your account has been updated");
    toast(context, 'Confirmed', variant: Variant.success);
    Get.to(HomeScreen());
    setState(() {
      uploading = false;
      _image.clear();
      urlsList.clear();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
    List<bool> selectedList =
        List.generate(availableInterests.length, (index) => false);
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.navigate_before_outlined,
              size: 36,
            ),
          ),
          title: Text(
            next ? "Profile Information" : "Choose 5 Images",
            style: const TextStyle(color: Colors.pink, fontSize: 22),
          ),
          actions: [
            next
                ? Container()
                : IconButton(
                    onPressed: () async {
                      if (_image.length == 5) {
                        setState(() {
                          uploading = false;
                          next = true;
                        });
                      } else {
                        Get.snackbar("5 images", 'please choose 5 images');
                        alert(
                          context,
                          '5 images',
                          'please choose 5 images',
                          variant: Variant.info,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.navigate_next_outlined,
                      size: 36,
                    ))
          ]),
      body: next
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Personal Info:",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.nameController,
                        labelText: "name",
                        iconData: Icons.person,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    SizedBox(
                      height: 70,
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FlutterPhoneNumberField(
                        style: const TextStyle(color: Colors.black),
                        focusNode: focusNode,
                        initialCountryCode: "ET",
                        pickerDialogStyle: PickerDialogStyle(
                          countryFlagStyle: const TextStyle(
                              fontSize: 17, color: Colors.white),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle:
                              TextStyle(color: Colors.black, fontSize: 14),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        languageCode: "en",
                        onChanged: (phone) {
                          if (phone.completeNumber.length == 13) {
                            setState(() {
                              phoneNumber = phone.completeNumber;
                              authenticationController.phoneController.text =
                                  phoneNumber;
                            });
                          }
                        },
                        onCountryChanged: (country) {
                          if (kDebugMode) {
                            print('Country changed to: ${country.name}');
                          }
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.cityController,
                        labelText: "City",
                        iconData: Icons.location_city,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.countryController,
                        labelText: "Country",
                        iconData: Icons.location_city,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.professionController,
                        labelText: "Profession",
                        iconData: Icons.business_center,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.religionController,
                        labelText: "Religion",
                        iconData: CupertinoIcons.checkmark_seal_fill,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.bioController,
                        labelText: "Bio",
                        iconData: CupertinoIcons.checkmark_seal_fill,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 50),
                      itemCount: availableInterests.length,
                      itemBuilder: (context, index) {
                        final isSelected = authenticationController
                            .selectedInterests
                            .contains(availableInterests[index].name);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                authenticationController.selectedInterests
                                    .remove(availableInterests[index].name);
                              } else {
                                authenticationController.selectedInterests
                                    .add(availableInterests[index].name);
                              }
                            });
                            if (kDebugMode) {
                              print(authenticationController.selectedInterests);
                            }
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: isSelected ? Colors.pink : Colors.white,
                                borderRadius: BorderRadius.circular(
                                    20)), // Adjust the height as needed

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  availableInterests[index].image,
                                  width: 30, // Adjust the width as needed
                                  height: 30, // Adjust the height as needed
                                ),
                                const SizedBox(
                                    height: 4), // Adjust the spacing as needed
                                Text(
                                  availableInterests[index].name,
                                  style: TextStyle(
                                    fontSize:
                                        12, // Adjust the font size as needed
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 30,
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: InkWell(
                        onTap: () {
                          if (authenticationController.nameController.text
                              .trim()
                              .isNotEmpty) {
                            _image.isNotEmpty
                                ? updateUserData(
                                    authenticationController.nameController.text
                                        .trim(),
                                    authenticationController
                                        .phoneController.text
                                        .trim(),
                                    authenticationController.selectedInterests)
                                : null;
                          } else {
                            Get.snackbar("A Field is Empty",
                                "please fill out all field in text field");
                          }
                        },
                        child: const Center(
                            child: Text(
                          "Update",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    // showProgressBar == true
                    //     ? CircularProgressIndicator(
                    //         valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    //       )
                    //     : Container()
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  child: GridView.builder(
                      itemCount: _image.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Container(
                                color: Colors.grey,
                                child: Center(
                                  child: IconButton(
                                      onPressed: () {
                                        if (_image.length < 5) {
                                          !uploading ? chooseImage() : null;
                                        } else {
                                          setState(() {
                                            uploading = true;
                                          });
                                          Get.snackbar("5 Images Chosen",
                                              "5 Images Already Selected");
                                        }
                                      },
                                      icon: const Icon(Icons.add)),
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(_image[index - 1]),
                                        fit: BoxFit.cover)),
                              );
                      }),
                )
              ],
            ),
    );
  }
}
