import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentinal/controller/video_upload.dart';
import 'package:sentinal/models/age_restriction.dart';
import 'package:sentinal/services/utils.dart';

class VideoUploadScreen extends StatelessWidget {
  final VideoUploadController _controller = Get.find();
  final TextEditingController _titleController = TextEditingController();

  final Map<String, String> ageRestrictionDescriptions = {
    'AR13':
        'Suitable for ages 13 and above. Some content may not be appropriate for younger viewers.',
    'AR18':
        'Strictly for adults. This content is restricted to users 18 and older.',
  };

  @override
  Widget build(BuildContext context) {
    // Retrieve theme colors from GetX theme.
    final primaryColor = Get.theme.colorScheme.primary;
    final onPrimary =
        Get.theme.colorScheme.onPrimary; // Contrast for text/icons
    final secondaryColor = Get.theme.colorScheme.secondary;
    final errorColor = Get.theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: onPrimary),
            onPressed: () {
              // Add your logout logic here.
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // If a video was successfully uploaded, show only the uploaded video's details.
          if (_controller.lastUploadedVideo.value != null) {
            final video = _controller.lastUploadedVideo.value!;
            String ageRestrictionKey =
                video.ageRestriction.toString().split('.').last;
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video thumbnail
                  FutureBuilder<Uint8List?>(
                    future: generateThumbnail(video.videoUrl),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return Container(
                          height: 220,
                          color: Colors.grey[300],
                          child: Center(child: Text('Error loading thumbnail')),
                        );
                      } else {
                        return Container(
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12.0),
                            ),
                            image: DecorationImage(
                              image: MemoryImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Title
                        Text(
                          video.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Age Restriction Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                video.ageRestriction == AgeRestriction.AR18
                                    ? errorColor
                                    : secondaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Age Restriction: $ageRestrictionKey',
                            style: TextStyle(
                              color: Get.theme.colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Age Restriction Description
                        Text(
                          ageRestrictionDescriptions[ageRestrictionKey] ??
                              'No description available.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Otherwise, show the upload form.
            return Column(
              children: [
                // Video title input
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Video Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                // Video preview or a placeholder message
                Obx(() {
                  if (_controller.selectedVideo.value != null) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'Video Selected:\n${_controller.selectedVideo.value!.path.split('/').last}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(child: Text('No video selected.')),
                    );
                  }
                }),
                SizedBox(height: 20),
                // Button to pick a video from the gallery.
                ElevatedButton.icon(
                  onPressed: _controller.pickVideo,
                  icon: Icon(Icons.video_library, color: onPrimary),
                  label: Text('Select Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: onPrimary,
                  ),
                ),
                SizedBox(height: 20),
                // Upload button with loading indicator.
                Obx(() {
                  return ElevatedButton.icon(
                    onPressed:
                        _controller.isUploading.value
                            ? null
                            : () {
                              String title = _titleController.text.trim();
                              if (title.isNotEmpty) {
                                _controller.uploadVideo(title);
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please enter a video title',
                                  backgroundColor: errorColor,
                                  colorText: Colors.white,
                                );
                              }
                            },
                    icon:
                        _controller.isUploading.value
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                            : Icon(Icons.cloud_upload, color: onPrimary),
                    label: Text(
                      _controller.isUploading.value
                          ? 'Uploading...'
                          : 'Upload Video',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: onPrimary,
                    ),
                  );
                }),
              ],
            );
          }
        }),
      ),
    );
  }
}
