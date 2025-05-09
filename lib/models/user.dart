import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final DateTime dateOfBirth;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.dateOfBirth,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    print(data);
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      dateOfBirth: DateTime.parse(
        (data['dateOfBirth'] as Timestamp).toDate().toString(),
      ),
    );
  }

  int get age {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month) {
      return age - 1;
    }
    if (now.month == dateOfBirth.month && now.day < dateOfBirth.day) {
      return age - 1;
    }
    return age;
  }

  static AppUser get empty => AppUser(
    uid: '',
    email: '',
    name: '',
    photoUrl: '',
    dateOfBirth: DateTime.now(),
  );

  AppUser.fromDocumentSnapshot(DocumentSnapshot snapshot)
    : uid = FirebaseAuth.instance.currentUser?.uid ?? snapshot['uid'],
      email = snapshot['email'],
      name = snapshot['name'],
      photoUrl = snapshot['photoUrl'],
      dateOfBirth = DateTime.parse(
        (snapshot['dateOfBirth'] as Timestamp).toDate().toString(),
      ) {
    print(snapshot);
  }
}
