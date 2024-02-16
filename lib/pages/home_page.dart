import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kitajomvendor/pages/profile_page.dart';
import 'package:kitajomvendor/pages/booking_page.dart';
import 'package:kitajomvendor/pages/listing_page.dart';
import 'package:kitajomvendor/pages/chat_page.dart';
import 'package:kitajomvendor/pages/homepage_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String firstName = "";
  final user = FirebaseAuth.instance.currentUser!;

  final List<Widget> _pages = [
    HomePageContent(),
    MyListingsPage(),
    BookingsPage(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void getUsername() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      firstName = (snap.data() as Map<String, dynamic>)['firstName'];
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Icon(
          Icons.menu,
          color: darkGreen,
        ),
        iconTheme: IconThemeData(
          color: darkGreen,
        ),
        title: Center(
          child: Text(
            "Welcome Back, $firstName",
            style: TextStyle(
              color: darkGreen,
              fontFamily: 'Lexend',
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              GNav(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: darkGreen,
                activeColor: darkGreen,
                tabBackgroundColor: lightGreen.withOpacity(0.3),
                tabMargin: EdgeInsets.symmetric(horizontal: 2),
                tabBorderRadius: 30,
                gap: 8,
                onTabChange: (index) {
                  setState(
                    () {
                      _selectedIndex = index;
                    },
                  );
                },
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: "Home",
                  ),
                  GButton(
                    icon: Icons.list_alt,
                    text: "Listings",
                  ),
                  GButton(
                    icon: Icons.calendar_month,
                    text: "Bookings",
                  ),
                  GButton(
                    icon: Icons.chat,
                    text: "Chat",
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
