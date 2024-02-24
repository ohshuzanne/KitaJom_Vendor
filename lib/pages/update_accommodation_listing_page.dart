import 'package:kitajomvendor/components/accommodation_type_dropdown.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/mylongtextfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/pages/listing_page.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'dart:io';
import 'package:kitajomvendor/pages/auth_page.dart';

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
  final TextEditingController _newAmenitiesController = TextEditingController();
  final TextEditingController _roomTypesBedController = TextEditingController();
  final TextEditingController _roomTypesNameController =
      TextEditingController();
  final TextEditingController _roomTypesPaxController = TextEditingController();
  final TextEditingController _roomTypesPriceController =
      TextEditingController();
  final TextEditingController _roomTypesQuantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchListingData();
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Make dialog non-dismissible
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text(
            "Alert",
            style:
                TextStyle(color: darkGreen), // darkGreen text color for title
          ),
          content: Text(
            message,
            style:
                TextStyle(color: darkGreen), // darkGreen text color for content
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(
                    color: darkGreen), // darkGreen text color for button text
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteImage(int index) {
    // Remove the image URL from the list
    setState(() {
      updatedListingData?['photos'].removeAt(index);
    });
  }

  void cancelUpdatesListing() {
    updatedListingData = null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

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

      // Update updatedListingData
      setState(() {
        updatedListingData?['photos'].add(imageUrl);
      });
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading image: $error'),
      ));
    }
  }

  Future<void> saveUpdatesListing() async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('accommodation').doc(widget.listingId);

    if (updatedListingData != null) {
      updatedListingData?['listingName'] = _listingNameController.text;
      updatedListingData?['address'] = _addressController.text;
      updatedListingData?['description'] = _descriptionController.text;
      updatedListingData?['updatedAt'] = DateTime.now();
      try {
        await docRef.update({...?updatedListingData});
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.info,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Listing updated.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            content: Text(
                "Your listing has been updated. You will be redirected to the homepage now."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: darkGreen,
                  ),
                ),
              ),
            ],
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (error) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text(
              "Error",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text("Failed to update listing: $error"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: darkGreen,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void disableListing() async {
    // Show confirmation dialog
    final confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disable Listing'),
          content: const Text(
              'Are you sure you want to disable this listing? Clicking yes will cause your listing to become private and taken off the listing pages on the application.'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // User taps "No"
              child: const Text('No', style: TextStyle(color: darkGreen)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // User taps "Yes"
              child: const Text('Yes', style: TextStyle(color: darkGreen)),
            ),
          ],
        );
      },
    );

    // If user confirmed
    if (confirmation == true) {
      // Prepare data for update
      final dataToUpdate = {
        ...updatedListingData ?? {}, // Use existing updates
        'isAvailable': false, // Set isAvailable to false
      };

      // Update Firestore
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('accommodation')
            .doc(widget.listingId)
            .update(dataToUpdate);

        // Show a success message or directly navigate back to home
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } catch (error) {
        // Handle errors, e.g., show an error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to disable listing: $error'),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // Close the dialog
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // If user tapped "No", just close the dialog and do nothing
    }
  }

  void enableListing() async {
    // Show confirmation dialog
    final confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Listing'),
          content: const Text(
              'Are you sure you want to enable this listing? Clicking yes will turn this listing public and viewable by anyone again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // User taps "No"
              child: const Text('No', style: TextStyle(color: darkGreen)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // User taps "Yes"
              child: const Text('Yes', style: TextStyle(color: darkGreen)),
            ),
          ],
        );
      },
    );

    // If user confirmed
    if (confirmation == true) {
      // Prepare data for update
      final dataToUpdate = {
        ...updatedListingData ?? {}, // Use existing updates
        'isAvailable': true, // Set isAvailable to true
      };

      // Update Firestore
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('accommodation')
            .doc(widget.listingId)
            .update(dataToUpdate);

        // Show a success message or directly navigate back to home
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } catch (error) {
        // Handle errors, e.g., show an error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to enable listing: $error'),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(), // Close the dialog
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // If user tapped "No", just close the dialog and do nothing
    }
  }

  Future<void> fetchListingData() async {
    final firestore = FirebaseFirestore.instance;
    final accommodationSnapshot =
        await firestore.collection('accommodation').doc(widget.listingId).get();

    setState(
      () {
        if (accommodationSnapshot.exists) {
          listingData = accommodationSnapshot.data();
          updatedListingData = listingData;
          _listingNameController.text =
              accommodationSnapshot['listingName'] ?? '';
          _addressController.text = accommodationSnapshot['address'] ?? '';
          _descriptionController.text =
              accommodationSnapshot['description'] ?? '';
        }
      },
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AuthPage(),
    ));
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
      //photos
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 7),
          //photos
          Visibility(
            visible: listingData?['photos'] != null,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 18.0), // Remove horizontal padding
              child: SizedBox(
                height: 250,
                width: double.infinity, // Ensure PageView takes full width
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount:
                          (listingData?['photos'] as List<dynamic>?)?.length ??
                              0,
                      itemBuilder: (context, index) {
                        final photoUrl = listingData?['photos'][index];
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            // Delete button
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(Icons.delete_forever,
                                    color: Colors.red),
                                onPressed: () => deleteImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: (listingData?['photos'] as List<dynamic>?)
                                    ?.length ??
                                0,
                            effect: ExpandingDotsEffect(
                              spacing: 6,
                              dotWidth: 8,
                              dotHeight: 8,
                              dotColor: Colors.white,
                              activeDotColor: mediumGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //listingName
          const Padding(
            padding: EdgeInsets.fromLTRB(
              30,
              15,
              25,
              6,
            ),
            child: Text(
              'Accommodation Name',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyUpdateTextField(
            controller: _listingNameController,
          ),

          //address
          const Padding(
            padding: EdgeInsets.fromLTRB(
              30,
              15,
              25,
              6,
            ),
            child: Text(
              'Accommodation Address',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyLongTextField(
            controller: _addressController,
            hintText: 'Accommodation Address',
          ),

          //description
          const Padding(
            padding: EdgeInsets.fromLTRB(
              30,
              15,
              25,
              6,
            ),
            child: Text(
              'Accommodation Description',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyLongTextField(
            controller: _descriptionController,
            hintText: 'Accommodation Description',
          ),

          //chip display
          Padding(
            padding: const EdgeInsets.fromLTRB(
              30,
              0,
              39,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Amenities",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: darkGreen,
                      fontSize: 16,
                      fontFamily: 'Lexend'),
                ),
                const SizedBox(
                    height: 10), // Add some space between the icon and the text
                SizedBox(
                  height: 40, // Set a fixed height for the ListView
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        (updatedListingData?['amenities'] as List<dynamic>?)
                                ?.map<Widget>(
                              (amenities) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InputChip(
                                    label: Text(
                                      amenities.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                    onDeleted: () {
                                      updatedListingData?['amenities']
                                          .remove(amenities);
                                      // Update your UI accordingly by setting state
                                      setState(() {});
                                    },
                                    deleteIconColor:
                                        Colors.grey[600], // Adjust as needed
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      side: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).toList() ??
                            [],
                  ),
                ),
              ],
            ),
          ),

          //add new accommodation tag
          Padding(
            padding: const EdgeInsets.fromLTRB(
              30,
              0,
              30,
              6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newAmenitiesController,
                    decoration: InputDecoration(
                      hintText: 'Enter new amenities tag',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: darkGreen), // Non-focused border color
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: darkGreen), // Focused border color
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    String newAmenity = _newAmenitiesController.text.trim();
                    if (newAmenity.isNotEmpty) {
                      setState(() {
                        updatedListingData?['amenities'].add(newAmenity);
                        _newAmenitiesController.clear();
                      });
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: darkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //accommodationType
          Padding(
            padding: const EdgeInsets.fromLTRB(
              32,
              6,
              30,
              6,
            ),
            child: Text(
              'Accommodation Type',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              30,
              0,
              30,
              15,
            ),
            child: AccommodationTypeDropdown(
              onChanged: (selectedType) {
                setState(() {
                  updatedListingData?['accommodationType'] = selectedType;
                });
              },
            ),
          ),

          //roomTypes
          Padding(
            padding: const EdgeInsets.fromLTRB(
              30,
              10,
              30,
              6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Room Types/Whole House',
                  style: TextStyle(
                    color: darkGreen,
                    fontFamily: 'Lexend',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: updatedListingData?['roomTypes']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final roomType = updatedListingData?['roomTypes'][index];
                      return ListTile(
                        title: Text(roomType['name']),
                        subtitle: Text('RM${roomType['price']}'
                            ' | ${roomType['pax']} PAX'
                            ' | ${roomType['quantity']} quantity'
                            ' | ${roomType['bed']} Beds'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              updatedListingData?['roomTypes']?.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (!isAddingRoom) // Render Add Ticket button if not adding ticket
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          isAddingRoom = true;
                        });
                      },
                      child: Text(
                        'Add Room Type/ House',
                        style: TextStyle(color: darkGreen),
                      ),
                    ),
                  ),
                if (isAddingRoom) // Render text fields if adding ticket
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _roomTypesNameController,
                        decoration: InputDecoration(
                          labelText: 'Room Type Name',
                          labelStyle: TextStyle(color: darkGreen),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkGreen),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _roomTypesPriceController,
                        decoration: InputDecoration(
                          labelText: 'Room Type Price',
                          labelStyle: TextStyle(color: darkGreen),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkGreen),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _roomTypesPaxController,
                        decoration: InputDecoration(
                          labelText: 'Room Type PAX',
                          labelStyle: TextStyle(color: darkGreen),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkGreen),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _roomTypesQuantityController,
                        decoration: InputDecoration(
                          labelText: 'Room Type Quantity',
                          labelStyle: TextStyle(color: darkGreen),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkGreen),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _roomTypesBedController,
                        decoration: InputDecoration(
                          labelText: 'Room Type Beds',
                          labelStyle: TextStyle(color: darkGreen),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: darkGreen),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                updatedListingData?['roomTypes']?.add({
                                  'name': _roomTypesNameController.text,
                                  'price': double.parse(
                                      _roomTypesPriceController.text),
                                  'pax': _roomTypesPaxController.text,
                                  'bed': _roomTypesBedController.text,
                                  'quantity': _roomTypesQuantityController.text,
                                });
                                _roomTypesNameController.clear();
                                _roomTypesPriceController.clear();
                                _roomTypesPaxController.clear();
                                _roomTypesBedController.clear();
                                _roomTypesQuantityController.clear();
                                isAddingRoom = false;
                              });
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: darkGreen,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _roomTypesNameController.clear();
                                _roomTypesPriceController.clear();
                                _roomTypesBedController.clear();
                                _roomTypesPaxController.clear();
                                _roomTypesQuantityController.clear();
                                isAddingRoom = false;
                              });
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),

          //uploadimages
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
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
                onPressed: pickAndUploadImages,
                icon: Icon(Icons.camera_alt),
                iconSize: 36,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 0, 35, 10),
                child: Text(
                  "Your images will appear here",
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  10,
                ),
                child: SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      updatedListingData?['photos']?.length ?? 0,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.network(
                              updatedListingData?['photos'][index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Save Updates and Disable
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            child: Row(
              children: [
                //Save updates listing
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyButton(
                      onTap: saveUpdatesListing,
                      buttonText: 'Save Updates',
                    ),
                  ),
                ),

                //cancel changes
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyButton(
                      onTap: cancelUpdatesListing,
                      buttonText: 'Cancel Changes',
                    ),
                  ),
                ),
              ],
            ),
          ),

          //make unavailable
          Visibility(
            visible: listingData?['isAvailable'] == true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  10,
                  25,
                  40,
                ),
                child: GestureDetector(
                  onTap: disableListing,
                  child: Text(
                    "Click here to disable your listing",
                    style: TextStyle(
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),

          //make available
          Visibility(
            visible: listingData?['isAvailable'] == false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  10,
                  25,
                  40,
                ),
                child: GestureDetector(
                  onTap: enableListing,
                  child: Text(
                    "Click here to enable your listing",
                    style: TextStyle(
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
