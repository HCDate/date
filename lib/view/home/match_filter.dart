import 'package:date/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchFilter extends StatefulWidget {
  const MatchFilter({super.key});

  @override
  State<MatchFilter> createState() => _MatchFilterState();
}

class _MatchFilterState extends State<MatchFilter> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.navigate_before_outlined,
              size: 36,
            ),
          ),
        ),
        body: Center(
          child: CustomTextField(
            isObsecure: false,
            labelText: "name",
            iconData: Icons.person,
          ),
        ),
      ),
    );
  }
}