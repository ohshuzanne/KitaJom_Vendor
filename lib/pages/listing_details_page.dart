import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/home_page.dart';

class ListingDetails extends StatefulWidget {
  final String userId;
  final String listingId;

  const ListingDetails(
      {Key? key, required this.userId, required this.listingId})
      : super(key: key);

  @override
  State<ListingDetails> createState() => _ListingDetailsState();
}

class _ListingDetailsState extends State<ListingDetails> {
  Map<String, dynamic>? listingData;
  final user = FirebaseAuth.instance.currentUser!;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchListingData();
  }

  Future<void> fetchListingData() async {
    final firestore = FirebaseFirestore.instance;
    final restaurantSnapshot =
        await firestore.collection('restaurant').doc(widget.listingId).get();
    final accommodationSnapshot =
        await firestore.collection('accommodation').doc(widget.listingId).get();
    final activitySnapshot =
        await firestore.collection('activity').doc(widget.listingId).get();

    setState(() {
      if (restaurantSnapshot.exists) {
        listingData = restaurantSnapshot.data();
      } else if (accommodationSnapshot.exists) {
        listingData = accommodationSnapshot.data();
      } else if (activitySnapshot.exists) {
        listingData = activitySnapshot.data();
      }
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void deletelisting() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Listing Confirmation"),
        content: Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final firestore = FirebaseFirestore.instance;

      // Query all three collections
      final restaurantSnapshot =
          await firestore.collection('restaurant').doc(widget.listingId).get();
      final accommodationSnapshot = await firestore
          .collection('accommodation')
          .doc(widget.listingId)
          .get();
      final activitySnapshot =
          await firestore.collection('activity').doc(widget.listingId).get();

      if (restaurantSnapshot.exists) {
        await firestore.collection('restaurant').doc(widget.listingId).delete();
      } else if (accommodationSnapshot.exists) {
        await firestore
            .collection('accommodation')
            .doc(widget.listingId)
            .delete();
      } else if (activitySnapshot.exists) {
        await firestore.collection('activity').doc(widget.listingId).delete();
      }

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  Widget starRating(int rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      IconData iconData = rating > 1 ? Icons.start : Icons.star_rounded;
      Color color = rating > i ? Colors.yellow : Colors.grey;
      stars.add(
        Icon(
          iconData,
          color: color,
          size: 25,
        ),
      );
    }
    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: darkGreen,
        ),
        title: Center(
          child: Text(
            listingData?['listingName'] ?? 'Listing Not Found',
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              color: darkGreen,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 7),

            //photos
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 18.0), // Remove horizontal padding
              child: SizedBox(
                height: 250,
                width: double.infinity, // Ensure PageView takes full width
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount:
                          (listingData?['photos'] as List<dynamic>?)?.length ??
                              0,
                      itemBuilder: (context, index) {
                        final photoUrl = listingData?['photos'][index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Image.network(
                                  photoUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: (listingData?['photos'] as List<dynamic>?)
                                    ?.length ??
                                0,
                            effect: ExpandingDotsEffect(
                              spacing: 6,
                              dotWidth: 8,
                              dotHeight: 8,
                              dotColor: Colors.white,
                              activeDotColor: mediumGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            //main listing details
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  starRating(
                    listingData?['rating'] ?? 0,
                  ),
                ],
              ),
            ),

            //userReviews
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Check user reviews ",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "here",
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

            //listing data here
            //name
            Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                20,
                25,
                8,
              ),
              child: SizedBox(
                child: Row(
                  children: [
                    Text(
                      "${listingData?['listingName'] ?? 'Loading'}",
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Visibility(
                      visible: listingData?['pricePoint'] != null,
                      child: Text(
                        "   (${listingData?['pricePoint'] ?? ''})",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //address
            Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                0,
                25,
                6,
              ),
              child: Row(
                children: [
                  Icon(Icons.place_rounded),
                  SizedBox(
                      width:
                          10), // Add some space between the icon and the text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height:
                                5), // Add some vertical space between the title and the address
                        Text(
                          "${listingData?['address'] ?? 'Loading'}",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //description
            Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                0,
                25,
                6,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                  ),
                  SizedBox(
                      width:
                          10), // Add some space between the icon and the text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height:
                                5), // Add some vertical space between the title and the address
                        Text(
                          "${listingData?['description'] ?? 'Loading'}",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //openingHours
            Visibility(
              visible: listingData?['openingHours'] != null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  0,
                  25,
                  6,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                    ),
                    SizedBox(
                        width:
                            10), // Add some space between the icon and the text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  5), // Add some vertical space between the title and the address
                          Text(
                            "${listingData?['openingHours'] ?? 'Loading'}",
                            style: TextStyle(
                              fontFamily: 'Lexend',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Divider(),
            ),

            //cuisine tags
            Visibility(
              visible: listingData?['cuisine'] != null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  15,
                  25,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                    ),
                    SizedBox(
                        width:
                            10), // Add some space between the icon and the text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 5.0,
                            runSpacing: 0.0,
                            children:
                                (listingData?['cuisine'] as List<dynamic>?)
                                        ?.map<Widget>((cuisine) {
                                      return Chip(
                                        label: Text(
                                          cuisine.toString(),
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            fontSize: 14,
                                            color: Colors.grey[00],
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade400,
                                            )),
                                      );
                                    }).toList() ??
                                    [],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            DefaultTextStyle(
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lexend',
                  color: Colors.grey.shade400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Last Updated: "),
                  Text(
                    (listingData?['updatedAt'] != null
                        ? DateFormat('MMMM d, y')
                            .format(listingData?['createdAt']?.toDate())
                        : 'Loading'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //Delete Listing
            MyButton(onTap: deletelisting, buttonText: 'Delete Listing'),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
