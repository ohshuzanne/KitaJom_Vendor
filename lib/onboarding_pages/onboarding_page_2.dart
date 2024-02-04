import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class OnboardingPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: skyBlue,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            //onboarding image 1
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: skyBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('lib/images/onboardingimage3.png'),
              ),
            ),

            const SizedBox(height: 30),

            //Heading 1
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Column(
                    children: [
                      Text(
                        "Connect better",
                        style: TextStyle(
                          color: Colors.white,
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
                          "Simply put, we allow you to\ncommunicate better, faster, and\nclearer with your customers.\nHost showings through video calls\nand reply quickly with our built-in\nchat functions.",
                          style: TextStyle(
                            color: Colors.white,
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
