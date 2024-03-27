import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/SplashScreen.dart';
import 'package:date/view/auth/AuthScreen.dart';
import 'package:date/view/auth/onBoarding/First.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/person.dart' as personModel;
import '../view/auth/onBoarding/Fourth.dart';
import '../view/home/home_screen.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController authenticationController = Get.find();
  late Rx<File?> pickedFile;
  late Rx<User?> firebaseCurrentUser;
  XFile? imageFile;
  File? get profileImage => pickedFile.value;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController religionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController professionController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController lookingForController = TextEditingController();
  TextEditingController imageProfileController = TextEditingController();

  final List<String> _selectedInterests = [];
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<String> selectedInterests = [];
  static String verifyId = "";
  pickImageFileFromGallery() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      Get.snackbar(
          "Profile Image", "you have successfully picked your profile image");
      pickedFile = Rx<File?>(File(imageFile!.path));
      imageProfileController.text =
          await uploadImageToStorage(pickedFile.value!);
    }
  }

  captureImageFromPhone() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Get.snackbar("Profile Image",
          "you have successfully picked your profile image using camera");
      pickedFile = Rx<File?>(File(imageFile!.path));
      imageProfileController.text =
          await uploadImageToStorage(pickedFile.value!);
    }
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    // Check file size before upload
    if (imageFile.lengthSync() > 4 * 1024 * 1024) {
      throw Exception("Image file exceeds 4MB limit");
    }

    Reference reference = FirebaseStorage.instance
        .ref()
        .child("profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask task = reference.putFile(imageFile);
    TaskSnapshot snapshot = await task;
    String downloadUrlOfImage = await snapshot.ref.getDownloadURL();
    return downloadUrlOfImage;
  }

  createNewUser(
      String imageProfile,
      String age,
      String name,
      String email,
      String? gender,
      String phoneNo,
      String city,
      String country,
      String state,
      String profession,
      String religion,
      List<String> interests,
      String lookingFor,
      String bio,
      bool? paymentStatus) async {
    try {
      // UserCredential userCredential = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(email: email, password: password);
      // if (kDebugMode) {
      //   print("$userCredential");
      // }

      personModel.Person person = personModel.Person(
          uid: FirebaseAuth.instance.currentUser!.uid,
          imageProfile: imageProfile,
          email: email,
          age: int.parse(age),
          gender: gender,
          phoneNo: phoneNo,
          name: name,
          city: city,
          country: country,
          state: state,
          profession: profession,
          publishedDateTime: DateTime.now().millisecondsSinceEpoch,
          religion: religion,
          interests: interests,
          lookingFor: lookingFor,
          bio: bio,
          paymentStatus: true);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(person.toJson());
      Get.snackbar(
          "Account Creation successful", "Account created successfully");
      Get.to(HomeScreen());
      genderController.clear();
      nameController.clear();
      cityController.clear();
      countryController.clear();
      stateController.clear();
      professionController.clear();
      religionController.clear();
      imageProfileController.clear();
      emailController.clear();
      lookingForController.clear();
      bioController.clear();
      ageController.clear();
      genderController.clear();
    } catch (errorMsg) {
      if (kDebugMode) {
        print("$errorMsg");
      }
      Get.snackbar("Account Creation unsuccessful", "$errorMsg");
    }
  }

  loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailUser, password: passwordUser);
      Get.snackbar("Login Successfull", "logged-in successfully");

      Get.to(HomeScreen());
    } catch (error) {
      Get.snackbar("Login Unsuccessful",
          "Error occurred during signin authentication:${error}");
    }
  }

  checkIfUserIsLoggedIn(User? currentUser) {
    if (currentUser == null) {
      Get.to(SplashScreen());
    } else {
      Get.to(const HomeScreen());
    }
  }

  Future sentOtp(
      {required String phone,
      required Function errorStep,
      required Function nextStep}) async {
    await _firebaseAuth
        .verifyPhoneNumber(
            phoneNumber: phone,
            timeout: Duration(seconds: 30),
            verificationCompleted: (PhoneAuthCredential) async {
              return;
            },
            verificationFailed: (error) async {
              return;
            },
            codeSent: (verificationId, forceResendingToken) async {
              verifyId = verificationId;
              nextStep();
            },
            codeAutoRetrievalTimeout: (verificationId) async {
              return;
            })
        .onError((error, stackTrace) {
      errorStep();
    });
  }

  Future loginWithOtp({required String otp}) async {
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);
    try {
      final user = await _firebaseAuth.signInWithCredential(cred);
      if (user.user != null) {
        // return "Success";
        print(cred.providerId);
        Get.to(FirstPage());
      } else {
        return "Error in otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future loginOtp({required String otp}) async {
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);
    try {
      final bool isUserRegistered = await isRegisteredUser(cred.providerId);
      if (isUserRegistered) {
        final user = await _firebaseAuth.signInWithCredential(cred);
        if (user.user != null) {
          // return "Success";
          Get.to(HomeScreen());
        } else {
          return "Error ";
        }
      } else {
        return "NotRegistered";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> isRegisteredUser(String userId) async {
    try {
      // Get the user document from the "users" collection
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Check if the document exists
      return userSnapshot.exists;
    } catch (e) {
      // Handle errors, such as Firestore exceptions
      print('Error checking user registration: $e');
      return false;
    }
  }

  // @override
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());
    ever(firebaseCurrentUser, checkIfUserIsLoggedIn);
  }
}
