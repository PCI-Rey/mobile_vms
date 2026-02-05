import 'package:get/get.dart';
import '../controller/agenda_controller.dart';

class AgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgendaController>(() => AgendaController());
  }
}
