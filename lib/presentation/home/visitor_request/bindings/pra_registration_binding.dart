import 'package:get/get.dart';
import '../controllers/pra_registration_controller.dart';

class PraRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PraRegistrationController());
  }
}
