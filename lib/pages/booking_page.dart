import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:kitajomvendor/models/booking_detail_class.dart';

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  late final User _currentUser;
  late final String _currentUserId;
  Future<List<BookingDetail>>? _bookingDetails;
  String _selectedFilter = 'All';
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _currentUserId = _currentUser.uid;
    _bookingDetails = _fetchBookingDetails();
  }

  Future<String> _getUsername(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (userSnapshot.exists) {
      return userSnapshot['username'];
    } else {
      return 'Unknown';
    }
  }

  void _navigateToBookingDetailsPage(
      String confirmationNumber, String userId) async {
    // Fetch the username from the 'user' collection using the userId
    String username = await _getUsername(userId);
    String dialogContent =
        "Confirmation Number:\n$confirmationNumber\n\nUsername:\n$username";

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                title: Text(
                  "Booking Details",
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 17,
                    color: darkGreen,
                  ),
                ),
                subtitle: SelectableText(
                  dialogContent,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: dialogContent));
                      Navigator.of(context).pop(); // Close the bottom sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        color: darkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<BookingDetail>> _fetchBookingDetails() async {
    List<BookingDetail> details = [];
    final bookingSnapshot =
        await FirebaseFirestore.instance.collection('booking').get();

    for (var bookingDoc in bookingSnapshot.docs) {
      var data = bookingDoc.data();
      String listingCollection =
          data['listingType'] == 'accommodation' ? 'accommodation' : 'activity';
      var listingSnapshot = await FirebaseFirestore.instance
          .collection(listingCollection)
          .doc(data['listingId'])
          .get();

      if (listingSnapshot.exists) {
        String vendorId = listingSnapshot['vendorId'];
        if (vendorId == _currentUserId) {
          BookingDetail detail = BookingDetail(
            listingName: listingSnapshot['listingName'],
            totalAmount: data['totalAmount'],
            listingType: data['listingType'],
            checkIn: formatDate(data['checkIn']),
            checkOut: formatDate(data['checkOut']),
            night: data.containsKey('night') ? data['night'].toString() : '',
            ticketType: data.containsKey('ticketType')
                ? List.from(data['ticketType'])
                : [],
            confirmationNumber: data['confirmationNumber'],
            userId: data['userId'],
          );
          details.add(detail);
        }
      }
    }

    return details;
  }

  String formatDate(String? dateTime) {
    if (dateTime != null && dateTime.isNotEmpty) {
      return dateTime.substring(
          0, 10); // Extracts the date in 'YYYY-MM-DD' format
    }
    return '';
  }

  // Filter bookings based on accommodation or activity and or month
  void _filterBookings(String filter, {String? month}) {
    setState(() {
      _selectedFilter = filter;
      _selectedMonth = month; // Set the selected month or null
    });
  }

  // Calculate total earnings
  double _calculateTotalEarnings(List<BookingDetail> bookings) {
    double total = 0.0;
    for (var booking in bookings) {
      total += double.parse(booking.totalAmount.toString());
    }
    return total;
  }

  // Check if check-in date is active or past
  String _checkBookingStatus(String checkInDate) {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('yyyy-MM-dd');
    try {
      DateTime checkIn = format.parse(checkInDate);
      DateTime checkInDateOnly =
          DateTime(checkIn.year, checkIn.month, checkIn.day);
      DateTime currentDateOnly = DateTime(now.year, now.month, now.day);
      return checkInDateOnly.isBefore(currentDateOnly) ? 'Past' : 'Active';
    } catch (e) {
      print('Error parsing date: $e');
      return 'Unknown';
    }
  }

  void _showFilterOptions(BuildContext context) async {
    // Step 1: Choose the filter type
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Filter Type",
              style: TextStyle(
                color: darkGreen,
                fontFamily: 'Lexend',
                fontSize: 17,
                fontWeight: FontWeight.w400,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('All'),
                  onTap: () => Navigator.of(context).pop('All'),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Accommodation'),
                  onTap: () => Navigator.of(context).pop('Accommodation'),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Activity'),
                  onTap: () => Navigator.of(context).pop('Activity'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedFilter != null) {
      _selectedFilter = selectedFilter;

      // Step 2: If 'All' or 'Accommodation' is chosen, allow month selection
      if (selectedFilter != 'Activity') {
        final selectedMonth = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Select Month",
                  style: TextStyle(
                    color: darkGreen,
                    fontFamily: 'Lexend',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  )),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text('All'),
                      onTap: () => Navigator.of(context).pop('All'),
                    ),
                    ...List.generate(12, (index) {
                      var date = DateTime(0, index + 1, 1);
                      String monthName = DateFormat.MMMM().format(date);
                      return GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(monthName),
                        ),
                        onTap: () => Navigator.of(context).pop(monthName),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );

        if (selectedMonth != null) {
          setState(() {
            _selectedFilter = selectedFilter;
            _selectedMonth = selectedMonth == 'All' ? null : selectedMonth;
            _bookingDetails =
                _fetchBookingDetails(); // Refresh the booking details based on the new filter
          });
        }
      } else {
        // If 'Activity' is selected, no need to select month, just refresh the list
        setState(() {
          _selectedFilter = selectedFilter;
          _selectedMonth = null; // Reset month selection
          _bookingDetails = _fetchBookingDetails();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show filter options
          _showFilterOptions(context);
        },
        child: Icon(Icons.filter_list, color: darkGreen),
        shape: CircleBorder(),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: FutureBuilder<List<BookingDetail>>(
        future: _bookingDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: darkGreen));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final bookingDetails = snapshot.data ?? [];
            // Filter bookings based on selected filter
            List<BookingDetail> filteredBookings =
                bookingDetails.where((detail) {
              // Filter by listing type
              bool matchesType = _selectedFilter == 'All' ||
                  detail.listingType.toLowerCase() ==
                      _selectedFilter.toLowerCase();

              // If a month is selected, further filter by month
              if (_selectedMonth != null &&
                  matchesType &&
                  detail.checkIn.isNotEmpty) {
                DateFormat format = DateFormat('yyyy-MM-dd');
                DateTime checkInDate = format.parse(detail.checkIn);
                // Assuming _selectedMonth is in 'January', 'February', etc. format
                DateFormat monthFormat = DateFormat('MMMM');
                String detailMonth = monthFormat.format(checkInDate);
                return detailMonth == _selectedMonth;
              }

              return matchesType;
            }).toList();
            // Calculate total earnings
            double totalEarnings = _calculateTotalEarnings(filteredBookings);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final detail = filteredBookings[index];
                      return GestureDetector(
                        onTap: () {
                          _navigateToBookingDetailsPage(
                              detail.confirmationNumber, detail.userId);
                        },
                        child: Card(
                          color: Color.fromARGB(255, 255, 250, 250),
                          margin: EdgeInsets.fromLTRB(25, 8, 25, 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.listingName,
                                  style: TextStyle(
                                    color: darkGreen,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Total Amount: RM${detail.totalAmount}',
                                  style: TextStyle(
                                      fontSize: 12, fontFamily: 'Lexend'),
                                ),
                                SizedBox(height: 4),
                                if (detail.listingType == 'accommodation')
                                  Text(
                                    'Nights: ${detail.night}\nCheck-in: ${detail.checkIn}\nCheck-out: ${detail.checkOut}',
                                    style: TextStyle(
                                        fontSize: 12, fontFamily: 'Lexend'),
                                  ),
                                if (detail.listingType != 'accommodation')
                                  Text(
                                    'Tickets: ${detail.ticketType.map((t) => t['ticketName'].toString()).join(', ')}',
                                    style: TextStyle(
                                        fontSize: 12, fontFamily: 'Lexend'),
                                  ),
                                SizedBox(height: 4),
                                if (detail.listingType == 'accommodation')
                                  Text(
                                    _checkBookingStatus(detail.checkIn),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Lexend',
                                      color:
                                          _checkBookingStatus(detail.checkIn) ==
                                                  'Active'
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    'Total Earnings: RM$totalEarnings',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
