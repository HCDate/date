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
        Get.to(FirstPage());

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
        'User Info',
        'No User Found',
        variant: Variant.warning,
      );
    }
   
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Positioned.fill(
          top: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/splash.jpg'),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.4),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: TextButton(
                      child: Text(
                        'Phone Number',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      onPressed: () {
                        Get.to(PhoneVerification());
                      },
                    )),
                SizedBox(
                  height: 50,
                ),
                
                Container(
                    width: MediaQuery.of(context).size.width - 30,
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                      onPressed: () {
                        signInWithGoogle();
                        // Get.to(FirstPage());
                      },
                    )),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          )),
    );
  }
}
