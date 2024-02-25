import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/pages/update_restaurant_listing_page.dart';
import 'package:kitajomvendor/pages/update_activity_listing_page.dart';
import 'package:kitajomvendor/pages/update_accommodation_listing_page.dart';
import 'package:kitajomvendor/pages/view_review_page.dart';
import 'package:kitajomvendor/pages/auth_page.dart';
import 'package:kitajomvendor/utils/map_utils.dart';

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

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Make dialog non-dismissible
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background color to white
          title: Text(
            "Alert",
            style:
                TextStyle(color: darkGreen), // darkGreen text color for title
          ),
          content: Text(
            message,
            style:
                TextStyle(color: darkGreen), // darkGreen text color for content
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "OK",
                style: TextStyle(
                    color: darkGreen), // darkGreen text color for button text
              ),
            ),
          ],
        );
      },
    );
  }

  void navigateToUserReviews() async {
    final firestore = FirebaseFirestore.instance;
    String collectionName = '';

    final restaurantSnapshot =
        await firestore.collection('restaurant').doc(widget.listingId).get();
    if (restaurantSnapshot.exists) {
      collectionName = 'restaurant';
    } else {
      final accommodationSnapshot = await firestore
          .collection('accommodation')
          .doc(widget.listingId)
          .get();
      if (accommodationSnapshot.exists) {
        collectionName = 'accommodation';
      } else {
        final activitySnapshot =
            await firestore.collection('activity').doc(widget.listingId).get();
        if (activitySnapshot.exists) {
          collectionName = 'activity';
        }
      }
    }

    if (collectionName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserReviewsPage(
            userId: user.uid,
            listingId: widget.listingId,
            collectionName: collectionName,
          ),
        ),
      );
    } else {
      showAlertDialog(context, "No collection found");
    }
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AuthPage(),
    ));
  }

  void updateListing() {
    // Check if the listing ID belongs to the restaurant collection
    FirebaseFirestore.instance
        .collection('restaurant')
        .doc(widget.listingId)
        .get()
        .then((restaurantSnapshot) {
      if (restaurantSnapshot.exists) {
        // Navigate to UpdateRestaurantListingPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateRestaurantListingPage(
              userId: widget.userId,
              listingId: widget.listingId,
            ),
          ),
        );
      } else {
        // Check if the listing ID belongs to the activity collection
        FirebaseFirestore.instance
            .collection('activity')
            .doc(widget.listingId)
            .get()
            .then((activitySnapshot) {
          if (activitySnapshot.exists) {
            // Navigate to UpdateActivityListingPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateActivityListingPage(
                  userId: widget.userId,
                  listingId: widget.listingId,
                ),
              ),
            );
          } else {
            // Assume the listing ID belongs to the accommodation collection
            // Navigate to UpdateAccommodationListingPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateAccommodationListingPage(
                  userId: widget.userId,
                  listingId: widget.listingId,
                ),
              ),
            );
          }
        });
      }
    });
  }

  void deletelisting() async {
    bool confirm = await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.grey.shade800.withOpacity(0.8),
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              "Delete Listing?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        content: Text(
            "Are you sure you want to delete this listing? Any deleted information is unretrievable."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "No",
              style: TextStyle(
                color: darkGreen,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Yes",
              style: TextStyle(
                color: darkGreen,
              ),
            ),
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

  Widget starRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      Icon icon;
      if (i <= rating) {
        icon = Icon(Icons.star, color: Colors.yellow.shade700, size: 25);
      } else if (i - rating < 1) {
        // This will add a half star if the rating is not a whole number
        icon = Icon(Icons.star_half, color: Colors.yellow.shade700, size: 25);
      } else {
        icon = Icon(Icons.star_border, color: Colors.grey, size: 25);
      }
      stars.add(icon);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    double rating = (listingData?['rating'] ?? 0).toDouble();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
            Visibility(
              visible: listingData?['photos'] != null,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 18.0), // Remove horizontal padding
                child: SizedBox(
                  height: 250,
                  width: double.infinity, // Ensure PageView takes full width
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: (listingData?['photos'] as List<dynamic>?)
                                ?.length ??
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
            ),

            const SizedBox(height: 10),

            //main listing details
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  starRating(rating),
                ],
              ),
            ),

            //userReviews
            Center(
              child: GestureDetector(
                onTap: navigateToUserReviews,
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
              child: GestureDetector(
                onTap: () {
                  MapUtils.openMap(listingData?['address'] ?? '');
                },
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
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

            //activityType
            Visibility(
              visible: listingData?['activityType'] != null,
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
                      Icons.local_activity_rounded,
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
                            "${(listingData?['activityType'] ?? 'Loading').substring(0, 1).toUpperCase()}${(listingData?['activityType'] ?? 'Loading').substring(1)}",
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

            //accommodationType
            Visibility(
              visible: listingData?['accommodationType'] != null,
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
                      Icons.house_rounded,
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
                            "${(listingData?['accommodationType'] ?? 'Loading').substring(0, 1).toUpperCase()}${(listingData?['accommodationType'] ?? 'Loading').substring(1)}",
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

            //ageRestrictions
            Visibility(
              visible: listingData?['ageRestrictions'] != null,
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
                      Icons.people,
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
                            "${(listingData?['ageRestrictions'] ?? 'Loading').substring(0, 1).toUpperCase()}${(listingData?['ageRestrictions'] ?? 'Loading').substring(1)}",
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

            //duration
            Visibility(
              visible: listingData?['duration'] != null,
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
                      Icons.hourglass_bottom_rounded,
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
                            "${(listingData?['duration'] ?? 'Loading').substring(0, 1).toUpperCase()}${(listingData?['duration'] ?? 'Loading').substring(1)}",
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
                  20,
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

            //activity tags
            Visibility(
              visible: listingData?['activities'] != null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  15,
                  25,
                  20,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        15,
                      ),
                      child: Text("Activity Tags",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          )),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 5.0,
                                runSpacing: 0.0,
                                children: (listingData?['activities']
                                            as List<dynamic>?)
                                        ?.map<Widget>((activities) {
                                      return Chip(
                                        label: Text(
                                          activities.toString(),
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
                  ],
                ),
              ),
            ),

            //amenities tag
            Visibility(
              visible: listingData?['amenities'] != null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  15,
                  25,
                  20,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        15,
                      ),
                      child: Text("Amenities",
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          )),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 5.0,
                                runSpacing: 0.0,
                                children: (listingData?['amenities']
                                            as List<dynamic>?)
                                        ?.map<Widget>((amenities) {
                                      return Chip(
                                        label: Text(
                                          amenities.toString(),
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
                  ],
                ),
              ),
            ),

            // Tickets
            Visibility(
              visible: listingData?['ticketPrice'] != null &&
                  listingData?['ticketPrice'] is List<dynamic>,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  15,
                  25,
                  25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        15,
                      ),
                      child: Text(
                        "Tickets",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ),
                    // Iterate over each ticket element
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (listingData?['ticketPrice'] as List<dynamic>?)
                              ?.map<Widget>((ticket) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  // Display ticket name
                                  Expanded(
                                    child: Text(
                                      ticket['name'] ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: Colors.grey[00],
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                  // Display ticket price
                                  Text(
                                    'RM${ticket['price'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: Colors.grey[00],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ],
                ),
              ),
            ),

            // Room Types
            Visibility(
              visible: listingData?['roomTypes'] != null &&
                  listingData?['roomTypes'] is List<dynamic>,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  15,
                  25,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        0,
                        0,
                        15,
                      ),
                      child: Text(
                        "Room Types/Whole House",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ),
                    // Iterate over each room type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (listingData?['roomTypes'] as List<dynamic>?)
                              ?.map<Widget>((roomType) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display room type name (underline and semi-bold)
                                  Text(
                                    roomType['name'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: Colors.grey[00],
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // Display price
                                  Text(
                                    'Price: RM${roomType['price'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: Colors.grey[00],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  // Display pax
                                  Text(
                                    'Pax: ${roomType['pax'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: Colors.grey[00],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  // Display bed
                                  Text(
                                    'Bed: ${roomType['bed'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: Colors.grey[00],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  // Display quantity
                                  Text(
                                    'Quantity: ${roomType['quantity'] ?? ''}',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 14,
                                      color: Colors.grey[00],
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ],
                ),
              ),
            ),
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

            // Update & delete Listing
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: Row(
                children: [
                  //Update listing
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MyButton(
                        onTap: updateListing,
                        buttonText: 'Update Listing',
                      ),
                    ),
                  ),

                  //Delete Lising
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MyButton(
                        onTap: deletelisting,
                        buttonText: 'Delete Listing',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
