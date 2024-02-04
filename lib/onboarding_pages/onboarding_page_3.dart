import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';

class OnboardingPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: milk,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 0),
            //onboarding image 1
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: milk,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('lib/images/onboardingimage4.png'),
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
                        "Be a part of the\nchange",
                        style: TextStyle(
                          color: darkGreen,
                          height: 1.0,
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

            const SizedBox(height: 20),

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
                          "KitaJom is an initiative to not\nonly serve our Mother Earth and\nprotect our natural resources,\nit also promotes the beauty of\nlife in our vicinity. Choose local,\nchoose sustainable.",
                          style: TextStyle(
                            color: darkGreen,
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
