import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  //sign user out
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: darkGreen,
          title: Text("HomePage",
              style: TextStyle(
                fontFamily: 'Lexend',
                color: lightYellow,
              )),
          actions: [
            IconButton(
                onPressed: signUserOut,
                icon: Icon(Icons.logout, color: lightYellow))
          ]),
      body: Center(
          child: Text(
        "Logged in as:\n" + user.email!,
        style: TextStyle(
          fontSize: 20,
          color: darkGreen,
        ),
        textAlign: TextAlign.center,
      )),
    );
  }
}
