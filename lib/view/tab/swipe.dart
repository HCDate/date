import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image package
import 'package:get/get.dart';
import '../../controller/profile_controller.dart';
import '../../global.dart';
import '../../models/person.dart';
import '../../view/tab/user_detail.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({Key? key}) : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final ProfileController profileController = ProfileController();
  final CardSwiperController _controller = CardSwiperController();
  String senderName = "";
  bool favorite = false;
  String receiverToken = '';
  bool _swipeFinished = false;

  @override
  void initState() {
    super.initState();
    profileController.getResults();
  }

  applyFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Matching Filter"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('I am looking for a'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      items: ['Male', 'Female'].map((value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          chosenGender = value;
                        });
                      },
                      hint: Text("select gender"),
                      value: chosenGender,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("who's age equal or above"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      items: ['20', '30', '40', '45'].map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          chosenAge = value;
                        });
                      },
                      hint: Text("select age"),
                      value: chosenAge,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      profileController.getResults();

                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            );
          });
        });
  }

  readCurrentUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .get()
        .then((dataSnapshot) {
      setState(() {
        senderName = dataSnapshot.data()!["name"].toString();
        print(senderName);
      });
    });
  }

  retriveReceiver(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((dataSnapshot) {
      setState(() {
        receiverToken = dataSnapshot.data()!['userDeviceToken'].toString();
      });
    });
  }

  List<Widget> _buildCards(List<Person> profileList) {
    List<Widget> cards = [];
    for (final person in profileList) {
      cards.add(_buildCard(person));
    }
    return cards;
  }

  Widget _buildCard(Person person) {
    return FutureBuilder(
        future: Future.wait([
          profileController.hasLiked(person.uid.toString()),
          profileController.hasFavorited(person.uid.toString()),
        ]),
        builder: (context, AsyncSnapshot<List<bool>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            bool liked = snapshot.data![0];
            bool favorited = snapshot.data![1];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => UserDetailScreen(userID: person.uid));
                      },
                      child: CachedNetworkImage(
                        imageUrl: person.imageProfile.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                            onPressed: () {
                              Get.to(
                                  () => UserDetailScreen(userID: person.uid));
                            },
                            child: Text(person.name.toString(),
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold))),
                        Text(person.age.toString(),
                            style: TextStyle(fontSize: 16.0)),
                        Text(
                          person.bio.toString(),
                          style: const TextStyle(fontSize: 14.0),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Align buttons to the right
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  // Call like method from ProfileController
                                  await retriveReceiver(person.uid.toString());
                                  profileController.likeSentAndFavoriteReceived(
                                      person.uid.toString(),
                                      senderName,
                                      receiverToken);
                                },
                                child: Icon(
                                  liked ? Icons.star : Icons.star_border,
                                  color: liked ? Colors.yellow : Colors.pink,
                                  size: 40,
                                )),
                            const SizedBox(width: 8),
                            ElevatedButton(
                                onPressed: () async {
                                  await retriveReceiver(person.uid.toString());
                                  profileController
                                      .favoriteSentAndFavoriteReceived(
                                          person.uid.toString(),
                                          senderName,
                                          receiverToken);
                                },
                                child: Icon(
                                  favorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favorited ? Colors.red : Colors.pink,
                                  size: 40,
                                )),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Call undo method from CardSwiperController
                                _controller.undo();
                              },
                              child: const Icon(Icons.rotate_left),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget _cardBuilder(
      BuildContext context, int index, int realIndex, int swipeIndex) {
    final profileList = profileController.allUsersProfileList;
    final person = profileList[index];
    return _buildCard(person);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final profileList = profileController.allUsersProfileList;
          return profileList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'You have no get Maches for now!',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 24, top: 8),
                              child: Text(
                                "Habesha\nChristian\nMingle",
                                style:
                                    TextStyle(color: Colors.pink, fontSize: 17),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: 0, left: 10),
                                child: IconButton(
                                    onPressed: () {
                                      applyFilter();
                                    },
                                    icon: Icon(
                                      Icons.filter_list,
                                      size: 30,
                                      color: Colors.pink,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: CardSwiper(
                            isLoop: false,
                            controller: _controller,
                            cardsCount: profileList.length,
                            cardBuilder: _cardBuilder,
                            numberOfCardsDisplayed: 1,
                            onSwipe: (int previousIndex, int? currentIndex,
                                CardSwiperDirection direction) {
                              debugPrint(
                                  'Card swiped. Previous index: $previousIndex, Current index: $currentIndex, Direction: $direction');
                              return true;
                            },
                            onUndo: (int? previousIndex, int currentIndex,
                                CardSwiperDirection direction) {
                              debugPrint(
                                  'Undo swipe. Previous index: $previousIndex, Current index: $currentIndex, Direction: $direction');
                              return true;
                            },
                            onEnd: () {
                              setState(() {
                                _swipeFinished = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_swipeFinished)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 300,
                            ),
                            const Center(
                              child: Text(
                                "Your Matching Over",
                                style: TextStyle(color: Colors.pink),
                              ),
                            ),
                            const Center(
                                child:
                                    Text('Enjoy With already existed match')),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _controller.undo();
                                setState(() {
                                  _swipeFinished = false;
                                });
                              },
                              child: const Icon(
                                Icons.rotate_left,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
        }),
      ),
    );
  }
}
