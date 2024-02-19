import 'package:flutter/material.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
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
    _showLoadingDialog(); // Show loading dialog

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context); // Pop the loading dialog
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Pop the loading dialog
      showErrorMessage(e.code);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dialog from being dismissed by tapping outside
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: darkGreen),
        );
      },
    );
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
          title: Center(
            child: Text(
              "Incorrect email or password",
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

            MyButton(
              onTap: signUserIn,
              buttonText: "Sign In",
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
