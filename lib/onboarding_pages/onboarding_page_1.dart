import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class OnboardingPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowGrey,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            //onboarding image 1
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: yellowGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('lib/images/onboardingimage2.png'),
              ),
            ),

            const SizedBox(height: 40),

            //Heading 1
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Column(
                    children: [
                      Text(
                        "Expand your reach",
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 24,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            //Description 1
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 43.00,
                  ),
                  child: Column(
                    children: [
                      Text(
                          "Put your platform out there, and\nlet us do the promoting for you.\nReaching your target audience\nhas never been this easy.",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 16,
                          )),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
