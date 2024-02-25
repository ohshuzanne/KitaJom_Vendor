import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userPhotoUrl; // Initialize as an empty string
  String? email;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? username;
  String? address;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data();
        setState(() {
          userPhotoUrl = userData?['photoUrl'];
          firstName = userData?['firstName'];
          lastName = userData?['lastName'];
          email = userData?['email'];
          phoneNumber = userData?['phoneNumber'];
          username = userData?['username'];
        });

        // Now fetch the address from the 'vendor' subcollection
        QuerySnapshot<Map<String, dynamic>> vendorSnapshot =
            await FirebaseFirestore.instance
                .collection('user')
                .doc(uid)
                .collection('vendor')
                .get();
        if (vendorSnapshot.docs.isNotEmpty) {
          Map<String, dynamic>? vendorData = vendorSnapshot.docs.first.data();
          setState(() {
            address = vendorData['address'];
          });
        }
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        // Make the page scrollable
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context)
                  .size
                  .width, // This ensures it spans the full width
              height: MediaQuery.of(context).size.height *
                  0.3, // Adjust the height as needed, here it's 30% of the screen height
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    userPhotoUrl ??
                        'https://via.placeholder.com/150', // Fallback to a placeholder if `userPhotoUrl` is null
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: userPhotoUrl == null
                  ? Icon(Icons.account_circle,
                      size: 100,
                      color: Colors.white
                          .withOpacity(0.5)) // Show an icon if no image URL
                  : null, // No child widget if the image URL is not null
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .start, // Aligns children to the start of the column
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal:
                            20, // Add horizontal padding for aesthetic spacing
                      ),
                      margin: EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 250, 247, 247),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2), // Shadow color
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "Basic Information",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w400,
                          color: darkGreen,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Aligns children to the start and end of the row
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreen,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          email ?? 'Not available',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Aligns children to the start and end of the row
                      children: [
                        Text(
                          "First Name",
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreen,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          firstName ?? 'Not available',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Aligns children to the start and end of the row
                      children: [
                        Text(
                          "Last Name",
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreen,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          lastName ?? 'Not available',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Aligns children to the start and end of the row
                      children: [
                        Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreen,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          phoneNumber ?? 'Not available',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Aligns children to the start and end of the row
                      children: [
                        Text(
                          "Username",
                          style: TextStyle(
                            fontSize: 14,
                            color: darkGreen,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          username ?? 'Not available',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Adjust alignment as needed
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Address",
                            style: TextStyle(
                              fontSize: 14,
                              color: darkGreen,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            address ?? 'Not available',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateProfilePage()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Update profile ",
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "here",
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
