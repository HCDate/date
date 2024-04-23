import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/view/auth/onBoarding/First.dart';
import 'package:date/view/auth/onBoarding/PhoneVerification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../controller/auth_controller.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var authenticationController =
      AuthenticationController.authenticationController;
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final User userDetails =
            (await FirebaseAuth.instance.signInWithCredential(credential))
                .user!;
        final bool isUserRegistered =
            await authenticationController.isRegisteredUser(userDetails.uid);
        if (isUserRegistered) {
          await FirebaseAuth.instance.signOut();
          await googleSignIn.signOut();
        } else {
          authenticationController.nameController.text =
              userDetails.displayName ?? '';
          authenticationController.emailController.text =
              userDetails.email ?? '';
          // authenticationController.profileImage.toString()=userDetails.photoURL;
          Get.to(const FirstPage());
        }
      } on FirebaseAuthException {
        return;
      }
    } else {
      alert(
        // ignore: use_build_context_synchronously
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
  bool _isLoadingGoogle = false;
  bool _isLoadingPhone = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            top: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/splash.jpg'),
                      fit: BoxFit.cover)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildTextSection(),
                  const SizedBox(
                    height: 50,
                  ),
                  _buildButtonSection(
                    context: context,
                    label: "Sign Up With Google",
                    onPressed: () => _handleGoogleSignup(context),
                    color: Colors.white,
                    textColor: Colors.black,
                    icon: _isLoadingGoogle
                        ? const CircularProgressIndicator()
                        : const Icon(
                            SimpleIcons.google,
                            color: Colors.green,
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildButtonSection(
                    context: context,
                    label: "Sign Up with Phone Number",
                    onPressed: () => _handlePhoneSignup(context),
                    color: Colors.pink,
                    textColor: Colors.white,
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ))
      ],
    );
  }
  
  // Handle Google Sign Up with loading indicator
  _handleGoogleSignup(BuildContext context) async {
    setState(() {
      _isLoadingGoogle = true; // Set loading flag to true
    });
    await signInWithGoogle();
    setState(() {
      _isLoadingGoogle = false; // Set loading flag to false after completion
    });
  }

  // Handle Phone Sign Up with loading indicator (assuming Get.to opens PhoneVerification)
  _handlePhoneSignup(BuildContext context) async {
    setState(() {
      _isLoadingPhone = true; // Set loading flag to true
    });
    await Get.to(const PhoneVerification());
    setState(() {
      _isLoadingPhone = false; // Set loading flag to false after completion
    });
  }

  Widget _buildTextSection() {
    return GestureDetector(
      child: const Center(
        child: Image(
          image: AssetImage('assets/images/logo.png'),
        ),
      ),
    );
  }

  Widget _buildButtonSection(
      {required BuildContext context,
      required String label,
      required VoidCallback onPressed,
      required Color color,
      Color? textColor,
      required Widget icon}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
