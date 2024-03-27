import 'dart:convert';
import 'dart:io';

import 'package:async_button/async_button.dart';
import 'package:bilions_ui/bilions_ui.dart';
import 'package:date/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:uic/checkbox_uic.dart';
import 'package:uic/step_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:uic/widgets/action_button.dart';

import '../../../global.dart';
import 'Third.dart';

class FourthPage extends StatefulWidget {
  FourthPage();

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  bool? term;
  bool? paymentStatus = false;
  Map<String, dynamic>? paymentIntent;
  var authenticationController =
      AuthenticationController.authenticationController;
  void makePayment() async {
    try {
      print("make payment");
      paymentIntent = await createPaymentIntent();
      setState(() {
        paymentStatus = true;
      });
      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "US", currencyCode: "US", testEnv: true);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!["client_secret"],
              style: ThemeMode.light,
              merchantDisplayName: "Beki",
              googlePay: gpay));
      displayPaymentSheet();
      setState(() {
        paymentStatus = true;
      });
    } catch (e) {
      setState(() {
        paymentStatus = true;
      });
      throw Exception(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": calculateAmount('20'),
        "currency": "usd"
      };
      http.Response response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51OFYhgD9rzaCJql7s4IMR4aqt0iZZZqXq8CrrM5xt5m0fKuJCtxQ7phaIoLBkxfVim4XwIAqHbhnWMvPWhWseMCL00oHD6rcGM",
            "Content-Type": "application/x-www-form-urlencoded"
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  submit() async {
    if (term == true && paymentStatus == true) {
      authenticationController.createNewUser(
          authenticationController.imageProfileController.text.trim().isEmpty
              ? avatar
              : authenticationController.imageProfileController.text.trim(),
          authenticationController.ageController.text.trim(),
          authenticationController.nameController.text.trim().toUpperCase(),
          authenticationController.emailController.text.trim(),
          authenticationController.genderController.text.toLowerCase(),
          authenticationController.phoneController.text.trim(),
          authenticationController.cityController.text.trim().toUpperCase(),
          authenticationController.countryController.text.trim().toUpperCase(),
          authenticationController.stateController.text.trim().toUpperCase(),
          authenticationController.professionController.text.trim(),
          authenticationController.religionController.text.trim(),
          authenticationController.selectedInterests,
          authenticationController.lookingForController.text
              .trim()
              .toUpperCase(),
          authenticationController.bioController.text.trim(),
          paymentStatus);
    } else {
      alert(
        context,
        'Term And Privacy',
        'To register you need to accept term and privacy',
        variant: Variant.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncBtnStatesController btnStateController = AsyncBtnStatesController();
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            StepIndicator(
              selectedStepIndex: 4,
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
            const Text(
              "Payment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "Choose Payment Method",
              maxLines: 2,
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                makePayment();
              },
              child: const Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.credit_card),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Debit or Credit Card",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => UsePaypal(
                        sandboxMode: true,
                        clientId:
                            "AS4Y8vl9WGXCB3VNinxQ9zyccNwN2u1Wj_anaR7mPK1Kvys-CmLdi5Azv5fVKGGy_UM08bSMm-kly7zI",
                        secretKey:
                            "EGp3K6HurDSpXM1UCS-1ariWtGH1oqPPcSPqJ6yFx-tzKRIuNKgLMW_DJ3KsOel3FUZZ8l1SrW382Zmf",
                        returnURL: "https://samplesite.com/return",
                        cancelURL: "https://samplesite.com/cancel",
                        transactions: const [
                          {
                            "amount": {
                              "total": '20',
                              "currency": "USD",
                              "details": {
                                "subtotal": '10.12',
                                "shipping": '0',
                                "shipping_discount": 0
                              }
                            },
                            "description": "The payment for sign up.",
                            "item_list": {
                              "items": [
                                {
                                  "name": "registration",
                                  "quantity": 1,
                                  "price": '20',
                                  "currency": "USD"
                                }
                              ],
                            }
                          }
                        ],
                        note: "Contact us for any questions on your order.",
                        onSuccess: (Map params) async {
                          print("onSuccess: $params");
                          setState(() {
                            paymentStatus = true;
                          });
                        },
                        onError: (error) {
                          print("onError: $error");
                        },
                        onCancel: (params) {
                          print('cancelled: $params');
                          setState(() {
                            paymentStatus = true;
                          });
                        }),
                  ),
                );
              },
              child: const Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.paypal),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "PayPal",
                    style: TextStyle(fontSize: 18),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            CheckboxUic(
              initialValue: false,
              title: 'Term And Pervicy',
              description: 'Accepted term and pravicy',
              descriptionUnchecked:
                  'You need to accept term and privecy to continue'
                  '',
              onChanged: (value) {
                term = value;
              },
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
                child: Container(
              width: MediaQuery.of(context).size.width - 150,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: ActionButton(
                action: () async {
                  await submit();
                },
                child: Text("Submit"),
              ),
            )
                //  Container(
                //     width: MediaQuery.of(context).size.width - 150,
                //     height: 50,
                //     decoration: const BoxDecoration(
                //         color: Colors.pink,
                //         borderRadius: BorderRadius.all(Radius.circular(12))),
                //     child: TextButton(
                //       child: const Text(
                //         'Submit',
                //         style: TextStyle(color: Colors.white, fontSize: 20),
                //       ),
                //       onPressed: () {
                //         if (term == true && paymentStatus == true) {
                //           if (authenticationController.selectedInterests != null &&
                //               authenticationController.bioController.text
                //                   .trim()
                //                   .isNotEmpty) {
                //             authenticationController.createNewUser(
                //                 authenticationController.profileImage==null??avatar:authenticationController.profileImage,
                //                 authenticationController.ageController.text.trim(),
                //                 authenticationController.nameController.text
                //                     .trim()
                //                     .toUpperCase(),
                //                 authenticationController.emailController.text
                //                     .trim(),
                //                 authenticationController.passwordController.text
                //                     .trim(),
                //                 authenticationController.genderController.text
                //                     .toLowerCase(),
                //                 authenticationController.phoneController.text
                //                     .trim(),
                //                 authenticationController.cityController.text
                //                     .trim()
                //                     .toUpperCase(),
                //                 authenticationController.countryController.text
                //                     .trim()
                //                     .toUpperCase(),
                //                 authenticationController.stateController.text
                //                     .trim()
                //                     .toUpperCase(),
                //                 authenticationController.professionController.text
                //                     .trim(),
                //                 authenticationController.religionController.text
                //                     .trim(),
                //                 authenticationController.selectedInterests,
                //                 authenticationController.lookingForController.text
                //                     .trim()
                //                     .toUpperCase(),
                //                 authenticationController.bioController.text.trim(),
                //                 paymentStatus);
                //           } else {
                //             // Get.to(ThirdPage());
                //           }
                //         } else {
                //           alert(
                //             context,
                //             'Term And Privacy',
                //             'To register you need to accept term and privacy',
                //             variant: Variant.danger,
                //           );
                //         }
                //       },
                //     )),
                ),
          ],
        ),
      ),
    ));
  }
}
