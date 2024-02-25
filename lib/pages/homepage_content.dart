import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:kitajomvendor/pages/add_listing.dart';
import 'package:kitajomvendor/pages/update_profile_page.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d MMMM, y').format(now);

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Say hi to your\ndashboard!",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      color: darkGreen,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("It is now ",
                        style: TextStyle(fontStyle: FontStyle.italic)),
                    Text(formattedDate),
                  ],
                ),
                const SizedBox(height: 83),

                // Feature banner background
                ClipPath(
                  clipper: InwardCurvedBorderClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: darkGreen,
                  ),
                ),

                // New container under the feature banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    40,
                    30,
                    10,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddListingPage()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        height:
                            80, // Increased height to accommodate the subtitle
                        color: Color.fromARGB(255, 236, 234, 234),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 24,
                                  ), // Add icon
                                  SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Add new listing',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Put yourself on the map',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.chevron_right,
                                size: 24,
                              ), // Forward right arrow icon
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // New container under the feature banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    0,
                    30,
                    20,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UpdateProfilePage()), // Navigate to AddListingPage
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        height:
                            80, // Increased height to accommodate the subtitle
                        color: Color.fromARGB(255, 236, 234, 234),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                  ), // Add icon
                                  SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Update your profile',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Ensure your details are accurate',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.chevron_right,
                                size: 24,
                              ), // Forward right arrow icon
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Positioning the image on top of all other content
            Positioned(
              bottom: 230,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'lib/images/65.png',
                  width: MediaQuery.of(context).size.width *
                      0.8, // Control the image size
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InwardCurvedBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curveDepth = 60.0;
    Path path = Path();

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(size.width / 2, curveDepth, 0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
