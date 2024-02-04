import 'package:flutter/material.dart';
import 'package:kitajomvendor/pages/auth_page.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:kitajomvendor/onboarding_pages/onboarding_page_1.dart';
import 'package:kitajomvendor/onboarding_pages/onboarding_page_2.dart';
import 'package:kitajomvendor/onboarding_pages/onboarding_page_3.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  //create a controller to keep track of which page we're on
  PageController _controller = PageController();

  //keep track of page index
  bool onSecondPage = false;
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onSecondPage = (index == 1);
                onLastPage = (index == 2);
              });
            },
            children: [
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
            ],
          ),
          //add dot indicator
          Container(
            alignment: const Alignment(0, 0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //skip button
                    GestureDetector(
                      onTap: () {
                        _controller.animateToPage(2,
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeInToLinear);
                      },
                      child: const Text("Skip",
                          style: TextStyle(fontFamily: 'Lexend')),
                    ),

                    //dot indicators
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        dotWidth: 10,
                        dotHeight: 10,
                        dotColor: darkGreen,
                        activeDotColor: lightGreen,
                      ),
                    ),

                    //next/done button
                    onLastPage
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AuthPage();
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Done",
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: darkGreen,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeIn,
                              );
                            },
                            child: Text(
                              "Next",
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: darkGreen,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 20),

                //get started button
                onSecondPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AuthPage();
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AuthPage();
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: darkGreen,
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          child: const Text(
                            "Get Started",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
