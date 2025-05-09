import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sentinal/models/user.dart';

class Firestore extends GetxService {
  static Firestore get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(
    String uid,
    String email,
    String name,
    String photoUrl,
    DateTime dateOfBirth,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'dateOfBirth': dateOfBirth,
      });
    } catch (e) {
      Get.snackbar('Error creating user', e.toString());
    }
  }

  // New method for storing video metadata
  Future<void> createVideo({
    required String id,
    required String title,
    required String videoUrl,
    required String ageRestriction,
  }) async {
    try {
      await _firestore.collection('videos').doc(id).set({
        'id': id,
        'title': title,
        'videoUrl': videoUrl,
        'ageRestriction': ageRestriction,
        'uploaded_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar('Error storing video', e.toString());
    }
  }

  Stream<AppUser> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => AppUser.fromDocumentSnapshot(snapshot));
  }
}
