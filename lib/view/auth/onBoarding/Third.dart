import 'package:bilions_ui/bilions_ui.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:date/view/auth/onBoarding/Fourth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:get/get.dart';
import 'package:uic/checkbox_uic.dart';
import 'package:uic/step_indicator.dart';

import '../../../controller/auth_controller.dart';
import '../../../services/interest.dart';

import '../../../widgets/custom_text_field.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    String countryValue;
    String stateValue;
    String cityValue;
    bool? term;
    var authenticationController =
        AuthenticationController.authenticationController;
    List<Interest> availableInterests = [
      Interest(name: 'Photography', image: 'assets/images/camera.png'),
      Interest(name: 'Shopping', image: 'assets/images/weixin-market.png'),
      Interest(name: 'Cooking', image: 'assets/images/noodles.png'),
      Interest(name: 'Tennis', image: 'assets/images/tennis.png'),
      Interest(name: 'Run', image: 'assets/images/sport.png'),
      Interest(name: 'Swimming', image: 'assets/images/ripple.png'),
      Interest(name: 'Art', image: 'assets/images/platte.png'),
      Interest(name: 'Traveling', image: 'assets/images/outdoor.png'),
      Interest(name: 'Extreme', image: 'assets/images/parachute.png'),
      Interest(name: 'Drink', image: 'assets/images/goblet-full.png'),
      Interest(name: 'Music', image: 'assets/images/music.png'),
      Interest(name: 'Video games', image: 'assets/images/game-handle.png'),
      // Add
    ];

    // List<bool> selectedList =
    //     List.generate(availableInterests.length, (index) => false);
    // final _items = availableInterests
    //     .map((interest) => MultiSelectItem<Interest>(interest, interest.name))
    //     .toList();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            StepIndicator(
              selectedStepIndex: 3,
              totalSteps: 4,
              completedStep: Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
              incompleteStep: Icon(
                Icons.radio_button_unchecked,
                color: Theme.of(context).primaryColor,
              ),
              selectedStep: Icon(
                Icons.radio_button_checked,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SelectState(
              // style: TextStyle(color: Colors.red),
              onCountryChanged: (value) {
                setState(() {
                  countryValue = value;
                  authenticationController.countryController.text = value;
                });
              },
              onStateChanged: (value) {
                setState(() {
                  stateValue = value;
                  authenticationController.stateController.text = value;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  cityValue = value;
                  authenticationController.cityController.text = value;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'What you are looking for?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 60,
              child: MultiSelectContainer(
                  maxSelectableCount: 1,
                  highlightColor: Colors.pink,
                  showInListView: true,
                  listViewSettings: ListViewSettings(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => const SizedBox(
                            width: 10,
                          )),
                  items: [
                    MultiSelectCard(
                      value: 'marriage',
                      label: 'Marriage',
                    ),
                    MultiSelectCard(
                      value: 'relationShip',
                      label: 'RelationShip',
                    ),
                    MultiSelectCard(
                      value: 'friendShip',
                      label: 'FriendShip',
                    ),
                  ],
                  onChange: (allSelectedItems, selectedItem) {
                    print(selectedItem);
                    authenticationController.lookingForController.text =
                        selectedItem;
                  }),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              'What you are interested in?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 60,
              child: MultiSelectContainer(
                  highlightColor: Colors.pink,
                  showInListView: true,
                  listViewSettings: ListViewSettings(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (_, __) => const SizedBox(
                            width: 10,
                          )),
                  items: [
                    MultiSelectCard(
                      value: 'Photography',
                      label: 'Photography',
                    ),
                    MultiSelectCard(value: 'Tennis', label: 'Tennis'),
                    MultiSelectCard(value: 'Cooking', label: 'Cooking'),
                    MultiSelectCard(value: 'Shopping', label: 'Shopping'),
                    MultiSelectCard(value: 'Run', label: 'Run'),
                    MultiSelectCard(value: 'Swimming', label: 'Swimming'),
                    MultiSelectCard(value: 'Art', label: 'Art'),
                    MultiSelectCard(value: 'Traveling', label: 'Traveling'),
                    MultiSelectCard(value: 'Extreme', label: 'Extreme'),
                    MultiSelectCard(value: 'Drink', label: 'Drink'),
                    MultiSelectCard(value: 'Music', label: 'Music'),
                  ],
                  onChange: (allSelectedItems, selectedItem) {
                    print(allSelectedItems);
                    authenticationController.selectedInterests =
                        allSelectedItems;
                  }),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.bioController,
                labelText: "bio",
                iconData: Icons.person,
              ),
            ),
            CheckboxUic(
              initialValue: false,
              title: 'Term And Pervicy',
              description: 'Accept term and pravicy',
              descriptionUnchecked:
                  'You need to accept term and privecy to continue'
                  '',
              onChanged: (value) {
                term = value;
              },
            ),
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
