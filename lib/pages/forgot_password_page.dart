import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:kitajomvendor/components/mytextfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Password reset link has been sent to your email."),
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Lexend',
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: darkGreen,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset('lib/images/forgotpassword.png'),
                ),
              ),

              const SizedBox(height: 7),

              const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Reset your password!",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Enter your e-mail, and we'll send you \nlink to reset your password safely.",
                    textAlign: TextAlign.center,
                  )
                ],
              ),

              const SizedBox(height: 25),
              //text field for e-mail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: TextField(
                  controller: _emailController,
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
                    hintText: 'Enter e-mail here',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              //reset password button
              MaterialButton(
                onPressed: passwordReset,
                child: Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
