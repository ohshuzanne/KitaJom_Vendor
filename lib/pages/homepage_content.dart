import 'package:flutter/material.dart';
import 'package:kitajomvendor/models/illustrations.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Text("This is your homepage so hello"),
      ),
    );
  }
}
