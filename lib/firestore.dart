import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference restaurantListings =
      FirebaseFirestore.instance.collection('restaurant');

  //CREATE new restaurant listings
  Future<void> addRestaurant({
    required String uid,
    required String listingName,
    required String address,
    required List<String> cuisine,
    required String description,
    required String openingHours,
    required String pricePoint,
    required List<String> photos,
  }) {
    return restaurantListings.add(
      {
        'vendorId': uid,
        'listingName': listingName,
        'address': address,
        'cuisine': cuisine,
        'description': description,
        'openingHours': openingHours,
        'pricePoint': pricePoint,
        'rating': 0,
        'photos': photos,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isAvailable': true,
        'listingType': "restaurant",
      },
    );
  }
}
