import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/auth_page.dart';

class UserReviewsPage extends StatefulWidget {
  final String userId;
  final String listingId;
  final String collectionName;

  const UserReviewsPage({
    Key? key,
    required this.userId,
    required this.listingId,
    required this.collectionName,
  }) : super(key: key);

  @override
  State<UserReviewsPage> createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  List<dynamic>? _userReviews;
  Map<String, TextEditingController> _replyControllers = {};

  @override
  void initState() {
    super.initState();
    fetchListingData();
  }

  void _deleteReply(String reviewId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.listingId);

      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        List<dynamic> userReviews = List.from(snapshot.data()!['userReviews']);

        // Find the review to update
        for (var reviewData in userReviews) {
          if (reviewData['reviewId'] == reviewId) {
            // Clear the vendorReply field
            reviewData['vendorReply'] = '';
            break; // Exit the loop once the review is updated
          }
        }

        // Update the document with the modified userReviews array
        await docRef.update({'userReviews': userReviews});

        // Refresh data
        fetchListingData();
      }
    } catch (e) {
      showAlertDialog(context, "Something went wrong: ${e.toString()}");
    }
  }

  void _showPhotoDialog(String photoUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: double.infinity,
          height:
              MediaQuery.of(context).size.height * 0.7, // 50% of screen height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(photoUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleReplyField(String reviewId) {
    if (_replyControllers.containsKey(reviewId)) {
      // If the reply field is already active, remove it
      _replyControllers.remove(reviewId);
    } else {
      // If the vendorReply is empty, allow the vendor to reply
      String vendorReply = _userReviews!.firstWhere(
          (review) => review['reviewId'] == reviewId)['vendorReply'];
      if (vendorReply.isEmpty) {
        _replyControllers[reviewId] =
            TextEditingController(); // Initialize TextEditingController for this review
      } else {
        // If vendorReply is not empty, show Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reply already exists'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitReply(
      String listingId, String reviewId, String reply) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(listingId);

      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        List<dynamic> userReviews = List.from(snapshot.data()!['userReviews']);

        // Find the review to update
        for (var reviewData in userReviews) {
          if (reviewData['reviewId'] == reviewId) {
            // Update the vendorReply field of the found review
            reviewData['vendorReply'] = reply;
            break; // Exit the loop once the review is updated
          }
        }

        // Update the document with the modified userReviews array
        await docRef.update({'userReviews': userReviews});

        // Clear text controller and remove reply field controller
        _replyControllers.remove(reviewId);
        // Refresh data
        fetchListingData();
      }
    } catch (e) {
      showAlertDialog(context, "Something went wrong: ${e.toString()}");
    }
  }

  Widget _buildReplyField(String reviewId) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Adjust based on your layout needs
        children: [
          Flexible(
            child: Container(
              width: 200,
              child: TextField(
                controller: _replyControllers[reviewId],
                decoration: InputDecoration(
                  hintText: "Type your reply here",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: darkGreen),
                  ),
                ),
              ),
            ),
            fit: FlexFit.loose, // Use loose fit
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              String reply = _replyControllers[reviewId]!.text;
              _submitReply(widget.listingId, reviewId, reply);
            },
          ),
        ],
      ),
    );
  }

  Widget starRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      Icon icon;
      if (i <= rating) {
        icon = Icon(Icons.star, color: Colors.yellow.shade700, size: 25);
      } else if (i - rating < 1 && i > rating) {
        // This will add a half star if the rating is not a whole number and is less than the next whole number
        icon = Icon(Icons.star_half, color: Colors.yellow.shade700, size: 25);
      } else {
        icon = Icon(Icons.star_border, color: Colors.grey, size: 25);
      }
      stars.add(icon);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
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

  Future<void> fetchListingData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.listingId)
          .get();

      if (snapshot.exists) {
        List<dynamic> reviewsWithUsernames = [];
        List<dynamic> userReviews =
            List.from(snapshot.data()?['userReviews'] ?? []);

        // Iterate over each review to fetch username using userId
        for (var review in userReviews) {
          String userId = review['userId'];
          // Fetch the username from the 'user' collection
          var userSnapshot = await FirebaseFirestore.instance
              .collection('user')
              .doc(userId)
              .get();

          String username = userSnapshot.data()?['username'] ?? 'Unknown User';
          // Add the username to the review map
          review['username'] = username;
          reviewsWithUsernames.add(review);
        }

        setState(() {
          _userReviews = reviewsWithUsernames;
        });
      }
    } catch (error) {
      showAlertDialog(
          context, "Something went wrong - please try again later.");
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: darkGreen,
        ),
        title: Center(
          child: Text(
            'User Reviews',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 18,
              color: darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _userReviews == null
          ? Center(child: CircularProgressIndicator())
          : _userReviews!.isEmpty
              ? Center(child: Text('No user reviews available'))
              : Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
                  child: ListView.builder(
                    itemCount: _userReviews?.length ?? 0,
                    itemBuilder: (context, index) {
                      final review = _userReviews![index];
                      String reviewId = review['reviewId'];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    review['username'] ??
                                        'Unknown User', // Assuming username is fetched and added
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lexend',
                                      fontSize: 16,
                                      color: darkGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  starRating(review['rating'].toDouble()),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(review['description']),
                              SizedBox(height: 10),
                              // Check if there are any photos to display
                              if (review['photoUrl'] != null &&
                                  review['photoUrl'].isNotEmpty)
                                Container(
                                  height:
                                      100.0, // Adjust based on your design needs
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: review['photoUrl'].length,
                                    itemBuilder: (context, photoIndex) {
                                      String photoUrl =
                                          review['photoUrl'][photoIndex];
                                      return GestureDetector(
                                        onTap: () => _showPhotoDialog(
                                            photoUrl), // Implement this method
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Image.network(photoUrl),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.reply),
                                    onPressed: () =>
                                        _toggleReplyField(reviewId),
                                  ),
                                  if (_replyControllers.containsKey(reviewId))
                                    _buildReplyField(reviewId),
                                ],
                              ),
                              Visibility(
                                // Check if vendorReply is not null and not an empty string
                                visible: review['vendorReply'] != null &&
                                    review['vendorReply'].isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    0,
                                    6,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'You replied: ${review['vendorReply']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          // Implement function to delete reply
                                          _deleteReply(reviewId);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
