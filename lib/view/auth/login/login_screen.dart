import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/view/auth/login/PhoneLogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_icons/simple_icons.dart';

import '../../../controller/auth_controller.dart';

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
  bool showProgressBar = false;
  var controllerAuth = Get.put(AuthenticationController());
  var authenticationController =
      AuthenticationController.authenticationController;
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
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
        if (!isUserRegistered) {
          await googleSignIn.signOut();
          await FirebaseAuth.instance.signOut();
          alert(
            // ignore: use_build_context_synchronously
            context,
            'User Not found',
            'User is not registered',
            variant: Variant.warning,
          );
        }

        // authenticationController.profileImage.toString()=userDetails.photoURL;
        // Get.to(FirstPage());
      } on FirebaseAuthException catch (e) {
        alert(
          // ignore: use_build_context_synchronously
          context,
          'Login Error',
          e.toString(),
          variant: Variant.warning,
        );
      }
    } else {
      alert(
        // ignore: use_build_context_synchronously
        context,
        'User Not found',
        'user not found',
        variant: Variant.warning,
      );
    }
  }

  bool _isLoadingGoogle = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
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
                label: "Sign In With Google",
                onPressed: () => _handleGoogleSignin(context),
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
                label: "Sign In  Phone Number",
                onPressed: () => Get.to(const PhoneLogin()),
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
 
  // Handle Google Sign Up with loading indicator
  _handleGoogleSignin(BuildContext context) async {
    setState(() {
      _isLoadingGoogle = true; // Set loading flag to true
    });
    await signInWithGoogle();
    setState(() {
      _isLoadingGoogle = false; // Set loading flag to false after completion
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
}
