import 'package:flutter/material.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'package:kitajomvendor/firestore.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/pages/home_page.dart';
import 'package:kitajomvendor/components/mylongtextfield.dart';

class RestaurantListingFields extends StatefulWidget {
  final VoidCallback pickAndUploadImages;
  final String userId;
  final List<String> imageUrls;
  const RestaurantListingFields({
    Key? key,
    required this.pickAndUploadImages,
    required this.userId,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _RestaurantListingFieldsState createState() =>
      _RestaurantListingFieldsState();
}

//restaurant listing fields
class _RestaurantListingFieldsState extends State<RestaurantListingFields> {
  //variables and controllers
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  List<String> cuisine = [];
  List<String> selectedCuisineTags = [];
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _openingHoursController = TextEditingController();
  String pricePointValue = '';
  FirestoreService firestoreService = FirestoreService();

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
            child: Image.asset('lib/images/56.png'),
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
                "Restaurant Name",
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
          hintText: "eg. KitaMakan Bistro and Bar",
          obscureText: false,
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
                "Restaurant Address",
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
          hintText: "eg. No.3, Jalan Putra 3, Lorong 3, 333333 KL",
        ),

        //section for cuisine tags
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
                "Cuisine Tags",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        //selected cuisine tags
        Wrap(
          children: List.generate(selectedCuisineTags.length, (index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(selectedCuisineTags[index]),
                  onDeleted: () {
                    setState(() {
                      selectedCuisineTags.removeAt(index);
                    });
                  },
                ));
          }),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // Add an empty string to the cuisineTags list
                cuisine.add('');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Add a new cuisine tag',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // List of cuisine tag text fields
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cuisine.length,
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
                                cuisine[index] = value;
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
                                  borderSide: BorderSide(
                                      color: darkGreen), // Dark green outline
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: darkGreen),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                fillColor: Colors.grey[200],
                                filled: true,
                                hintText: 'Cuisine ${index + 1}',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                labelText: cuisine[index].isEmpty
                                    ? 'Cuisine ${index + 1}'
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
                                    selectedCuisineTags.add(cuisine[index]);
                                    cuisine.removeAt(index);
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
                "Restaurant Description",
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
                "Restaurant Opening Hours",
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
                "Restaurant Price Point",
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
          icon: Icon(Icons.camera_alt),
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
            String description = _descriptionController.text;
            String openingHours = _openingHoursController.text;

            if (listingName.isNotEmpty &&
                address.isNotEmpty &&
                description.isNotEmpty &&
                openingHours.isNotEmpty) {
              // Save restaurant information to Firestore
              await firestoreService.addRestaurant(
                uid: widget.userId,
                listingName: listingName,
                address: address,
                cuisine: selectedCuisineTags,
                description: description,
                openingHours: openingHours,
                pricePoint: pricePointValue,
                photos: widget.imageUrls,
              );

              // Clear text fields
              _listingNameController.clear();
              _addressController.clear();
              _descriptionController.clear();
              _openingHoursController.clear();

              // Check if the widget is mounted before calling setState
              if (mounted) {
                // Navigate to the homepage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            } else {
              // Show an error message or handle empty fields appropriately
            }
          },
          text: "Add Restaurant",
        ),

        //spacing at bottom page
        const SizedBox(height: 100),
      ],
    );
  }
}
