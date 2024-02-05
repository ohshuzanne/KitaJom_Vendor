import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/components/pickimage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kitajomvendor/components/add_data.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //creating the controllers to save/use what the users are
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final usernameController = TextEditingController();
  final addressController = TextEditingController();
  final businessNameController = TextEditingController();
  final registrationNumberController = TextEditingController();

  //Uint8List for image
  Uint8List? _image;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    usernameController.dispose();
    addressController.dispose();
    businessNameController.dispose();
    registrationNumberController.dispose();
    super.dispose();
  }

  //sign user in method
  Future signUserUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: darkGreen),
        );
      },
    );

    //try creating the user //authentication
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        //add user details
        saveProfile();
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        showErrorMessage("Passwords do not match");
      }
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  //wrong credentials message
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Center(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(
      () {
        _image = img;
      },
    );
  }

  void saveProfile() async {
    String email = emailController.text.trim();
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String username = usernameController.text.trim();
    String address = addressController.text.trim();
    String businessName = businessNameController.text.trim();
    String registrationNumber = registrationNumberController.text.trim();

    String resp = await StoreData().saveData(
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      file: _image!,
      username: username,
      address: address,
      businessName: businessName,
      registrationNumber: registrationNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 30),
            //logo
            Center(
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('lib/images/17.png'),
              ),
            ),

            const SizedBox(height: 20),

            //welcome back, you've been missed

            const Text(
              "Establish yourself on\nthe platform to be",
              style: TextStyle(
                color: darkGreen,
                fontSize: 20,
                fontFamily: 'Lexend',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            //username textfield
            MyTextField(
              controller: emailController,
              hintText: "E-mail",
              obscureText: false,
            ),

            const SizedBox(height: 20),

            //password textfield
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),

            const SizedBox(height: 20),

            //confirm password textfield
            MyTextField(
              controller: confirmPasswordController,
              hintText: "Confirm your password",
              obscureText: true,
            ),

            const SizedBox(height: 20),

            //username TextField
            MyTextField(
              controller: usernameController,
              hintText: "Username",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //firstName TextField
            MyTextField(
              controller: firstNameController,
              hintText: "First Name",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //lastName TextField
            MyTextField(
              controller: lastNameController,
              hintText: "Last Name",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //phone TextField
            MyTextField(
              controller: phoneNumberController,
              hintText: "Phone Number",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //ADDRESS TextField
            //CHANGE THIS
            MyTextField(
              controller: addressController,
              hintText: "Address",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //Business Name
            MyTextField(
              controller: businessNameController,
              hintText: "Business Name",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            //registration number
            MyTextField(
              controller: registrationNumberController,
              hintText: "Registration Number",
              obscureText: false,
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
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
                        fontSize: 18,
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

            const SizedBox(height: 25),

            //profile photo
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                    : CircleAvatar(
                        radius: 64,
                        backgroundColor: milk,
                        backgroundImage:
                            AssetImage('lib/images/defaultprofile.png'),
                      ),
                Positioned(
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo,
                      color: darkGreen,
                    ),
                  ),
                  bottom: -10,
                  left: 90,
                ),
              ],
            ),

            const SizedBox(height: 25),

            //not a member? register now.

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already a member?",
                  style: TextStyle(color: darkGreen),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Sign in here.",
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            MyButton(
              onTap: signUserUp,
              buttonText: "Sign Up",
            ),
          ]),
        ),
      ),
    );
  }
}
