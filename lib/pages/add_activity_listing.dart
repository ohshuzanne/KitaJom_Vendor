import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'package:kitajomvendor/controller/firestore.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/components/activity_type_dropdown.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/components/mylongtextfield.dart';

class ActivityListingFields extends StatefulWidget {
  final VoidCallback pickAndUploadImages;
  final String userId;
  final List<String> imageUrls;
  const ActivityListingFields({
    Key? key,
    required this.pickAndUploadImages,
    required this.userId,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _ActivityListingFieldsState createState() => _ActivityListingFieldsState();
}

class Ticket {
  String name;
  double price;
  Ticket({required this.name, required this.price});
}

class _ActivityListingFieldsState extends State<ActivityListingFields> {
  final user = FirebaseAuth.instance.currentUser!;

  //variables and controllers
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String activityTypeValue = '';
  List<String> activities = [];
  List<String> activitiesSelected = [];
  TextEditingController _ageRestrictionsController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _openingHoursController = TextEditingController();
  TextEditingController _currentTicketNameController = TextEditingController();
  TextEditingController _currentTicketPriceController = TextEditingController();
  String pricePointValue = '';
  List<Ticket> tickets = [];
  List<Ticket> savedTickets = [];
  FirestoreService firestoreService = FirestoreService();

  void addTicket() {
    setState(() {
      tickets.add(Ticket(name: '', price: 0.0));
    });
  }

  // Function to save ticket information
  void _saveTicket(String name, String price) {
    if (name.isNotEmpty && price.isNotEmpty) {
      setState(() {
        Ticket newTicket =
            Ticket(name: name, price: double.tryParse(price) ?? 0.0);
        savedTickets
            .add(newTicket); // Add the ticket to the list of saved tickets
      });
      // Clear the text fields after saving
      _currentTicketNameController.clear();
      _currentTicketPriceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //illustration
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset('lib/images/57.png'),
          ),
        ),

        //Spacing
        const SizedBox(height: 20),

        //listingName field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            0,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Activity Name",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyTextField(
          controller: _listingNameController,
          hintText: "eg. KitaPlay Waterpark",
          obscureText: false,
        ),

        //dropdown menu for activityType field
        Padding(
          padding: const EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activity Type",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  35,
                  15,
                  35,
                  6,
                ),
                child: SizedBox(
                  width: 300,
                  child: ActivityTypeDropdown(
                    onChanged: (value) {
                      activityTypeValue = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        //section for activity tags
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Activity Tags",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        //selected activity tags
        Wrap(
          children: List.generate(
            activitiesSelected.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    activitiesSelected[index],
                    style: TextStyle(color: darkGreen),
                  ),
                  backgroundColor: Colors.white,
                  deleteIcon: Icon(Icons.close),
                  deleteIconColor: darkGreen,
                  onDeleted: () {
                    setState(() {
                      activitiesSelected.removeAt(index);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: darkGreen,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // Add an empty string to the activities tag list
                activities.add('');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Add a new activity tag',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // List of activity tag text fields
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            TextFormField(
                              onChanged: (value) {
                                // Update the cuisine tag in the list when text changes
                                activities[index] = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  // Add border decoration
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                      color: darkGreen), // Dark green outline
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: darkGreen,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                fillColor: Colors.grey[200],
                                filled: true,
                                hintText: 'Activity Tag',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                labelText: activities[index].isEmpty
                                    ? 'Activity Tag'
                                    : null,
                                labelStyle: TextStyle(
                                  color: darkGreen.withOpacity(0.5),
                                  fontSize: 14,
                                  fontFamily: 'Lexend',
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    activitiesSelected.add(activities[index]);
                                    activities.removeAt(index);
                                  });
                                },
                                icon: Icon(Icons.check),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        //address field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Activity Address",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyLongTextField(
          controller: _addressController,
          hintText: "eg. Jalan Gambang",
        ),

        //age restriction field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Age Restriction",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyTextField(
          controller: _ageRestrictionsController,
          hintText: "eg. >5 years old",
          obscureText: false,
        ),

        //duration field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Activity Duration",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyTextField(
          controller: _durationController,
          hintText: "Average time spent at your activity?",
          obscureText: false,
        ),

        //description field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Activity Description",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyLongTextField(
          controller: _descriptionController,
          hintText: "e.g. An amazing atmosphere...",
        ),

        //openingHours field
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Activity Opening Hours",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        MyTextField(
          controller: _openingHoursController,
          hintText: "IN THIS FORMAT: HH:MMam/pm - HH:MMam/pm",
          obscureText: false,
        ),

        //dropdown menu for pricePoint field
        Padding(
          padding: const EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Activity Price Point",
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: darkGreen,
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  35,
                  15,
                  35,
                  6,
                ),
                child: SizedBox(
                  width: 300,
                  child: PricePointDropDown(
                    onChanged: (value) {
                      pricePointValue = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        //ticket categories
        const Padding(
          padding: EdgeInsets.fromLTRB(
            35,
            10,
            35,
            6,
          ),
          child: Row(
            children: [
              Text(
                "Ticket Categories",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        // Display list of ticket categories as chips
        Wrap(
          children: List.generate(savedTickets.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                  label: Text(
                    savedTickets[index].name,
                    style: TextStyle(
                      color: darkGreen,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  deleteIcon: Icon(Icons.close),
                  deleteIconColor: darkGreen,
                  onDeleted: () {
                    setState(() {
                      savedTickets.removeAt(index);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(color: darkGreen),
                  )),
            );
          }),
        ),
        // List of text fields for ticket name and price
        Padding(
          padding: const EdgeInsets.fromLTRB(35, 10, 35, 0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller:
                              TextEditingController(text: tickets[index].name),
                          onChanged: (value) {
                            tickets[index].name = value;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Ticket Name',
                            labelStyle: TextStyle(
                              color: darkGreen,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: darkGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                              text: tickets[index].price.toString()),
                          onChanged: (value) {
                            tickets[index].price =
                                double.tryParse(value) ?? 0.0;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            labelStyle: TextStyle(
                              color: darkGreen,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: darkGreen),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () {
                          _saveTicket(tickets[index].name,
                              tickets[index].price.toString());
                          setState(() {
                            tickets.removeAt(index);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                        ),
                        child: const Text('Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            )),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // Add a button to add a new ticket
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              addTicket();
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreen),
            child: const Text(
              'Add a new ticket',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        //uploadimages
        const Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: darkGreen,
                ),
              ),
              //middle text
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Text(
                  "Upload your photo",
                  style: TextStyle(
                    color: darkGreen,
                    fontFamily: 'Lexend',
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 0.5,
                  color: darkGreen,
                ),
              )
            ],
          ),
        ),

        IconButton(
          onPressed: widget.pickAndUploadImages,
          icon: const Icon(Icons.camera_alt),
          iconSize: 36,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(35, 0, 35, 10),
          child: Text(
            "Your images will appear here",
            style: TextStyle(
              color: Colors.grey.withOpacity(0.9),
              fontStyle: FontStyle.italic,
              fontFamily: 'Lexend',
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            0,
            0,
            0,
            10,
          ),
          child: SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                widget.imageUrls.length,
                (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        //save button
        CustomButton(
          onPressed: () async {
            String listingName = _listingNameController.text;
            String address = _addressController.text;
            String ageRestriction = _ageRestrictionsController.text;
            String duration = _durationController.text;
            String description = _descriptionController.text;
            String openingHours = _openingHoursController.text;

            if (listingName.isNotEmpty &&
                address.isNotEmpty &&
                description.isNotEmpty &&
                openingHours.isNotEmpty) {
              // Save restaurant information to Firestore
              await firestoreService.addActivity(
                uid: widget.userId,
                listingName: listingName,
                activityType: activityTypeValue,
                activities: activitiesSelected,
                address: address,
                ageRestrictions: ageRestriction,
                duration: duration,
                description: description,
                openingHours: openingHours,
                pricePoint: pricePointValue,
                ticketPrice: savedTickets,
                photos: widget.imageUrls,
              );
              _listingNameController.clear();
              _addressController.clear();
              _descriptionController.clear();
              _openingHoursController.clear();

              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            } else {}
          },
          text: "Add Activity",
        ),

        //spacing at bottom page
        const SizedBox(height: 100),
      ],
    );
  }
}
