import 'package:bilions_ui/bilions_ui.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:date/view/auth/onBoarding/Fourth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:get/get.dart';
import 'package:text_area/text_area.dart';
import 'package:uic/step_indicator.dart';

import '../../../controller/auth_controller.dart';
import '../../../services/interest.dart';
import 'package:uic/widgets/action_button.dart';

import '../../../widgets/custom_text_field.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  var authenticationController =
      AuthenticationController.authenticationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String countryValue;
    String stateValue;
    String cityValue;
    bool? term;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              const SizedBox(
                height: 20,
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
              const SizedBox(
                height: 30,
              ),
              const Text(
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
              const SizedBox(
                height: 25,
              ),
              const Text(
                'What you are interested in?',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
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
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 150,
                  height: 50,
                  decoration: const BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: ActionButton(
                    action: () async {
                      Future.delayed(Duration(seconds: 5));
                      if (authenticationController.selectedInterests != null &&
                          authenticationController.bioController.text
                              .trim()
                              .isNotEmpty &&
                          authenticationController.lookingForController.text
                              .trim()
                              .isNotEmpty) {
                        Get.to(FourthPage());
                      } else {
                        alert(
                          context,
                          'Fill Values',
                          'All value must be Field',
                          variant: Variant.warning,
                        );
                      }
                      // Get.to(ThirdPage());
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
