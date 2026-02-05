import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/datasources/agenda_datasource.dart';

class VisitorTable extends StatelessWidget {
  const VisitorTable({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_VisitorRow> rows = [];

    for (var agenda in dummyAgendas) {
      for (var visitor in agenda.visitors) {
        rows.add(
          _VisitorRow(
            name: visitor.name,
            email: visitor.email,
            gedung: agenda.destination,
            status: visitor.status!,
            checkTime: visitor.checkTime!,
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // Background putih
        border: Border.all(width: 1, color: AppColors.grey300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(
              context,
            ).size.width, // Minimal selebar layar
          ),
          child: DataTable(
            columnSpacing: 0, // Hilangkan spacing default
            headingRowHeight: 56,
            dataRowHeight: 60,
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
            columns: [
              DataColumn(
                label: Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Gedung',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Check Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
            rows: rows.map((row) {
              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        row.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        row.gedung,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(row.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          row.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        row.checkTime,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'checkin':
        return AppColors.primary500;
      case 'checkout':
        return AppColors.warning500;
      case 'deny':
        return AppColors.error500;
      default:
        return Colors.grey;
    }
  }
}

class _VisitorRow {
  final String name;
  final String email;
  final String gedung;
  final String status;
  final String checkTime;

  _VisitorRow({
    required this.name,
    required this.email,
    required this.gedung,
    required this.status,
    required this.checkTime,
  });
}
