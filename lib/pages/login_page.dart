import 'package:flutter/material.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/pages/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Add a GlobalKey

  void signUserIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // If sign-in is successful, navigate to the account page or home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePage(), // Replace AccountPage with the actual page you want to navigate to
        ),
      );
    } on FirebaseAuthException catch (e) {
      // If there is an error signing in, show an error message.
      showErrorMessage(e.message ?? "An error occurred. Please try again.");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Error",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 20),
            //logo
            Center(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('lib/images/16.png'),
              ),
            ),

            const SizedBox(height: 5),

            //welcome back, you've been missed

            const Text(
              "Easily connect with\nyour target audience",
              style: TextStyle(
                color: darkGreen,
                fontSize: 20,
                fontFamily: 'Lexend',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            //username textfield
            Text(
              "E-mail",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Lexend',
                color: darkGreen,
              ),
            ),
            MyTextField(
              controller: emailController,
              hintText: "E-mail",
              obscureText: false,
            ),

            const SizedBox(height: 20),

            //password textfield
            Text(
              "Password",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Lexend',
                color: darkGreen,
              ),
            ),

            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
            ),

            const SizedBox(height: 10),

            //forgot password?

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ForgotPasswordPage();
                    },
                  ),
                );
              },
              child: Text(
                "Forgot password?",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),

            //sign in button

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: MyButton(
                onTap: signUserIn,
                buttonText: "Sign In",
              ),
            ),

            const SizedBox(height: 25),

            //not a member? register now.

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member?",
                  style: TextStyle(color: darkGreen),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Register now.",
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
