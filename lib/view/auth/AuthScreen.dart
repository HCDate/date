import 'package:date/view/auth/onBoarding/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'login/login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                _buildTextSection(),
                const SizedBox(height: 50),
                _buildButtonSection(
                  context: context,
                  label: 'Create Account',
                  onPressed: () => Get.to(const SignUp()),
                  color: Colors.pink,
                ),
                const SizedBox(height: 50),
                _buildButtonSection(
                  context: context,
                  label: 'Sign In',
                  onPressed: () => Get.to(const LoginScreen()),
                  color: Colors.white,
                  textColor: Colors.black,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
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

  Widget _buildButtonSection({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
