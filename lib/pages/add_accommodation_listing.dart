import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitajomvendor/utils/colors.dart';
import 'package:kitajomvendor/components/mytextfield.dart';
import 'package:kitajomvendor/components/pricepoint_dropdown.dart';
import 'package:kitajomvendor/firestore.dart';
import 'package:kitajomvendor/components/mybutton.dart';
import 'package:kitajomvendor/components/mylongtextfield.dart';
import 'package:kitajomvendor/components/activity_type_dropdown.dart';
import 'package:kitajomvendor/components/accommodation_type_dropdown.dart';
import 'package:kitajomvendor/pages/home_page.dart';

class AccommodationListingFields extends StatefulWidget {
  final VoidCallback pickAndUploadImages;
  final String userId;
  final List<String> imageUrls;
  const AccommodationListingFields({
    Key? key,
    required this.pickAndUploadImages,
    required this.userId,
    required this.imageUrls,
  }) : super(key: key);

  @override
  _AccommodationListingFieldsState createState() =>
      _AccommodationListingFieldsState();
}

class RoomTypes {
  String name;
  double price;
  int pax;
  String bed;
  int quantity;
  RoomTypes({
    required this.name,
    required this.price,
    required this.pax,
    required this.bed,
    required this.quantity,
  });
}

class _AccommodationListingFieldsState
    extends State<AccommodationListingFields> {
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController _listingNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String accommodationTypeValue = '';
  List<String> amenities = [];
  List<String> amenitiesSelected = [];
  TextEditingController _descriptionController = TextEditingController();
  List<RoomTypes> roomTypes = [];
  List<RoomTypes> savedRoomTypes = [];
  TextEditingController _currentRoomTypeNameController =
      TextEditingController();
  TextEditingController _currentRoomTypePriceController =
      TextEditingController();
  TextEditingController _currentRoomTypePaxController = TextEditingController();
  TextEditingController _currentRoomTypeBedController = TextEditingController();
  TextEditingController _currentRoomTypeQuantityController =
      TextEditingController();
  FirestoreService firestoreService = FirestoreService();

  void addRoomType() {
    setState(() {
      roomTypes.add(RoomTypes(
        name: '',
        price: 0.0,
        pax: 0,
        bed: '',
        quantity: 0,
      ));
    });
  }

  void _saveRoomType(
      String name, String price, String pax, String bed, String quantity) {
    if (name.isNotEmpty &&
        price.isNotEmpty &&
        pax.isNotEmpty &&
        bed.isNotEmpty &&
        quantity.isNotEmpty) {
      setState(() {
        RoomTypes newRoomType = RoomTypes(
            name: name,
            price: double.tryParse(price) ?? 0.0,
            pax: int.tryParse(pax) ?? 0,
            bed: bed,
            quantity: int.tryParse(quantity) ?? 0);
        savedRoomTypes.add(newRoomType);
      });
      _currentRoomTypeNameController.clear();
      _currentRoomTypePriceController.clear();
      _currentRoomTypePaxController.clear();
      _currentRoomTypeBedController.clear();
      _currentRoomTypeQuantityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //illustration for accommodation
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset('lib/images/58.png'),
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
                "Accommodation Name",
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
          hintText: "eg. KitaRest AirBnB",
          obscureText: false,
        ),

        //dropdown menu for accommodationType field
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
              const Text(
                "Accommodation Type",
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
                  child: AccommodationTypeDropdown(
                    onChanged: (value) {
                      accommodationTypeValue = value;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        //section for amenities tags
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
                "Amenities Available Tags",
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ),

        //selected amenities tags
        Wrap(
          children: List.generate(
            amenitiesSelected.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(
                    amenitiesSelected[index],
                    style: TextStyle(color: darkGreen),
                  ),
                  backgroundColor: Colors.white,
                  deleteIcon: Icon(Icons.close),
                  deleteIconColor: darkGreen,
                  onDeleted: () {
                    setState(() {
                      amenitiesSelected.removeAt(index);
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

        //button to add new amenities tag
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                // Add an empty string to the activities tag list
                amenities.add('');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Add a new amenity tag',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),

        //list of amenitites text fields
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: amenities.length,
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
                                amenities[index] = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Field is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide:
                                      const BorderSide(color: darkGreen),
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
                                hintText: 'Amenity',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                labelText:
                                    amenities[index].isEmpty ? 'Amenity' : null,
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
                                    amenitiesSelected.add(amenities[index]);
                                    amenities.removeAt(index);
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

        //address
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
                "Accommodation Address",
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
          hintText: "eg. Jalan Puchong Prima",
        ),

//description
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
                "Accommodation description",
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
          hintText: "A very comfortable stay with 6 rooms and...",
        ),
      ],
    );
  }
}




//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         //illustration
//         Center(
//           child: Container(
//             width: 250,
//             height: 250,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Image.asset('lib/images/57.png'),
//           ),
//         ),