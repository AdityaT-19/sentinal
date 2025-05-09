import 'dart:typed_data';

import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

Future<Uint8List?> generateThumbnail(String videoUrl) async {
  try {
    return await VideoThumbnail.thumbnailData(
      video: videoUrl,
      headers: {'skip_zrok_interstitial': 'true'},
      imageFormat: ImageFormat.JPEG,
      // maxWidth: 128, // Adjust the size as needed
      quality: 50,
      timeMs: 20,
    );
  } catch (e) {
    print('Error generating thumbnail: $e');
    return null;
  }
  // return Future.value(Uint8List.fromList(List.generate(100, (index) => index)));
}
