import 'package:get/get.dart';
import 'package:sentinal/controller/video.dart';

class VideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoController>(() => VideoController());
  }
}
