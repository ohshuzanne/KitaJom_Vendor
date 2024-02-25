import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kitajomvendor/pages/profile_page.dart';
import 'package:kitajomvendor/pages/booking_page.dart';
import 'package:kitajomvendor/pages/listing_page.dart';
import 'package:kitajomvendor/pages/auth_page.dart';
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
  String? userPhotoUrl;

  final List<Widget> _pages = [
    HomePageContent(),
    MyListingsPage(),
    BookingsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  void getUsername() async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snap.exists) {
        Map<String, dynamic> userData = snap.data() as Map<String, dynamic>;
        setState(() {
          firstName = userData['firstName'];
          // Update the user photo URL
          userPhotoUrl = userData['photoUrl'];
        });
      } else {}
    } catch (error) {
      // Handle any errors that occur during fetching
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
        leading: IconButton(
          icon: Icon(Icons.logout, color: darkGreen),
          onPressed: signUserOut, // Move the sign-out function here
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
          // Add a Circular Avatar to the top right
          Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              6,
              8,
              0,
            ),
            child: CircleAvatar(
              // Placeholder for user image, adjust as needed
              backgroundImage: NetworkImage(
                  userPhotoUrl ?? 'https://example.com/default_avatar.png'),
              backgroundColor: lightGreen,
            ),
          ),
          SizedBox(width: 10), // For some spacing
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
                    icon: Icons.person,
                    text: "Profile",
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
