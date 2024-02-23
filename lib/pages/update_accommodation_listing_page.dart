import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/mylongtextfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'package:kitajomvendor/components/activity_type_dropdown.dart';
import 'dart:io';

class UpdateAccommodationListingPage extends StatefulWidget {
  final String userId;
  final String listingId;

  const UpdateAccommodationListingPage({
    Key? key,
    required this.userId,
    required this.listingId,
  }) : super(key: key);

  @override
  _UpdateAccommodationListingPageState createState() =>
      _UpdateAccommodationListingPageState();
}

class _UpdateAccommodationListingPageState
    extends State<UpdateAccommodationListingPage> {
  Map<String, dynamic>? listingData;
  Map<String, dynamic>? updatedListingData;
  List<Map<String, dynamic>> roomTypes = [];
  bool isAddingRoom = false;
  final user = FirebaseAuth.instance.currentUser!;
  final PageController _pageController = PageController();
  final TextEditingController _listingNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchListingData();
  }

  Future<void> fetchListingData() async {
    final firestore = FirebaseFirestore.instance;
    final accommodationSnapshot =
        await firestore.collection('accommodation').doc(widget.listingId).get();

    setState(
      () {
        if (accommodationSnapshot.exists) {
          listingData = accommodationSnapshot.data();
        }
      },
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: darkGreen,
        ),
        title: Center(
          child: Text(
            listingData?['listingName'] ?? 'Listing Not Found',
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              color: darkGreen,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 7),
        ]),
      ),
    );
  }
}
