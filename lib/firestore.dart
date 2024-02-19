import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/pages/add_listing_page2.dart';
import 'package:kitajomvendor/pages/add_activity_listing.dart';
import 'package:kitajomvendor/pages/add_restaurant_listing.dart';
import 'package:kitajomvendor/pages/add_accommodation_listing.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/pages/add_listing_page2.dart';
import 'package:kitajomvendor/pages/add_activity_listing.dart';
import 'package:kitajomvendor/pages/add_restaurant_listing.dart';
import 'package:kitajomvendor/pages/add_accommodation_listing.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference restaurantListings =
      FirebaseFirestore.instance.collection('restaurant');
  final CollectionReference activityListings =
      FirebaseFirestore.instance.collection('activity');
  final CollectionReference accommodationListings =
      FirebaseFirestore.instance.collection('accommodation');

  Stream<List<Map<String, dynamic>>> getUserListings(String userId) {
    // Create streams for each collection
    final restaurantStream = restaurantListings
        .where('vendorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

    final activityStream = activityListings
        .where('vendorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

    final accommodationStream = accommodationListings
        .where('vendorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());

    // Merge the streams into a single stream
    return Rx.combineLatest3(
      restaurantStream,
      activityStream,
      accommodationStream,
      (restaurantListings, activityListings, accommodationListings) {
        // Combine the listings from all streams into one list
        List<Map<String, dynamic>> allListings = [];
        allListings.addAll(restaurantListings);
        allListings.addAll(activityListings);
        allListings.addAll(accommodationListings);
        return allListings;
      },
    );
  }

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

  //CREATE new activity listings
  Future<void> addActivity({
    required String uid,
    required String listingName,
    required String activityType,
    required List<String> activities,
    required String address,
    required String ageRestrictions,
    required String duration,
    required String description,
    required String openingHours,
    required String pricePoint,
    required List<Ticket> ticketPrice,
    required List<String> photos,
  }) {
    return activityListings.add(
      {
        'vendorId': uid,
        'listingName': listingName,
        'activityType': activityType,
        'listingType': "activity",
        'activities': activities,
        'address': address,
        'ageRestrictions': ageRestrictions,
        'duration': duration,
        'description': description,
        'openingHours': openingHours,
        'pricePoint': pricePoint,
        'rating': 0,
        'ticketPrice': ticketPrice
            .map((ticketPrice) => {
                  'name': ticketPrice.name,
                  'price': ticketPrice.price,
                })
            .toList(),
        'photos': photos,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isAvailable': true,
      },
    );
  }

//CREATE new accommodation listings
  Future<void> addAccommodation({
    required String uid,
    required String listingName,
    required String accommodationType,
    required List<String> amenities,
    required String address,
    required String description,
    required List<RoomTypes> roomType,
    required List<String> photos,
  }) {
    return accommodationListings.add(
      {
        'vendorId': uid,
        'listingName': listingName,
        'listingType': 'accommodation',
        'accommodationType': accommodationType,
        'amenities': amenities,
        'address': address,
        'description': description,
        'rating': 0,
        'roomTypes': roomType
            .map((roomType) => {
                  'name': roomType.name,
                  'price': roomType.price,
                  'pax': roomType.pax,
                  'bed': roomType.bed,
                  'quantity': roomType.quantity,
                })
            .toList(),
        'photos': photos,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isAvailable': true,
      },
    );
  }

  // READ restaurant listings
  Future<List<QueryDocumentSnapshot>> getRestaurantListings() async {
    QuerySnapshot querySnapshot = await restaurantListings.get();
    return querySnapshot.docs;
  }

  // READ activity listings
  Future<List<QueryDocumentSnapshot>> getActivityListings() async {
    QuerySnapshot querySnapshot = await activityListings.get();
    return querySnapshot.docs;
  }

  // READ accommodation listings
  Future<List<QueryDocumentSnapshot>> getAccommodationListings() async {
    QuerySnapshot querySnapshot = await accommodationListings.get();
    return querySnapshot.docs;
  }

  // DELETE restaurant listing
  Future<void> deleteRestaurant(String listingId) async {
    await restaurantListings.doc(listingId).delete();
  }

  // DELETE activity listing
  Future<void> deleteActivity(String listingId) async {
    await activityListings.doc(listingId).delete();
  }

  // DELETE accommodation listing
  Future<void> deleteAccommodation(String listingId) async {
    await accommodationListings.doc(listingId).delete();
  }
}
