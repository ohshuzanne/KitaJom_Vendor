import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/mylongtextfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'package:kitajomvendor/components/activity_type_dropdown.dart';
import 'dart:io';
import 'package:kitajomvendor/pages/auth_page.dart';

class UpdateActivityListingPage extends StatefulWidget {
  final String userId;
  final String listingId;

  const UpdateActivityListingPage({
    Key? key,
    required this.userId,
    required this.listingId,
  }) : super(key: key);

  @override
  State<UpdateActivityListingPage> createState() =>
      _UpdateActivityListingPageState();
}

class _UpdateActivityListingPageState extends State<UpdateActivityListingPage> {
  Map<String, dynamic>? listingData;
  Map<String, dynamic>? updatedListingData;
  List<Map<String, dynamic>> ticketPrices = [];
  bool isAddingTicket = false;
  final user = FirebaseAuth.instance.currentUser!;
  final PageController _pageController = PageController();
  final TextEditingController _listingNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ageRestrictionsController =
      TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _openingHoursController = TextEditingController();
  final TextEditingController _newActivitiesController =
      TextEditingController();
  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchListingData();
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
    final docRef = firestore.collection('activity').doc(widget.listingId);

    if (updatedListingData != null) {
      updatedListingData?['listingName'] = _listingNameController.text;
      updatedListingData?['address'] = _addressController.text;
      updatedListingData?['description'] = _descriptionController.text;
      updatedListingData?['openingHours'] = _openingHoursController.text;
      updatedListingData?['ageRestrictions'] = _ageRestrictionsController.text;
      updatedListingData?['duration'] = _durationController.text;
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
            .collection('activity')
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
            .collection('activity')
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
    final activityScreenshot =
        await firestore.collection('activity').doc(widget.listingId).get();

    setState(
      () {
        if (activityScreenshot.exists) {
          listingData = activityScreenshot.data();
          updatedListingData = listingData;
          _listingNameController.text = activityScreenshot['listingName'] ?? '';
          _addressController.text = activityScreenshot['address'] ?? '';
          _descriptionController.text = activityScreenshot['description'] ?? '';
          _openingHoursController.text =
              activityScreenshot['openingHours'] ?? '';
          _durationController.text = activityScreenshot['duration'] ?? '';
          _ageRestrictionsController.text =
              activityScreenshot['ageRestrictions'] ?? '';
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
            updatedListingData?['listingName'] ?? 'Listing Not Found',
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
              'Activity Name',
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
              'Activity Address',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyLongTextField(
            controller: _addressController,
            hintText: 'ACtivity Address',
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
              'Activity Description',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyLongTextField(
            controller: _descriptionController,
            hintText: 'Activity Description',
          ),

          //openingHours
          const Padding(
            padding: EdgeInsets.fromLTRB(
              30,
              15,
              25,
              6,
            ),
            child: Text(
              'Activity Opening Hours',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyUpdateTextField(
            controller: _openingHoursController,
          ),

          //ageRestrictions
          const Padding(
            padding: EdgeInsets.fromLTRB(
              30,
              15,
              25,
              6,
            ),
            child: Text(
              'Age Restrictions',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyUpdateTextField(
            controller: _ageRestrictionsController,
          ),

          //duration
          const Padding(
            padding: EdgeInsets.fromLTRB(
              30,
              15,
              25,
              6,
            ),
            child: Text(
              'Activity Duration',
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          MyUpdateTextField(
            controller: _durationController,
          ),

          //chip display
          Padding(
            padding: const EdgeInsets.fromLTRB(
              30,
              15,
              39,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Activities",
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
                        (updatedListingData?['activities'] as List<dynamic>?)
                                ?.map<Widget>(
                              (activities) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InputChip(
                                    label: Text(
                                      activities.toString(),
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    backgroundColor: Colors.grey.shade200,
                                    onDeleted: () {
                                      updatedListingData?['activities']
                                          .remove(activities);
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

          //add new activity tag
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
                    controller: _newActivitiesController,
                    decoration: InputDecoration(
                      hintText: 'Enter new activities tag',
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
                    String newActivity = _newActivitiesController.text.trim();
                    if (newActivity.isNotEmpty) {
                      setState(() {
                        updatedListingData?['activities'].add(newActivity);
                        _newActivitiesController.clear();
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

          //pricePoint
          Padding(
            padding: const EdgeInsets.fromLTRB(
              32,
              15,
              30,
              6,
            ),
            child: Text(
              'Activity Price Point',
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
            child: PricePointDropDown(
              onChanged: (selectedPrice) {
                setState(() {
                  updatedListingData?['pricePoint'] = selectedPrice;
                });
              },
            ),
          ),

          //activityType
          Padding(
            padding: const EdgeInsets.fromLTRB(
              32,
              6,
              30,
              6,
            ),
            child: Text(
              'Activity Type',
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
            child: ActivityTypeDropdown(
              onChanged: (selectedType) {
                setState(() {
                  updatedListingData?['activityType'] = selectedType;
                });
              },
            ),
          ),

          //tickets
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Tickets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: updatedListingData?['ticketPrice']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final ticket = updatedListingData?['ticketPrice'][index];
                      return ListTile(
                        title: Text(ticket['name']),
                        subtitle: Text('RM${ticket['price']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              updatedListingData?['ticketPrice']
                                  ?.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (!isAddingTicket) // Render Add Ticket button if not adding ticket
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        isAddingTicket = true;
                      });
                    },
                    child: Text(
                      'Add Ticket',
                      style: TextStyle(color: darkGreen),
                    ),
                  ),
                if (isAddingTicket) // Render text fields if adding ticket
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _ticketNameController,
                        decoration: InputDecoration(labelText: 'Ticket Name'),
                      ),
                      TextField(
                        controller: _ticketPriceController,
                        decoration: InputDecoration(labelText: 'Ticket Price'),
                        keyboardType: TextInputType.number,
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
                                updatedListingData?['ticketPrice']?.add({
                                  'name': _ticketNameController.text,
                                  'price':
                                      double.parse(_ticketPriceController.text),
                                });
                                _ticketNameController.clear();
                                _ticketPriceController.clear();
                                isAddingTicket = false;
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
                                _ticketNameController.clear();
                                _ticketPriceController.clear();
                                isAddingTicket = false;
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
