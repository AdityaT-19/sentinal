import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sentinal/services/firestore.dart';
import 'package:sentinal/models/age_restriction.dart';
import 'package:sentinal/models/video.dart';

class VideoUploadController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final selectedVideo = Rx<File?>(null);
  final isUploading = false.obs;

  // Store details of the last uploaded video
  final lastUploadedVideo = Rx<Video?>(null);

  /// Pick a video from the gallery.
  Future<void> pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedVideo.value = File(pickedFile.path);
    }
  }

  /// Upload the video to FastAPI server and store metadata in Firestore.
  Future<void> uploadVideo(String title) async {
    if (selectedVideo.value == null) {
      Get.snackbar(
        'Error',
        'Please select a video to upload.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUploading.value = true;
    try {
      // Create a multipart request to your FastAPI endpoint.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://sential.share.zrok.io/upload/'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('file', selectedVideo.value!.path),
      );
      request.headers['skip_zrok_interstitial'] = 'true';
      // Optionally, send additional fields if needed.
      // request.fields['title'] = title;

      final response = await request.send();

      if (response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(respStr);

        // Expected FastAPI response format:
        // {
        //    "filename": "generated_filename.mp4",
        //    "age_restriction": "AR13", // or "AR18"
        //    "message": "Video uploaded and classified successfully"
        // }

        if (jsonResponse['message'] !=
            'Video uploaded and classified successfully') {
          Get.snackbar(
            'Upload Error',
            jsonResponse['message'],
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        print(jsonResponse);

        String fileName = jsonResponse['filename'];
        String ageRestrictionStr = jsonResponse['age_restriction'];
        // Print the filename and age restriction for debugging purposes.
        print('Filename: $fileName');
        print('Age Restriction String: $ageRestrictionStr');
        // Convert the age restriction string to an enum.

        AgeRestriction ageRestriction = AgeRestrictionFromMap.fromMap(
          ageRestrictionStr,
        );
        // Print the age restriction for debugging purposes.
        print('Age Restriction: $ageRestriction');
        // Construct the video URL based on your server configuration.
        String videoUrl = "https://sential.share.zrok.io/video/$fileName";

        // Store the video metadata in Firestore via the Firestore service.
        await Firestore.instance.createVideo(
          id: fileName,
          title: title,
          videoUrl: videoUrl,
          ageRestriction: ageRestrictionStr,
        );

        // Store the uploaded video's data locally.
        lastUploadedVideo.value = Video(
          id: fileName,
          title: title,
          videoUrl: videoUrl,
          ageRestriction: ageRestriction,
        );

        Get.snackbar(
          'Success',
          jsonResponse['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Upload Error',
          'Failed to upload video to the server.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
      selectedVideo.value = null;
    }
  }
}
