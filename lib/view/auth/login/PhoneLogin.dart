import 'package:bilions_ui/bilions_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_number_field/flutter_phone_number_field.dart';

import '../../../controller/auth_controller.dart';

class PhoneLogin extends StatefulWidget {
  const PhoneLogin({super.key});

  @override
  State<PhoneLogin> createState() => _PhoneLoginState();
}

class _PhoneLoginState extends State<PhoneLogin> {
  FocusNode focusNode = FocusNode();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = "";
  @override
  Widget build(BuildContext context) {
    var authenticationController =
        AuthenticationController.authenticationController;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            const Text(
              'Sign In with phone number',
              style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 70,
              width: MediaQuery.of(context).size.width * 0.9,
              child: FlutterPhoneNumberField(
                focusNode: focusNode,
                initialCountryCode: "ET",
                pickerDialogStyle: PickerDialogStyle(
                  countryFlagStyle: const TextStyle(fontSize: 17),
                ),
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                languageCode: "en",
                onChanged: (phone) {
                  if (phone.completeNumber.length == 13) {
                    setState(() {
                      phoneNumber = phone.completeNumber;
                    });
                  }
                },
                onCountryChanged: (country) {
                  if (kDebugMode) {
                    print('Country changed to: ${country.name}');
                  }
                },
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Center(
              child: Container(
                  width: MediaQuery.of(context).size.width - 150,
                  height: 50,
                  decoration: const BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: TextButton(
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      if (phoneNumber.length == 13) {
                        // calculateAge();
                        authenticationController.sentOtp(
                            phone: phoneNumber,
                            errorStep: () => alert(
                                  context,
                                  'Title here',
                                  'Description here',
                                  variant: Variant.warning,
                                ),
                            nextStep: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: const Text("OTP verification"),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text("Enter 6 digit"),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            Form(
                                              key: _formKey,
                                              child: TextFormField(
                                                controller: _otpController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                decoration: InputDecoration(
                                                    labelText:
                                                        'Enter you phone number',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(32))),
                                                validator: (value) {
                                                  if (value!.length != 6)
                                                    return "Invalid";
                                                  return null;
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  final String res =
                                                      authenticationController
                                                          .loginOtp(
                                                              otp: _otpController
                                                                  .text) as String;
                                                  if (res == "NotRegistered") {
                                                    alert(
                                                      context,
                                                      'Error',
                                                      'User Not Registered',
                                                      variant: Variant.danger,
                                                    );
                                                  }
                                                }
                                              },
                                              child: const Text("Submit"))
                                        ],
                                      ));
                            });
                      } else {}
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
