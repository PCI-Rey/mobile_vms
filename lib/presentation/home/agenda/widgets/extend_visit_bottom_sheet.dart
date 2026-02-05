import 'package:flutter/material.dart';

import '../../../../core/core.dart';

class ExtendVisitBottomSheet extends StatefulWidget {
  const ExtendVisitBottomSheet({super.key});

  @override
  State<ExtendVisitBottomSheet> createState() => _ExtendVisitBottomSheetState();
}

class _ExtendVisitBottomSheetState extends State<ExtendVisitBottomSheet> {
  int selectedIndex = -1;
  final List<String> durations = ['30 min', '90 min', '60 min'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Extend Visit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey900,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.grey600),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const Divider(color: AppColors.grey300, thickness: 1),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(durations.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                flex: isSelected ? 2 : 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Button.filledRed(
                    borderRadius: 20,
                    height: 28,
                    label: durations[index],
                    onPressed: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    color: isSelected ? AppColors.error500 : AppColors.error400,
                    textColor: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          Button.filled(
            label: "Extend Visit",
            onPressed: () {},
            height: 40,
            fontSize: 14,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}
