import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/view/tab/user_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool isFavoriteSentClicked = true;
  List<String> favoriteSentList = [];
  List<String> favoriteReceivedList = [];
  List favoritesList = [];
  getFavoriteListKeys() async {
    if (isFavoriteSentClicked) {
      var favoriteSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('favoriteSent')
          .get();

      for (int i = 0; i < favoriteSentDocument.docs.length; i++) {
        favoriteSentList.add(favoriteSentDocument.docs[i].id);
      }
      getKeyDataFromUsersCollection(favoriteSentList);
    } else {
      var favoriteReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('favoriteReceived')
          .get();
      for (int i = 0; i < favoriteReceivedDocument.docs.length; i++) {
        favoriteReceivedList.add(favoriteReceivedDocument.docs[i].id);
      }
      getKeyDataFromUsersCollection(favoriteReceivedList);
    }
  }

  getKeyDataFromUsersCollection(List<String> keysList) async {
    var alluserDocument =
        await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < alluserDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((alluserDocument.docs[i].data() as dynamic)["uid"]) ==
            keysList[k]) {
          favoritesList.add(alluserDocument.docs[i].data());
        }
      }
    }
    setState(() {
      favoritesList;
    });
  }

  @override
  void initState() {
    super.initState();
    getFavoriteListKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    favoriteReceivedList.clear();
                    favoriteReceivedList = [];
                    favoriteSentList.clear();
                    favoriteSentList = [];
                    favoritesList.clear();
                    favoritesList = [];
                    setState(() {
                      isFavoriteSentClicked = true;
                    });
                    getFavoriteListKeys();
                  },
                  child: Text(
                    "My Favorites",
                    style: TextStyle(
                        color:
                            isFavoriteSentClicked ? Colors.pink : Colors.black,
                        fontWeight: isFavoriteSentClicked
                            ? FontWeight.bold
                            : FontWeight.normal),
                  )),
              const Text(
                " | ",
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                  onPressed: () {
                    favoriteReceivedList.clear();
                    favoriteReceivedList = [];
                    favoriteSentList.clear();
                    favoriteSentList = [];
                    favoritesList.clear();
                    favoritesList = [];
                    setState(() {
                      isFavoriteSentClicked = false;
                    });
                    getFavoriteListKeys();
                  },
                  child: Text(
                    "I'm their Favorite",
                    style: TextStyle(
                        color:
                            isFavoriteSentClicked ? Colors.black : Colors.pink,
                        fontWeight: isFavoriteSentClicked
                            ? FontWeight.normal
                            : FontWeight.bold),
                  ))
            ],
          ),
        ),
        body: favoritesList.isEmpty
            ? const Center(
                child: Icon(
                  Icons.person_off_sharp,
                  color: Colors.black,
                  size: 60,
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(8),
                children: List.generate(favoritesList.length, (index) {
                  return GridTile(
                      child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Card(
                      color: Colors.blue.shade200,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(UserDetailScreen(
                            userID: favoritesList[index]["uid"],
                          ));
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                                image: NetworkImage(
                                    favoritesList[index]["imageProfile"]),
                                fit: BoxFit.cover),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Spacer(),
                                  ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16))),
                                      child: Text(
                                        '${favoritesList[index]['name']}${favoritesList[index]['age']}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      )),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ));
                }),
              ));
  }
}
