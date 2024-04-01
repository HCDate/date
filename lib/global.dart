import 'package:firebase_auth/firebase_auth.dart';

String currentUserID = FirebaseAuth.instance.currentUser!.uid;
String fcmServerToken =
    "key=AAAAmQs8YSM:APA91bEs344qRhwI_T056DlF6pUiOwhmjiwhsRWEXZP2e83YLI3BUkjxGWe-7k_FXokfMeUiUP2k1Z44UaoABDZ_mkeREjSCPu4NgOliVtU37ctcYyUaDpa52DgU8u3y73kDsQN3QpSg";
String? chosenAge;
String? chosenCountry;
String? chosenGender;
String avatar =
    "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=e535ba4b-b1e2-4f52-89bd-d97700e9324a";
