import 'package:get/get.dart';
import '../../../../data/datasources/agenda_datasource.dart';
import '../../../../data/models/agenda_model.dart';

class AgendaController extends GetxController {
  final isLoading = false.obs;
  final agendas = <AgendaModel>[].obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadAgendas();
  }

  Future<void> loadAgendas() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await dummyGetAllAgendas();
      agendas.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
