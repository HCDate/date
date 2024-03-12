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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: person.imageProfile.toString(),
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.name.toString(),
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                Text(person.age.toString(), style: TextStyle(fontSize: 16.0)),
                Text(
                  person.bio.toString(),
                  style: TextStyle(fontSize: 14.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Align buttons to the right
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          // Call like method from ProfileController
                          await retriveReceiver(person.uid.toString());
                          profileController.likeSentAndFavoriteReceived(
                              person.uid.toString(), senderName, receiverToken);
                        },
                        child: const Icon(
                          Icons.star,
                          color: Colors.pink,
                          size: 40,
                        )),
                    SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: () async {
                          await retriveReceiver(person.uid.toString());
                          profileController.favoriteSentAndFavoriteReceived(
                              person.uid.toString(), senderName, receiverToken);
                        },
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.pink,
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

  Widget _cardBuilder(
      BuildContext context, int index, int realIndex, int swipeIndex) {
    final profileList = profileController.allUsersProfileList;
    final person = profileList[index];
    return _buildCard(person);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Habesha",
                  style: TextStyle(color: Colors.pink, fontSize: 17),
                ),
                SizedBox(
                  width: 4,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                ),
                Text(
                  "dating",
                  style: TextStyle(color: Colors.pink, fontSize: 17),
                ),
              ],
            ),
          ],
        ),
        actions: [],
      ),
      body: SafeArea(
        child: Obx(() {
          final profileList = profileController.allUsersProfileList;
          return profileList.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.pink,
                ))
              : Stack(
                  children: [
                    Column(
                      children: [
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
                            SizedBox(
                              height: 300,
                            ),
                            Center(
                              child: Text(
                                "Your Matching Over",
                                style: TextStyle(color: Colors.pink),
                              ),
                            ),
                            Center(
                                child: Text('Enjoy With already existed match'))
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
