import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kitajomvendor/pages/add_activity_listing.dart';
import 'package:kitajomvendor/pages/add_restaurant_listing.dart';
import 'package:kitajomvendor/pages/add_accommodation_listing.dart';

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
  List<String> imageUrls = [];
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> pickAndUploadImages() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;
    String uniqueFileName =
        DateTime.now().millisecondsSinceEpoch.toString() + '.png';

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Listing_images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      // Upload the image file
      TaskSnapshot uploadTask =
          await referenceImageToUpload.putFile(File(file.path));
      String imageUrl = await uploadTask.ref.getDownloadURL();
      setState(() {
        imageUrls.add(imageUrl);
      });
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading image: $error'),
      ));
    }
  }

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
            style: const TextStyle(
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
                  RestaurantListingFields(
                    pickAndUploadImages: pickAndUploadImages,
                    userId: widget.userId,
                    imageUrls: imageUrls,
                  )
                else if (widget.listingType == 'activity')
                  ActivityListingFields(
                    pickAndUploadImages: pickAndUploadImages,
                    userId: widget.userId,
                    imageUrls: imageUrls,
                  )
                else if (widget.listingType == "accommodation")
                  AccommodationListingFields(
                    pickAndUploadImages: pickAndUploadImages,
                    userId: widget.userId,
                    imageUrls: imageUrls,
                  ),
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
