import 'dart:io';
import 'dart:ui';

import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/controller/auth_controller.dart';
import 'package:date/view/auth/onBoarding/Second.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:text_area/text_area.dart';
import 'package:uic/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../widgets/custom_text_field.dart';

class FirstPage extends StatefulWidget {
  FirstPage();

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var reasonValidation = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var authenticationController =
      AuthenticationController.authenticationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authenticationController.bioController.addListener(() {
      setState(() {
        reasonValidation = authenticationController.bioController.text.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              StepIndicator(
                selectedStepIndex: 1,
                totalSteps: 4,
                completedStep: Icon(
                  Icons.check_circle,
                  color: Colors.pink,
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
                height: 100,
              ),
              authenticationController.imageFile == null
                  ? Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: AssetImage(
                                  'assets/images/profile_avatar.jpg'))),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: FileImage(File(
                                  authenticationController.imageFile!.path)))),
                    ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        await authenticationController
                            .pickImageFileFromGallery();
                        setState(() {
                          authenticationController.imageFile;
                        });
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        color: Colors.pink,
                        size: 30,
                      )),
                  SizedBox(
                    width: 15,
                  ),
                  IconButton(
                      onPressed: () async {
                        await authenticationController.captureImageFromPhone();
                        setState(() {
                          authenticationController.imageFile;
                        });
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.pink,
                        size: 30,
                      ))
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: CustomTextField(
                  isObsecure: false,
                  editingController: authenticationController.nameController,
                  labelText: "name",
                  iconData: Icons.person,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 150,
                child: Form(
                  key: formKey,
                  child: TextArea(
                    borderRadius: 10,
                    borderColor: const Color(0xFFCFD6FF),
                    textEditingController:
                        authenticationController.bioController,
                    validation: reasonValidation,
                    errorText: 'Please type a short bio!',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 150,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: TextButton(
                    child: Text(
                      'Continue',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      if (authenticationController.nameController.text
                              .trim()
                              .isEmpty ||
                          authenticationController.bioController.text
                              .trim()
                              .isEmpty) {
                        alert(
                          context,
                          'Fill Value',
                          'Full Name or bio field field must be Fielded',
                          variant: Variant.warning,
                        );
                      } else {
                        Get.to(() => SecondPage());
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
