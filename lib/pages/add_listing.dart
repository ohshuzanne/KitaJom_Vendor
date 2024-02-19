import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kitajomvendor/pages/profile_page.dart';
import 'package:kitajomvendor/pages/booking_page.dart';
import 'package:kitajomvendor/pages/listing_page.dart';
import 'package:kitajomvendor/pages/chat_page.dart';
import 'package:kitajomvendor/pages/homepage_content.dart';
import 'package:kitajomvendor/pages/add_listing_page2.dart';

class AddListingPage extends StatefulWidget {
  const AddListingPage({super.key});

  @override
  State<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends State<AddListingPage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? selectedListingType;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: darkGreen,
        ),
        title: const Center(
          child: Text(
            "Add New Listing",
            style: TextStyle(
              color: darkGreen,
              fontFamily: 'Lexend',
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('lib/images/55.png'),
            ),
          ),

          //Text
          const Text(
            "What kind of listing\nare you adding?",
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 24,
              color: darkGreen,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          //Space
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                //radio buttons
                RadioListTile<String>(
                  title: Text(
                    "Restaurant",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  value: 'restaurant',
                  groupValue: selectedListingType,
                  onChanged: (value) {
                    setState(() {
                      selectedListingType = value;
                    });
                  },
                  activeColor: darkGreen,
                  dense: true,
                ),

                //second radio
                RadioListTile<String>(
                  title: Text(
                    "Activity",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  value: 'activity',
                  groupValue: selectedListingType,
                  onChanged: (value) {
                    setState(() {
                      selectedListingType = value;
                    });
                  },
                  activeColor: darkGreen,
                  dense: true,
                ),

                //third radio button
                RadioListTile<String>(
                  title: Text(
                    "Accommodation",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  value: 'accommodation',
                  groupValue: selectedListingType,
                  onChanged: (value) {
                    setState(() {
                      selectedListingType = value;
                    });
                  },
                  activeColor: darkGreen,
                  dense: true,
                ),
              ],
            ),
          ),

          //Spacing
          const SizedBox(
            height: 20,
          ),

          //next button
          ElevatedButton(
            onPressed: () {
              if (selectedListingType != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddListingPage2(
                      listingType: selectedListingType!,
                      userId: user.uid,
                    ),
                  ),
                );
              } else {
                print("No");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Next',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
