// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MatchFilter extends StatefulWidget {
  const MatchFilter({super.key});

  @override
  _MatchFilterState createState() => _MatchFilterState();
}

class _MatchFilterState extends State<MatchFilter> {
  int minAge = 0;
  int maxAge = 0;
  String location = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Dismiss the modal on tap outside
      },
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.w800
                      ),
                    ),
                    SizedBox(height: 16,),
                    TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: "Age",
                        hintText: "This age or above",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          minAge = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: "Location",
                        hintText: "Enter location",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          location = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Implement filter logic based on minAge, maxAge, and location
                        print(
                            "Filter applied with minAge: $minAge, maxAge: $maxAge, location: $location");
                      },
                      child: Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}