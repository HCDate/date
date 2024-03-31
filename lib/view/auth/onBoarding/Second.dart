import 'dart:io';

import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/controller/auth_controller.dart';
import 'package:date/view/auth/onBoarding/Third.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:gender_picker/source/gender_picker.dart';
import 'package:get/get.dart';
import 'package:uic/step_indicator.dart';
import 'package:date_cupertino_bottom_sheet_picker/date_cupertino_bottom_sheet_picker.dart';
import 'package:uic/widgets/action_button.dart';
import '../../../widgets/custom_text_field.dart';

class SecondPage extends StatefulWidget {
  SecondPage();

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  var authenticationController =
      AuthenticationController.authenticationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticationController.genderController.text = "male";
    authenticationController.ageController.clear();
    authenticationController.religionController.clear();
    authenticationController.professionController.clear();
  }

  FocusNode focusNode = FocusNode();
  @override
  int age = 0;

  DateTime? selectedDate = DateTime(2001, 12, 5);
  calculateAge() {
    if (selectedDate != null) {
      DateTime today = DateTime.now();
      int years = today.year - selectedDate!.year;
      if (today.month < selectedDate!.month ||
          (today.month == selectedDate!.month &&
              today.day < selectedDate!.day)) {
        years--;
      }

      authenticationController.ageController.text = years.toString();

      setState(() {
        age = years;
      });
    } else {
      setState(() {
        age = 0;
      });
    }
  }

  Widget build(BuildContext context) {
    String selectedGender = 'Select Gender';

    ValueNotifier<String> genderNotifier =
        ValueNotifier<String>('Select Gender');

    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 60,
            ),
            StepIndicator(
              selectedStepIndex: 2,
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
              height: 30,
            ),
            getWidget(true, false),
            const SizedBox(
              height: 35,
            ),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.9,
              child: DateCupertinoBottomSheetPicker(
                width: 1.0,
                firstDate: DateTime(1990),
                lastDate: DateTime(2050),
                selectedDate: selectedDate,
                minAge: 18,
                hintText: 'birth date',
                onChanged: (dateTime) {
                  selectedDate = dateTime;
                  calculateAge();
                },
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.religionController,
                labelText: "Religion",
                iconData: Icons.church,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController:
                    authenticationController.professionController,
                labelText: "Profession",
                iconData: Icons.work,
              ),
            ),
            const SizedBox(
              height: 50,
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
                    Future.delayed(Duration(seconds: 10));
                    calculateAge();
                    if (authenticationController.genderController.text
                            .trim()
                            .isEmpty ||
                        authenticationController.ageController.text
                            .trim()
                            .isEmpty ||
                        authenticationController.religionController.text
                            .trim()
                            .isEmpty ||
                        authenticationController.professionController.text
                            .trim()
                            .isEmpty) {
                      alert(
                        context,
                        'Fill Values',
                        'All value must be Field',
                        variant: Variant.warning,
                      );
                    } else if (age <= 18) {
                      alert(
                        context,
                        'Fill Values',
                        'Your age must greater than 18',
                        variant: Variant.warning,
                      );
                    } else {
                      Get.to(const ThirdPage());
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
    ));
  }

  Widget getWidget(bool showOtherGender, bool alignVertical) {
    var authenticationController =
        AuthenticationController.authenticationController;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: GenderPickerWithImage(
        showOtherGender: showOtherGender,
        verticalAlignedText: alignVertical,

        // to show what's selected on app opens, but by default it's Male
        selectedGender: Gender.Male,
        selectedGenderTextStyle: const TextStyle(
            color: Color(0xFF8b32a8), fontWeight: FontWeight.bold),
        unSelectedGenderTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        onChanged: (Gender? gender) {
          if (gender == Gender.Female) {
            authenticationController.genderController.text = 'female';
          } else if (gender == Gender.Male) {
            authenticationController.genderController.text = 'male';
          }
        },
        //Alignment between icons
        equallyAligned: true,

        animationDuration: Duration(milliseconds: 300),
        isCircular: true,
        // default : true,
        opacityOfGradient: 0.4,
        padding: const EdgeInsets.all(3),
        size: 50, //default : 40
      ),
    );
  }
}
