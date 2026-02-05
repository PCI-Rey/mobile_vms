import 'package:get/get.dart';
import '../controller/alarm_controller.dart';

class AlarmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmController>(() => AlarmController());
  }
}
