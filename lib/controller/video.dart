import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentinal/models/user.dart';
import 'package:sentinal/models/video.dart';
import 'package:sentinal/models/age_restriction.dart';

class VideoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<Video> videos = <Video>[].obs;
  Rx<AppUser> currentUser = AppUser.empty.obs;
  // List<Video> mockVideos = [
  //   Video(
  //     id: '1',
  //     title: 'Sample Video 1',
  //     videoUrl: 'https://download.samplelib.com/mp4/sample-10s.mp4',
  //     ageRestriction: AgeRestriction.AR13,
  //   ),
  //   Video(
  //     id: '2',
  //     title: 'Sample Video 2',
  //     videoUrl:
  //         'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  //     ageRestriction: AgeRestriction.AR18,
  //   ),
  //   // Add more videos as needed
  //   Video(
  //     id: '3',
  //     title: 'Sample Video 3',
  //     videoUrl:
  //         'https://www.sample-videos.com/video321/mp4/720/big_buck_bunny_720p_5mb.mp4',
  //     ageRestriction: AgeRestriction.UR,
  //   ),
  // ];

  @override
  void onInit() async {
    super.onInit();
    await fetchCurrentUser();
    fetchVideos();
  }

  Future<void> fetchCurrentUser() async {
    User? user = _auth.currentUser;
    print('User: $user');
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      currentUser.value = AppUser.fromDocumentSnapshot(userDoc);
    }
  }

  void fetchVideos() async {
    _firestore.collection('videos').snapshots().listen((videoSnapshot) {
      videos.value =
          videoSnapshot.docs.map((doc) => Video.fromMap(doc.data())).toList();
    });
    // videos.value =
    //     videoSnapshot.docs
    //         .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>))
    //         .toList();
  }

  // void fetchVideos() {
  //   videos.value = mockVideos;
  // }

  bool isVideoRestricted(Video video) {
    // if (currentUser.value.uid.isEmpty) {
    //   return false;
    // }
    print('User dob: ${currentUser.value.dateOfBirth}');
    int userAge = currentUser.value.age;
    print('User age: $userAge');
    switch (video.ageRestriction) {
      case AgeRestriction.AR13:
        return userAge < 13;
      case AgeRestriction.AR18:
        return userAge < 18;
      case AgeRestriction.UR:
        return false;
    }
  }
}
