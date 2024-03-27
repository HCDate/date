import 'dart:io';

import 'package:async_button/async_button.dart';
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
import 'package:text_area/text_area.dart';

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
  var reasonValidation = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
  bool uploading = false, next = true;
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
  String urlImage1 = "";
  String urlImage2 = "";
  String urlImage3 = "";
  String urlImage4 = "";
  String urlImage5 = "";
  String? selectedGender;
  AsyncBtnStatesController btnStateController = AsyncBtnStatesController();
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
      if (img.lengthSync() > 4 * 1024 * 1024) {
        // Check for 4MB size limit
        // Display a message indicating the file is too large
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image size exceeds 4MB limit.")),
        );
        continue; // Skip to the next image
      }
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
          if (snapshot.data()!["urlImage1"] != null) {
            setState(() {
              urlImage1 = snapshot.data()!["urlImage1"];
              urlImage2 = snapshot.data()!["urlImage2"];
              urlImage3 = snapshot.data()!["urlImage3"];
              urlImage4 = snapshot.data()!["urlImage4"];
              urlImage5 = snapshot.data()!["urlImage5"];
            });
          }
        });
      }
    });
  }

  updateUserDataWithOutImage(String name, String phoneNo, String profession,
      String bio, List interests) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': name,
      'phoneNo': phoneNo,
      'profession': profession,
      'bio': bio,
      'interests': interests
    });
    toast(context, 'Confirmed', variant: Variant.success);
    Get.to(HomeScreen());
  }

  updateUserData(String name, String phoneNo, String profession, String bio,
      List interests) async {
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
      'profession': profession,
      'bio': bio,
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

  update() async {
    if (authenticationController.nameController.text.trim().isNotEmpty) {
      _image.isNotEmpty
          ? updateUserData(
              authenticationController.nameController.text.trim(),
              authenticationController.phoneController.text.trim(),
              authenticationController.professionController.text.trim(),
              authenticationController.bioController.text.trim(),
              authenticationController.selectedInterests)
          : updateUserDataWithOutImage(
              authenticationController.nameController.text.trim(),
              authenticationController.phoneController.text.trim(),
              authenticationController.professionController.text.trim(),
              authenticationController.bioController.text.trim(),
              authenticationController.selectedInterests);
    } else {
      Get.snackbar(
          "A Field is Empty", "please fill out all field in text field");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserData();
    authenticationController.bioController.addListener(() {
      setState(() {
        reasonValidation = authenticationController.bioController.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<bool> selectedList =
        List.generate(availableInterests.length, (index) => false);
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              next
                  ? Get.back()
                  : setState(() {
                      next = true;
                    });
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
                ? IconButton(
                    onPressed: () async {
                      setState(() {
                        uploading = false;
                        next = false;
                      });
                    },
                    icon: const Icon(
                      Icons.navigate_next_outlined,
                      size: 36,
                    ))
                : Container()
          ]),
      body: next
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
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
                      height: 150,
                      child: Form(
                        key: formKey,
                        child: TextArea(
                          borderRadius: 10,
                          borderColor: const Color(0xFFCFD6FF),
                          textEditingController:
                              authenticationController.bioController,
                          validation: reasonValidation,
                          errorText: 'Please type a short bio!',
                        ),
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
                    AsyncElevatedBtn.withDefaultStyles(
                      sizeAnimationClipper: Clip.antiAliasWithSaveLayer,
                      switchInAnimationCurve: Curves.bounceOut,
                      asyncBtnStatesController: btnStateController,
                      onPressed: () async {
                        btnStateController.update(AsyncBtnState.loading);
                        try {
                          // Await your api call here
                          await update();
                          await Future.delayed(const Duration(seconds: 10));
                          btnStateController.update(AsyncBtnState.success);
                        } catch (e) {
                          btnStateController.update(AsyncBtnState.failure);
                        }
                      },
                      child: const Text('Update'),
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
                ),
              ],
            ),
    );
  }
}
