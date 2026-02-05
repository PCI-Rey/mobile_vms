import 'package:get/get.dart';
import '../controller/approval_controller.dart';

class ApprovalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApprovalController>(() => ApprovalController());
  }
}
