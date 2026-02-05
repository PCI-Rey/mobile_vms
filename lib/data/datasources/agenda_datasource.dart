
import '../models/agenda_model.dart';
import '../models/visitor_model.dart';


/// Simulasi fetch semua agenda
Future<List<AgendaModel>> dummyGetAllAgendas() async {
  await Future.delayed(const Duration(milliseconds: 1200));
  return dummyAgendas;
}

/// Simulasi fetch agenda by ID
Future<AgendaModel?> dummyGetAgendaById(String id) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  try {
    return dummyAgendas.firstWhere((agenda) => agenda.id == id);
  } catch (e) {
    return null;
  }
}

/// Simulasi create agenda baru
Future<bool> dummyCreateAgenda(AgendaModel newAgenda) async {
  await Future.delayed(const Duration(seconds: 2));
  
  // Simulasi success/fail (90% success rate)
  final success = DateTime.now().millisecond % 10 != 0;
  
  if (success) {
    // Dalam implementasi nyata, ini akan save ke database
    print('Agenda berhasil dibuat: ${newAgenda.id}');
    return true;
  } else {
    throw Exception('Gagal membuat agenda. Silakan coba lagi.');
  }
}

/// Simulasi update agenda
Future<bool> dummyUpdateAgenda(String agendaId, AgendaModel updatedAgenda) async {
  await Future.delayed(const Duration(milliseconds: 1500));
  
  // Cari agenda yang akan diupdate
  final exists = dummyAgendas.any((agenda) => agenda.id == agendaId);
  
  if (!exists) {
    throw Exception('Agenda dengan ID $agendaId tidak ditemukan');
  }
  
  // Simulasi update success
  print('Agenda $agendaId berhasil diupdate');
  return true;
}

/// Simulasi delete agenda
Future<bool> dummyDeleteAgenda(String agendaId) async {
  await Future.delayed(const Duration(milliseconds: 1000));
  
  final exists = dummyAgendas.any((agenda) => agenda.id == agendaId);
  
  if (!exists) {
    throw Exception('Agenda dengan ID $agendaId tidak ditemukan');
  }
  
  print('Agenda $agendaId berhasil dihapus');
  return true;
}



final dummyAgendas = [
  AgendaModel(
    id: '1',
    jenis: 'delivery',
    picOrHost: 'Siti Maesaroh',
    destination: 'Gudang Cabang Bandung',
    visitStart: DateTime(2025, 8, 2, 14, 0),
    visitEnd: DateTime(2025, 8, 2, 15, 30),
    visitors: [
      VisitorModel(
        name: 'Eko',
        email: 'eko@example.com',
        phone: '083812345678',
        organisation: 'JNE Express',
        gender: 'male',
        nik: '3301050101010004',
        status: 'deny',
        checkTime: '2025-08-01 10:00:00',
      ),
    ],
  ),
  AgendaModel(
    id: '2',
    jenis: 'occassion',
    picOrHost: 'Andi Wijaya',
    destination: 'Aula Lantai 3',
    visitStart: DateTime(2025, 8, 3, 10, 0),
    visitEnd: DateTime(2025, 8, 3, 13, 0),
    visitors: [
      VisitorModel(
        name: 'Lisa',
        email: 'lisa@example.com',
        phone: '085612345678',
        organisation: 'Komunitas IT Indonesia',
        gender: 'female',
        nik: '3210050101010005',
        status: 'checkin',
        checkTime: '2025-08-01 10:00:00',
      ),
      VisitorModel(
        name: 'Tommy',
        email: 'tommy@example.com',
        phone: '082134567891',
        organisation: 'TechnoLab',
        gender: 'male',
        nik: '3201040202020006',
        status: 'checkin',
        checkTime: '2025-08-01 10:00:00',
      ),
    ],
  ),
  AgendaModel(
    id: '3',
    jenis: 'meeting',
    picOrHost: 'Budi Santoso',
    destination: 'Kantor Pusat Jakarta',
    visitStart: DateTime(2025, 8, 1, 9, 0),
    visitEnd: DateTime(2025, 8, 1, 11, 0),
    visitors: [
      VisitorModel(
        name: 'Ani',
        email: 'ani@example.com',
        phone: '081234567890',
        organisation: 'PT Teknologi Nusantara',
        gender: 'female',
        nik: '3174020101010002',
        status: 'checkin',
        checkTime: '2025-08-01 10:00:00',
      ),
      VisitorModel(
        name: 'Rudi',
        email: 'rudi@example.com',
        phone: '082112345678',
        organisation: 'CV Karya Abadi',
        gender: 'male',
        nik: '3271030202020003',
        status: 'checkout',
        checkTime: '2025-08-01 10:00:00',
      ),
    ],
  ),
];


