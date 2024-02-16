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
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/pages/add_listing_page2.dart';

class AddListingPage2 extends StatefulWidget {
  final String userId;
  final String listingType;

  const AddListingPage2({
    Key? key,
    required this.userId,
    required this.listingType,
  }) : super(key: key);

  @override
  State<AddListingPage2> createState() => _AddListingPage2State();
}

class _AddListingPage2State extends State<AddListingPage2> {
  final user = FirebaseAuth.instance.currentUser!;

  //sign out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: darkGreen,
        ),
        title: Center(
          child: Text(
            'Add New ${widget.listingType.capitalize()} Listing',
            style: TextStyle(
              color: darkGreen,
              fontFamily: 'Lexend',
              fontSize: 16,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //spacing
                const SizedBox(height: 20),
                //checking what type and showing specific fieldsd
                if (widget.listingType == 'restaurant')
                  RestaurantListingFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class RestaurantListingFields extends StatefulWidget {
  const RestaurantListingFields({Key? key}) : super(key: key);

  @override
  _RestaurantListingFieldsState createState() =>
      _RestaurantListingFieldsState();
}

class _RestaurantListingFieldsState extends State<RestaurantListingFields> {
  //variables and controllers
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _openingHoursController = TextEditingController();
  TextEditingController _pricePointController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //illustration
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset('lib/images/56.png'),
          ),
        ),

        //Spacing
        const SizedBox(height: 20),

        //listingName field
        Padding(
          padding: const EdgeInsets.fromLTRB(
            35,
            0,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Restaurant Name",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyTextField(
            controller: _listingNameController,
            hintText: "eg. KitaMakan Bistro and Bar",
            obscureText: false),

        //address field
        Padding(
          padding: const EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Restaurant Address",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyTextField(
            controller: _addressController,
            hintText: "eg. KitaMakan Bistro and Bar",
            obscureText: false),
      ],
    );
  }
}
