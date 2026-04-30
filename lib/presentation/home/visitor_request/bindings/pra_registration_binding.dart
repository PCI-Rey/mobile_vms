import 'package:get/get.dart';
import '../controllers/pra_registration_controller.dart';

class PraRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    // fenix:true = controller is re-created fresh every time the binding is loaded,
    // so employee/host/site data is always re-fetched with the current token.
    Get.put(PraRegistrationController(), permanent: false);
  }
}
