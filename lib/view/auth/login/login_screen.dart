import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/view/auth/onBoarding/onBoardingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../controller/auth_controller.dart';
import '../../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String phoneNumber = "";
  TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showProgressBar = false;
  var controllerAuth = Get.put(AuthenticationController());
  var authenticationController =
      AuthenticationController.authenticationController;
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        final User userDetails =
            (await FirebaseAuth.instance.signInWithCredential(credential))
                .user!;
        authenticationController.nameController.text =
            userDetails.displayName ?? '';
        authenticationController.emailController.text = userDetails.email ?? '';
        // authenticationController.profileImage.toString()=userDetails.photoURL;
        // Get.to(FirstPage());

        print(userDetails.uid);
      } on FirebaseAuthException catch (e) {
        alert(
          context,
          'Title here',
          e.message ?? '',
          variant: Variant.warning,
        );
      }
    } else {
      alert(
        context,
        'Title here',
        'Description here',
        variant: Variant.warning,
      );
    }
    // Obtain the auth details from the request

    // Create a new credential

    // Once signed in, return the UserCredential
    // final user = await FirebaseAuth.instance.signInWithCredential(credential);
    // print(user);
    // return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/splash.jpg', // Replace this with your background image asset
          fit: BoxFit.cover,
        ),
      ),
      Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 500.0),
              SizedBox(
                height: 75,
                width: MediaQuery.of(context).size.width * 0.8,
                child: FlutterPhoneNumberField(
                  style: TextStyle(color: Colors.white),
                  focusNode: focusNode,
                  initialCountryCode: "ET",
                  pickerDialogStyle: PickerDialogStyle(
                    countryFlagStyle:
                        const TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                  ),
                  languageCode: "en",
                  onChanged: (phone) {
                    if (phone.completeNumber.length == 13) {
                      setState(() {
                        phoneNumber = phone.completeNumber;
                      });
                      confirm(
                        context,
                        ConfirmDialog(
                          'Are you sure?',
                          message: 'Are you sure is your phone number?',
                          variant: Variant.warning,
                          confirmed: () {
                            // do something here
                            authenticationController.sentOtp(
                                phone: phoneNumber,
                                errorStep: () => alert(
                                      context,
                                      'Title here',
                                      'Description here',
                                      variant: Variant.warning,
                                    ),
                                nextStep: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text("OTP verification"),
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Enter 6 digit"),
                                                SizedBox(
                                                  height: 12,
                                                ),
                                                Form(
                                                  key: _formKey,
                                                  child: TextFormField(
                                                    controller: _otpController,
                                                    keyboardType:
                                                        TextInputType.phone,
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            'Enter you phone number',
                                                        border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        32))),
                                                    validator: (value) {
                                                      if (value!.length != 6)
                                                        return "Invalid";
                                                      return null;
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      authenticationController
                                                          .loginOtp(
                                                              otp:
                                                                  _otpController
                                                                      .text);
                                                    }
                                                  },
                                                  child: Text("Submit"))
                                            ],
                                          ));
                                });
                          },
                        ),
                      );
                    }
                  },
                  onCountryChanged: (country) {
                    if (kDebugMode) {
                      print('Country changed to: ${country.name}');
                    }
                  },
                ),
              ),
              SizedBox(height: 60.0),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: TextButton(
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            SimpleIcons.google,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'With Google',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      signInWithGoogle();
                      // Get.to(FirstPage());
                    },
                  )),
            ],
          ),
        ),
      ),
    ]));
  }
}
