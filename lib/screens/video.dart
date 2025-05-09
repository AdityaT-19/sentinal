import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentinal/bindings/video_upload.dart';
import 'package:sentinal/controller/auth.dart';
import 'package:sentinal/controller/video.dart';
import 'package:sentinal/models/video.dart';
import 'package:sentinal/screens/video_player.dart';
import 'package:sentinal/screens/video_upload.dart';
import 'package:sentinal/services/utils.dart';

class VideoListScreen extends StatelessWidget {
  VideoListScreen({super.key});

  final AuthController _authController = Get.find<AuthController>();
  final VideoController _videoController = Get.find<VideoController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Videos',
          style: TextStyle(
            color: Get.theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Get.theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Get.theme.colorScheme.onPrimary),
            onPressed: () {
              _authController.signOut();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_videoController.videos.isEmpty) {
          return Center(
            child: Text(
              'No videos available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }
        return GridView(
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Display one item per row for larger thumbnails
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 16 / 9,
          ),
          children: _videoController.videos.map((video) {
            bool isRestricted = _videoController.isVideoRestricted(video);
            
            return FutureBuilder<Uint8List?>(
              future: generateThumbnail(video.videoUrl),
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading thumbnail'));
          } else {
            return GestureDetector(
              onTap: () {
                if (!isRestricted) {
            // Navigate to video playback screen
            Get.to(
              () => VideoPlayerScreen(videoUrl: video.videoUrl),
            );
                } else {
            Get.snackbar(
              'Restricted',
              'This video is age-restricted.',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              icon: Icon(Icons.warning, color: Colors.white),
              snackPosition: SnackPosition.BOTTOM,
            );
                }
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
                ),
                child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  filterQuality: FilterQuality.high,
                ),
              ),
              if (isRestricted)
                Container(
                  decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
              child: Text(
                'Age Restricted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.center,
                  child: Icon(
              Icons.play_circle_outline,
              color: Colors.white.withOpacity(0.8),
              size: 48.0,
                  ),
                ),
              Positioned(
                bottom: 8.0,
                left: 8.0,
                right: 8.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 8.0,
                  ),
                  decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
              video.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
                ),
              ),
            );
          }
              },
            );
          }).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => VideoUploadScreen(), binding: VideoUploadBinding());
        },
        child: Icon(Icons.cloud_upload),
      ),
    );
  }
}
