import 'package:flutter/material.dart';

enum Gender { male, female }

class GenderToggleButton extends StatelessWidget {
  final Gender selectedGender;
  final Function(Gender) onChanged;

  const GenderToggleButton({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _genderButton(
          icon: Icons.male,
          label: 'Laki-laki',
          selected: selectedGender == Gender.male,
          onTap: () => onChanged(Gender.male),
          selectedBorderColor: Colors.blue,
          iconColor: Colors.black,
        ),
        const SizedBox(width: 12),
        _genderButton(
          icon: Icons.female,
          label: 'Perempuan',
          selected: selectedGender == Gender.female,
          onTap: () => onChanged(Gender.female),
          selectedBorderColor: Colors.pink,
          iconColor: Colors.pink,
        ),
      ],
    );
  }

  Widget _genderButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color selectedBorderColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue[50] : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? selectedBorderColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
