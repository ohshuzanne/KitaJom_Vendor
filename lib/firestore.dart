import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kitajomvendor/pages/add_activity_listing.dart';
import 'package:kitajomvendor/pages/add_accommodation_listing.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final CollectionReference restaurantListings =
      FirebaseFirestore.instance.collection('restaurant');
  final CollectionReference activityListings =
      FirebaseFirestore.instance.collection('activity');
  final CollectionReference accommodationListings =
      FirebaseFirestore.instance.collection('accommodation');

//Generating a uuid
  final uuid = Uuid();

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
    String newUuid = uuid.v4();
    return restaurantListings.doc(newUuid).set(
      {
        'vendorId': uid,
        'listingName': listingName,
        'address': address,
        'cuisine': cuisine,
        'description': description,
        'openingHours': openingHours,
        'pricePoint': pricePoint,
        'rating': 0,
        'userReviews': [],
        'photos': photos,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'isAvailable': true,
        'listingType': "restaurant",
        'listingId': newUuid,
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
  }) async {
    String newUuid = uuid.v4();
    await activityListings.doc(newUuid).set(
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
        'userReviews': [],
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
        'listingId': newUuid,
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
  }) async {
    String newUuid = uuid.v4();
    await accommodationListings.doc(newUuid).set(
      {
        'vendorId': uid,
        'listingName': listingName,
        'listingType': 'accommodation',
        'accommodationType': accommodationType,
        'amenities': amenities,
        'address': address,
        'description': description,
        'rating': 0,
        'userReviews': [],
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
        'listingId': newUuid,
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
