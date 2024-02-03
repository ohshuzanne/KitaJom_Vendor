import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/pages/loginorregister_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          //stream is constantly listening to whether the user is logged in or not
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is logged in
            if (snapshot.hasData) {
              return HomePage();
            }

            //if user is not logged in
            else {
              return LoginOrRegisterPage();
            }
          }),
    );
  }
}
