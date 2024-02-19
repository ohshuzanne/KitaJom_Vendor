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

class FirestoreService {
  final CollectionReference restaurantListings =
      FirebaseFirestore.instance.collection('restaurant');
  final CollectionReference activityListings =
      FirebaseFirestore.instance.collection('activity');
  final CollectionReference accommodationListings =
      FirebaseFirestore.instance.collection('accommodation');

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
}
