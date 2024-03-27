import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/view/auth/onBoarding/First.dart';
import 'package:date/view/auth/onBoarding/Fourth.dart';
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
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
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
          Get.to(FirstPage());
        }

        print(userDetails.uid);
      } on FirebaseAuthException catch (e) {}
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
                    onPressed: () => signInWithGoogle(),
                    color: Colors.white,
                    textColor: Colors.black,
                    Icon: const Icon(
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
                    onPressed: () => Get.to(PhoneVerification()),
                    color: Colors.pink,
                    textColor: Colors.white,
                    Icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ))
      ],
    );
  }

  Widget _buildTextSection() {
    return GestureDetector(
      child: const Center(
        child: Text(
          "habesha\nchristian\nmingle",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            decoration: TextDecoration.none,
          ),
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
      Icon? Icon}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon!,
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
