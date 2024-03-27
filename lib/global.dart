import 'package:firebase_auth/firebase_auth.dart';

String currentUserID = FirebaseAuth.instance.currentUser!.uid;
String fcmServerToken =
    "key=AAAAwe9tmkg:APA91bHkAQrgwpx7AY7eZU4u0_aY1txBu801o7EYDO3SiPd-A1k60L1sauLgQpMklj06_ABPdBGPrWjr5nx3spAQV1ixNwBAPEnF3lzBepF4srM4PPk5qaJMabE_ZB5uTt5RaxSloVeZ";
String? chosenAge;
String? chosenCountry;
String? chosenGender;
String avatar =
    "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=e535ba4b-b1e2-4f52-89bd-d97700e9324a";
