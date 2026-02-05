import '../../data/models/visitor_model.dart';

class AgendaModel {
  final String id;
  final String jenis; // occassion, meeting, delivery
  final String picOrHost;
  final String destination;
  final DateTime visitStart;
  final DateTime visitEnd;
  final List<VisitorModel> visitors;

  AgendaModel({
    required this.id,
    required this.jenis,
    required this.picOrHost,
    required this.destination,
    required this.visitStart,
    required this.visitEnd,
    required this.visitors,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      id: json['id'].toString(), // pastikan tetap String
      jenis: json['jenis'],
      picOrHost: json['pic_or_host'],
      destination: json['destination'],
      visitStart: DateTime.parse(json['visit_start']),
      visitEnd: DateTime.parse(json['visit_end']),
      visitors: (json['visitors'] as List)
          .map((v) => VisitorModel.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jenis': jenis,
        'pic_or_host': picOrHost,
        'destination': destination,
        'visit_start': visitStart.toIso8601String(),
        'visit_end': visitEnd.toIso8601String(),
        'visitors': visitors.map((v) => v.toJson()).toList(),
      };
}
