import 'package:flutter/material.dart';
import 'package:kitajomvendor/pages/add_listing.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:kitajomvendor/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/pages/listing_details_page.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({Key? key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirestoreService _firestoreService = FirestoreService();
  late List<Map<String, dynamic>> listings;
  bool isLoaded = false;
  String firstName = '';

  @override
  void initState() {
    super.initState();
    _loadListings();
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

  _loadListings() async {
    List<Map<String, dynamic>> templist = [];

    //Fetch and filter restaurant listings
    var restaurantData = await _firestoreService.getRestaurantListings();
    var filteredRestaurantData = restaurantData
        .where((snapshot) =>
            (snapshot.data() as Map<String, dynamic>)['vendorId'] == user.uid)
        .toList();

    for (var snapshot in filteredRestaurantData) {
      templist.add(snapshot.data() as Map<String, dynamic>);
    }

    //Fetch and filter activity listings
    var activityData = await _firestoreService.getActivityListings();
    var filteredActivityData = activityData
        .where((snapshot) =>
            (snapshot.data() as Map<String, dynamic>)['vendorId'] == user.uid)
        .toList();

    for (var snapshot in filteredActivityData) {
      templist.add(snapshot.data() as Map<String, dynamic>);
    }

    // Fetch and filter accommodation listings
    var accommodationData = await _firestoreService.getAccommodationListings();
    var filteredAccommodationData = accommodationData
        .where((snapshot) =>
            (snapshot.data() as Map<String, dynamic>)['vendorId'] == user.uid)
        .toList();

    for (var snapshot in filteredAccommodationData) {
      templist.add(snapshot.data() as Map<String, dynamic>);
    }

    setState(() {
      listings = templist;
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Add listing button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: () {
                    // Navigate to add listing page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddListingPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    height: 80,
                    child: const Card(
                      color: darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Add new Listing!",
                              style: TextStyle(
                                color: milk,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            //reading listings
            isLoaded
                ? Expanded(
                    child: ListView.builder(
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        //read images

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListingDetails(
                                  userId: user.uid,
                                  listingId: listings[index][
                                      'listingId'], // Using Firestore auto-generated document ID
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.grey.shade400,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Container(
                                  height: 100.0,
                                  width: 100.0,
                                  color: Colors.white,
                                  child: listings[index]['photos'] != null &&
                                          listings[index]['photos'].isNotEmpty
                                      ? Image.network(
                                          listings[index]['photos'][0],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ); // Display an error icon if image loading fails
                                          },
                                        )
                                      : Icon(
                                          Icons.place,
                                          color: darkGreen,
                                        ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      listings[index]['listingName'] ??
                                          "Unavailable",
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontWeight: FontWeight.w600,
                                      )),
                                  const SizedBox(width: 10),
                                  Text(
                                    listings[index]['address'] ?? "Unavailable",
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                listings[index]['description'] ??
                                    "Description unavailable",
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: darkGreen,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
