import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitajomvendor/firestore.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'dart:io';
import 'dart:typed_data';

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
  Uint8List? _image;
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> pickAndUploadImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      //uploading the image to storage
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('listing_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = storageRef.putFile(file);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        imageUrls.add(downloadUrl);
      });
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
                  RestaurantListingFields(
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

class RestaurantListingFields extends StatefulWidget {
  final VoidCallback pickAndUploadImages;
  final String userId;
  final List<String> imageUrls;
  const RestaurantListingFields({
    Key? key,
    required this.pickAndUploadImages,
    required this.userId,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _RestaurantListingFieldsState createState() =>
      _RestaurantListingFieldsState();
}

class _RestaurantListingFieldsState extends State<RestaurantListingFields> {
  //variables and controllers
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  List<String> cuisine = [];
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _openingHoursController = TextEditingController();
  String pricePointValue = '';
  FirestoreService firestoreService = FirestoreService();

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
        const Padding(
          padding: EdgeInsets.fromLTRB(
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
          obscureText: false,
        ),

        //address field
        const Padding(
          padding: EdgeInsets.fromLTRB(
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
          obscureText: false,
        ),

        //section for cuisine tags
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Cuisine Tags",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // Add an empty string to the cuisineTags list
                cuisine.add('');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Add a new cuisine tag',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // List of cuisine tag text fields
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cuisine.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // Update the cuisine tag in the list when text changes
                                cuisine[index] = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: darkGreen),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                fillColor: Colors.grey[200],
                                filled: true,
                                hintText: 'Cuisine ${index + 1}',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                labelText: cuisine[index].isEmpty
                                    ? 'Cuisine ${index + 1}'
                                    : null,
                                labelStyle: TextStyle(
                                  color: darkGreen.withOpacity(0.5),
                                  fontSize: 14,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    cuisine.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        //description field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Restaurant Description",
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
          controller: _descriptionController,
          hintText: "eg. KitaMakan Bistro and Bar",
          obscureText: false,
        ),

        //openingHours field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Restaurant Opening Hours",
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
          controller: _openingHoursController,
          hintText: "eg. KitaMakan Bistro and Bar",
          obscureText: false,
        ),

        //dropdown menu for pricePoint field
        Padding(
          padding: const EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Restaurant Price Point",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  35,
                  15,
                  35,
                  6,
                ),
                child: SizedBox(
                  width: 300,
                  child: PricePointDropDown(
                    onChanged: (value) {
                      pricePointValue = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        //uploadimages
        const Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: darkGreen,
                ),
              ),
              //middle text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Text(
                  "Upload your photo",
                  style: TextStyle(
                    color: darkGreen,
                    fontFamily: 'Lexend',
                    fontSize: 16,
                  ),
                ),
              ),

              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: darkGreen,
                ),
              )
            ],
          ),
        ),

        IconButton(
          onPressed: widget.pickAndUploadImages,
          icon: Icon(Icons.camera_alt),
          iconSize: 36,
        ),

        //save button
        CustomButton(
          onPressed: () {
            String listingName = _listingNameController.text;
            String address = _addressController.text;
            String description = _descriptionController.text;
            String openingHours = _openingHoursController.text;

            if (listingName.isNotEmpty &&
                address.isNotEmpty &&
                description.isNotEmpty &&
                openingHours.isNotEmpty) {
              firestoreService.addRestaurant(
                uid: widget.userId,
                listingName: listingName,
                address: address,
                cuisine: cuisine,
                description: description,
                openingHours: openingHours,
                pricePoint: pricePointValue,
                photos: widget.imageUrls,
              );
            } else {
              // Show an error message or handle empty fields appropriately
            }
          },
          text: "Add Restaurant",
        ),

        //spacing at bottom page
        const SizedBox(height: 100),
      ],
    );
  }
}
