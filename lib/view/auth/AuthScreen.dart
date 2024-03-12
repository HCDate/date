import 'package:date/view/auth/onBoarding/First.dart';
import 'package:date/view/auth/onBoarding/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import 'login/login_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
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
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: TextButton(
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Get.to(const LoginScreen());
                    },
                  )),
              const SizedBox(
                height: 50,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.4),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12))),
                  child: TextButton(
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Get.to(const SignUp());
                    },
                  )),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ));
  }
}
