import 'package:sentinal/models/age_restriction.dart';

class Video {
  final String id;
  final String title;
  final String videoUrl;
  final AgeRestriction ageRestriction;

  Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.ageRestriction,
  });

  factory Video.fromMap(Map<String, dynamic> data) {
    return Video(
      id: data['id'],
      title: data['title'],
      videoUrl: data['videoUrl'],
      ageRestriction: AgeRestrictionFromMap.fromMap(data['ageRestriction']),
    );
  }
}
