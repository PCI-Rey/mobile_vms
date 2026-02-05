import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/core.dart';

class ProfileDialog extends StatelessWidget {
  final String name;
  final String company;
  final String email;
  final String image;

  const ProfileDialog({
    super.key,
    required this.name,
    required this.company,
    required this.email,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(image),
                      radius: 60,
                    ),

                    const SpaceWidth(20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleMenu(
                              image: Assets.icons.person.image(height: 20),
                              size: 30,
                              backgroundColor: AppColors.primary500,
                            ),
                            const SpaceWidth(8),
                            Text(name, style: TextStyles.bodySmall600),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleMenu(
                              image: Assets.icons.building.image(height: 20),
                              size: 30,
                              backgroundColor: AppColors.primary500,
                            ),
                            const SizedBox(width: 8),
                            Text(company, style: TextStyles.bodySmall600),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleMenu(
                              image: Icon(
                                Icons.email,
                                color: AppColors.primary50,
                                size: 20,
                              ),
                              size: 30,
                              backgroundColor: AppColors.primary500,
                            ),
                            const SizedBox(width: 8),
                            Text(email, style: TextStyles.bodySmall600),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey800,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
