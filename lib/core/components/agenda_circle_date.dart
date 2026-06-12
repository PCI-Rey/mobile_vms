import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'package:intl/intl.dart';

class AgendaCircleDate extends StatelessWidget {
  final DateTime date;
  final bool isSelected;

  const AgendaCircleDate({
    super.key,
    required this.date,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('E', 'en').format(date); // contoh: "Sen"
    final dayNumber = DateFormat('d').format(date); // contoh: "30"

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.blue : Colors.white,
        border: Border.all(color: AppColors.grey500),
      ),
      width: 60,
      height: 70,  
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayNumber,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : AppColors.grey550,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
