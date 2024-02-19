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
import 'package:kitajomvendor/components/activity_type_dropdown.dart';
import 'package:kitajomvendor/pages/home_page.dart';

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

      // Update the imageUrls list
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
                  )
                else if (widget.listingType == 'activity')
                  ActivityListingFields(
                    pickAndUploadImages: pickAndUploadImages,
                    userId: widget.userId,
                    imageUrls: imageUrls,
                    // Pass any required parameters here
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

//restaurant listing fields
class _RestaurantListingFieldsState extends State<RestaurantListingFields> {
  //variables and controllers
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  List<String> cuisine = [];
  List<String> selectedCuisineTags = [];
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
          hintText: "eg. No.3, Jalan Putra 3, Lorong 3, 333333 KL",
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

        //selected cuisine tags
        Wrap(
          children: List.generate(selectedCuisineTags.length, (index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(selectedCuisineTags[index]),
                  onDeleted: () {
                    setState(() {
                      selectedCuisineTags.removeAt(index);
                    });
                  },
                ));
          }),
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
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
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
                                border: OutlineInputBorder(
                                  // Add border decoration
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                      color: darkGreen), // Dark green outline
                                ),
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
                                    selectedCuisineTags.add(cuisine[index]);
                                    cuisine.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.check),
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
          hintText: "e.g. An amazing atmosphere...",
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
          hintText: "IN THIS FORMAT: HH:MMam/pm - HH:MMam/pm",
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
          onPressed: () async {
            String listingName = _listingNameController.text;
            String address = _addressController.text;
            String description = _descriptionController.text;
            String openingHours = _openingHoursController.text;

            if (listingName.isNotEmpty &&
                address.isNotEmpty &&
                description.isNotEmpty &&
                openingHours.isNotEmpty) {
              // Save restaurant information to Firestore
              await firestoreService.addRestaurant(
                uid: widget.userId,
                listingName: listingName,
                address: address,
                cuisine: selectedCuisineTags,
                description: description,
                openingHours: openingHours,
                pricePoint: pricePointValue,
                photos: widget.imageUrls,
              );

              // Clear text fields
              _listingNameController.clear();
              _addressController.clear();
              _descriptionController.clear();
              _openingHoursController.clear();

              // Check if the widget is mounted before calling setState
              if (mounted) {
                // Navigate to the homepage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
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

class ActivityListingFields extends StatefulWidget {
  final VoidCallback pickAndUploadImages;
  final String userId;
  final List<String> imageUrls;
  const ActivityListingFields({
    Key? key,
    required this.pickAndUploadImages,
    required this.userId,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _ActivityListingFieldsState createState() => _ActivityListingFieldsState();
}

class Ticket {
  String name;
  double price;
  Ticket({required this.name, required this.price});
}

class _ActivityListingFieldsState extends State<ActivityListingFields> {
  final user = FirebaseAuth.instance.currentUser!;

  //variables and controllers
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String activityTypeValue = '';
  List<String> activities = [];
  List<String> activitiesSelected = [];
  TextEditingController _ageRestrictionsController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _openingHoursController = TextEditingController();
  TextEditingController _currentTicketNameController = TextEditingController();
  TextEditingController _currentTicketPriceController = TextEditingController();
  String pricePointValue = '';
  List<Ticket> tickets = [];
  List<Ticket> savedTickets = [];
  FirestoreService firestoreService = FirestoreService();

  void addTicket() {
    setState(() {
      tickets.add(Ticket(name: '', price: 0.0));
    });
  }

  // Function to save ticket information
  void _saveTicket(String name, String price) {
    if (name.isNotEmpty && price.isNotEmpty) {
      setState(() {
        Ticket newTicket =
            Ticket(name: name, price: double.tryParse(price) ?? 0.0);
        savedTickets
            .add(newTicket); // Add the ticket to the list of saved tickets
      });
      // Clear the text fields after saving
      _currentTicketNameController.clear();
      _currentTicketPriceController.clear();
    }
  }

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
            child: Image.asset('lib/images/57.png'),
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
                "Activity Name",
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
          hintText: "eg. KitaPlay Waterpark",
          obscureText: false,
        ),

        //dropdown menu for activityType field
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
                "Activity Type",
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
                  child: ActivityTypeDropdown(
                    onChanged: (value) {
                      activityTypeValue = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        //section for activity tags
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
                "Activity Tags",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        //selected activity tags
        Wrap(
          children: List.generate(activitiesSelected.length, (index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(activitiesSelected[index]),
                  onDeleted: () {
                    setState(() {
                      activitiesSelected.removeAt(index);
                    });
                  },
                ));
          }),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // Add an empty string to the activities tag list
                activities.add('');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Add a new activity tag',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // List of activity tag text fields
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length,
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
                                activities[index] = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  // Add border decoration
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                      color: darkGreen), // Dark green outline
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: darkGreen,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                fillColor: Colors.grey[200],
                                filled: true,
                                hintText: 'Activity Tag',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                labelText: activities[index].isEmpty
                                    ? 'Activity Tag'
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
                                    activitiesSelected.add(activities[index]);
                                    activities.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.check),
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
                "Activity Address",
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
          hintText: "eg. Jalan Gambang",
          obscureText: false,
        ),

        //age restriction field
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
                "Age Restriction",
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
          controller: _ageRestrictionsController,
          hintText: "eg. >5 years old",
          obscureText: false,
        ),

        //duration field
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
                "Activity Duration",
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
          controller: _durationController,
          hintText: "Average time spent at your activity?",
          obscureText: false,
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
                "Activity Description",
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
          hintText: "e.g. An amazing atmosphere...",
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
                "Activity Opening Hours",
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
          hintText: "IN THIS FORMAT: HH:MMam/pm - HH:MMam/pm",
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
                "Activity Price Point",
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
                "Ticket Categories",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        // Add a button to add a new ticket
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              addTicket();
            },
            child: Text('Add a new ticket'),
          ),
        ),
        // Display list of ticket categories as chips
        Wrap(
          children: List.generate(savedTickets.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                label: Text(savedTickets[index].name),
                backgroundColor: Colors.green,
                deleteIcon: Icon(Icons.close),
                onDeleted: () {
                  setState(() {
                    savedTickets.removeAt(index);
                  });
                },
              ),
            );
          }),
        ),
        // List of text fields for ticket name and price
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller:
                            TextEditingController(text: tickets[index].name),
                        onChanged: (value) {
                          tickets[index].name = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Ticket Name',
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                            text: tickets[index].price.toString()),
                        onChanged: (value) {
                          tickets[index].price = double.tryParse(value) ?? 0.0;
                        },
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _saveTicket(tickets[index].name,
                            tickets[index].price.toString());
                        setState(() {
                          // Hide the text fields after saving
                          tickets.removeAt(index);
                        });
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
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
          icon: const Icon(Icons.camera_alt),
          iconSize: 36,
        ),

        //save button
        CustomButton(
          onPressed: () async {
            String listingName = _listingNameController.text;
            String address = _addressController.text;
            String ageRestriction = _ageRestrictionsController.text;
            String duration = _durationController.text;
            String description = _descriptionController.text;
            String openingHours = _openingHoursController.text;

            if (listingName.isNotEmpty &&
                address.isNotEmpty &&
                description.isNotEmpty &&
                openingHours.isNotEmpty) {
              // Save restaurant information to Firestore
              await firestoreService.addActivity(
                uid: widget.userId,
                listingName: listingName,
                activityType: activityTypeValue,
                activities: activitiesSelected,
                address: address,
                ageRestrictions: ageRestriction,
                duration: duration,
                description: description,
                openingHours: openingHours,
                pricePoint: pricePointValue,
                ticketPrice: savedTickets,
                photos: widget.imageUrls,
              );

              // Clear text fields
              _listingNameController.clear();
              _addressController.clear();
              _descriptionController.clear();
              _openingHoursController.clear();

              // Check if the widget is mounted before calling setState
              if (mounted) {
                // Navigate to the homepage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            } else {
              // Show an error message or handle empty fields appropriately
            }
          },
          text: "Add Activity",
        ),

        //spacing at bottom page
        const SizedBox(height: 100),
      ],
    );
  }
}
