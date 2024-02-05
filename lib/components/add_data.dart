import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(
    String childName,
    Uint8List file,
  ) async {
    // Construct the reference to the profilePic folder
    Reference ref = _storage.ref().child('profilePic').child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required Uint8List file,
    required String username,
    required String address,
    required String businessName,
    required String registrationNumber,
  }) async {
    String resp = "Some error has occurred";
    try {
      String uniqueFilename =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}.jpg';
      String imageUrl = await uploadImageToStorage(uniqueFilename, file);
      DocumentReference userDoc = await _firestore.collection('user').add({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'photoUrl': imageUrl,
        'role': 'vendor',
        'username': username,
      });
      await userDoc.collection('vendor').add({
        'address': address,
        'businessName': businessName,
        'registrationNumber': registrationNumber,
      });
      resp = 'Success';
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
