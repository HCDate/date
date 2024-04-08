import 'package:date/api/notification.dart';
import 'package:date/controller/auth_controller.dart';
import 'package:date/view/auth/AuthScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyAgjLLHu_kj1pson6Mxy2VI45bVCy8_df4",
              appId: "1:657318502691:android:933f51e85f8b94f8f36c96",
              messagingSenderId: "657318502691",
              projectId: "habeshac-7856b",
              storageBucket: "habeshac-7856b.appspot.com"))
      .then((value) {
    Get.put(AuthenticationController());
  });

  // FirebaseApi().initNotification();
  // await PushNotificationSystems().initNotification();
  await FirebaseApi().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Habesha Dating',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(240, 98, 146, 1)),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
