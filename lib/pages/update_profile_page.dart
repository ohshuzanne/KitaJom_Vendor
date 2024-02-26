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
import 'package:kitajomvendor/pages/auth_page.dart';
import 'dart:io';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({Key? key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Map<String, dynamic>? userData;
  DocumentReference? vendorDocReference;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  bool validateInputFields() {
    if (_emailController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _addressController.text.isEmpty) {
      // Show dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Missing Information",
              style: TextStyle(
                color: darkGreen,
                fontSize: 16,
              ),
            ),
            content: Text("Please fill in all fields."),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
              ),
            ],
          );
        },
      );
      return false; // Input validation failed
    }
    return true; // Input validation passed
  }

  Future<void> updateUserDetails() async {
    if (!validateInputFields()) {
      return;
    }

    String uid = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> updatedUserData = {
      'email': _emailController.text,
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'username': _usernameController.text,
    };

    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .update(updatedUserData);

      // Update address in vendor subcollection using the stored document reference
      if (vendorDocReference != null) {
        await vendorDocReference!.update({'address': _addressController.text});
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      print("Error updating user data: $error");
    }
  }

  Future<void> pickAndUploadProfileImage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String uniqueFileName = "profile_$uid.png";

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('profile_images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      TaskSnapshot uploadTask =
          await referenceImageToUpload.putFile(File(file.path));
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('user').doc(uid).update({
        'photoUrl': imageUrl,
      });

      setState(() {
        userData?['photoUrl'] = imageUrl;
      });
    } catch (error) {
      print('Error uploading image: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading image: $error'),
      ));
    }
  }

  void fetchUserDetails() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      if (userSnapshot.exists) {
        userData = userSnapshot.data(); // Assign fetched data to userData
        setState(() {
          // Set controller values based on fetched data
          _emailController.text = userData?['email'] ?? '';
          _firstNameController.text = userData?['firstName'] ?? '';
          _lastNameController.text = userData?['lastName'] ?? '';
          _phoneNumberController.text = userData?['phoneNumber'] ?? '';
          _usernameController.text = userData?['username'] ?? '';
        });

        // Fetch address from vendor subcollection if it exists
        QuerySnapshot<Map<String, dynamic>> vendorSnapshot =
            await FirebaseFirestore.instance
                .collection('user')
                .doc(uid)
                .collection('vendor')
                .get();
        if (vendorSnapshot.docs.isNotEmpty) {
          Map<String, dynamic>? vendorData = vendorSnapshot.docs.first.data();
          setState(() {
            _addressController.text = vendorData['address'] ?? '';

            // Store the document reference for future use
            vendorDocReference = vendorSnapshot.docs.first.reference;
          });
        }
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
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
        iconTheme: const IconThemeData(
          color: darkGreen,
        ),
        title: const Center(
          child: Text(
            "Updating Profile",
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              color: darkGreen,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //email
            Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                10,
                30,
                6,
              ),
              child: Text(
                "E-mail",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            ),
            MyTextField(
                controller: _emailController,
                hintText: "Enter your e-mail",
                obscureText: false),

            //firstName
            Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                10,
                30,
                6,
              ),
              child: Text(
                "First Name",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            ),
            MyTextField(
                controller: _firstNameController,
                hintText: "Enter your first name",
                obscureText: false),

            //lastName
            Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                10,
                30,
                6,
              ),
              child: Text(
                "Last Name",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            ),
            MyTextField(
                controller: _lastNameController,
                hintText: "Enter your last name",
                obscureText: false),

            //Phone number
            Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                10,
                30,
                6,
              ),
              child: Text(
                "Phone Number",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            ),
            MyTextField(
                controller: _phoneNumberController,
                hintText: "Enter your phone number",
                obscureText: false),

            //username
            Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                10,
                30,
                6,
              ),
              child: Text(
                "Username",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            ),
            MyTextField(
                controller: _usernameController,
                hintText: "Enter your username",
                obscureText: false),

            //address
            Padding(
              padding: const EdgeInsets.fromLTRB(
                32,
                10,
                30,
                6,
              ),
              child: Text(
                "Address",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
            ),
            MyLongTextField(
              controller: _addressController,
              hintText: "Enter your address",
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
                CircleAvatar(
                  radius: 60, // Adjust the size to fit your design
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: userData?['photoUrl'] != null
                      ? NetworkImage(userData!['photoUrl'])
                      : null, // Placeholder in case of null
                  child: userData?['photoUrl'] == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade800,
                        )
                      : null, // Shows an icon if no image is available
                ),
                IconButton(
                  onPressed: pickAndUploadProfileImage,
                  icon: Icon(Icons.camera_alt),
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 33,
              ),
              child: MyButton(
                onTap: () async {
                  await updateUserDetails();
                },
                buttonText: 'Update',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
