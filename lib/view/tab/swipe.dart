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

  Widget _buildCard(Person person) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(() => UserDetailScreen(userID: person.uid));
              },
              child: Image.network(
                person.imageProfile.toString(),
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Icon(Icons.error);
                },
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
                    Get.to(() => UserDetailScreen(userID: person.uid));
                  },
                  child: Text(
                    person.name.toString(),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  person.age.toString(),
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  person.bio.toString(),
                  style: TextStyle(fontSize: 14.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => profileController
                          .toggleLikedStatus(person.uid.toString()),
                      child: Obx(() {
                        final liked =
                            profileController.isLiked(person.uid ?? '');
                        return Icon(
                          liked ? Icons.star : Icons.star_border,
                          color: liked ? Colors.yellow : Colors.pink,
                          size: 40,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => profileController
                          .toggleFavoritedStatus(person.uid.toString()),
                      child: Obx(() {
                        final favorited =
                            profileController.isFavorited(person.uid ?? '');
                        return Icon(
                          favorited ? Icons.favorite : Icons.favorite_border,
                          color: favorited ? Colors.red : Colors.pink,
                          size: 40,
                        );
                      }),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _controller.undo();
                      },
                      child: Icon(Icons.rotate_left),
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
                          ],
                        ),
                        Flexible(
                          child: CardSwiper(
                            isLoop: false,
                            controller: _controller,
                            cardsCount: profileList.length,
                            cardBuilder:
                                (context, index, realIndex, swipeIndex) {
                              final person = profileList[index];
                              return _buildCard(person);
                            },
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
