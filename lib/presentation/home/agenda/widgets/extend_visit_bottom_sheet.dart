import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';

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
      padding: EdgeInsets.all(rw(context, 20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extend Visit',
                style: TextStyle(
                  fontSize: rfs(context, 18),
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

          vSpace(context, 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(durations.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                flex: isSelected ? 2 : 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: rw(context, 4)),
                  child: Button.filledRed(
                    borderRadius: rw(context, 20),
                    height: rh(context, 28),
                    label: durations[index],
                    onPressed: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    color: isSelected ? AppColors.error500 : AppColors.error400,
                    textColor: Colors.white,
                    fontSize: rfs(context, 12),
                  ),
                ),
              );
            }),
          ),

          vSpace(context, 20),
          Button.filled(
            label: "Extend Visit",
            onPressed: () {},
            height: rh(context, 40),
            fontSize: rfs(context, 14),
            borderRadius: rw(context, 10),
          ),
        ],
      ),
    );
  }
}
