import 'package:get/get.dart';
import 'package:sentinal/controller/video_upload.dart';

class VideoUploadBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoUploadController>(() => VideoUploadController());
  }
}
