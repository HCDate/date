import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? uid;
  String? imageProfile;
  String? name;
  String? email;
  String? password;
  int? age;
  String? gender;
  String? phoneNo;
  String? city;
  String? country;
  String? state;
  int? publishedDateTime;
  String? profession;
  String? religion;
  List<String>? interests;
  String? lookingFor;
  String? bio;
  bool? online;
  List<String>? blocklist;
  bool? paymentStatus;
  Person(
      {this.uid,
      this.imageProfile,
      this.age,
      this.gender,
      this.city,
      this.country,
      this.state,
      this.name,
      this.phoneNo,
      this.profession,
      this.publishedDateTime,
      this.religion,
      this.email,
      this.password,
      this.interests,
      this.lookingFor,
      this.bio,
      this.online,
      this.blocklist,
      this.paymentStatus});
  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;
    List<dynamic>? interestsData = dataSnapshot['interests'];
    List<dynamic>? blocklistsData = dataSnapshot['blocklist'];
    // Use null-aware spread operator to convert List<dynamic>? to List<String>?
    List<String>? interests = interestsData?.cast<String>();
    List<String>? blocklists = blocklistsData?.cast<String>();
    return Person(
        uid: dataSnapshot['uid'],
        name: dataSnapshot['name'],
        age: dataSnapshot['age'],
        email: dataSnapshot['email'],
        password: dataSnapshot['password'],
        gender: dataSnapshot['gender'],
        imageProfile: dataSnapshot['imageProfile'],
        city: dataSnapshot['city'],
        country: dataSnapshot['country'],
        state: dataSnapshot['state'],
        lookingFor: dataSnapshot['lookingFor'],
        phoneNo: dataSnapshot['phoneNo'],
        publishedDateTime: dataSnapshot['publishedDateTime'],
        religion: dataSnapshot['religion'],
        interests: interests,
        bio: dataSnapshot['bio'],
        online: dataSnapshot['online'],
        blocklist: blocklists,
        paymentStatus: dataSnapshot['paymentStatus']);
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "imageProfile": imageProfile,
        "name": name,
        "age": age,
        "city": city,
        "country": country,
        "email": email,
        "gender": gender,
        "phoneNo": phoneNo,
        "profession": profession,
        "publishedDateTime": publishedDateTime,
        "religion": religion,
        "interests": interests,
        "lookingFor": lookingFor,
        "bio": bio,
        "online": online,
        "blocklist": blocklist,
        "paymentStatus": paymentStatus
      };
}
