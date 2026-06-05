import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';

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
      insetPadding: EdgeInsets.all(rw(context, 40)),
      child: Container(
        padding: EdgeInsets.all(rw(context, 10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 16)),
        ),
        child: Stack(
          children: [
            IntrinsicWidth(
              child: Container(
                padding: EdgeInsets.all(rw(context, 10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(image),
                      radius: rw(context, 60),
                    ),

                    hSpace(context, 20),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleMenu(
                              image: Assets.icons.person.image(height: rw(context, 20)),
                              size: rw(context, 30),
                              backgroundColor: AppColors.primary500,
                            ),
                            hSpace(context, 8),
                            Text(name, style: TextStyles.bodySmall600.copyWith(fontSize: rfs(context, 12))),
                          ],
                        ),
                        vSpace(context, 8),
                        Row(
                          children: [
                            CircleMenu(
                              image: Assets.icons.building.image(height: rw(context, 20)),
                              size: rw(context, 30),
                              backgroundColor: AppColors.primary500,
                            ),
                            hSpace(context, 8),
                            Text(company, style: TextStyles.bodySmall600.copyWith(fontSize: rfs(context, 12))),
                          ],
                        ),
                        vSpace(context, 8),
                        Row(
                          children: [
                            CircleMenu(
                              image: Icon(
                                Icons.email,
                                color: AppColors.primary50,
                                size: rw(context, 20),
                              ),
                              size: rw(context, 30),
                              backgroundColor: AppColors.primary500,
                            ),
                            hSpace(context, 8),
                            Text(email, style: TextStyles.bodySmall600.copyWith(fontSize: rfs(context, 12))),
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
                    padding: EdgeInsets.all(rw(context, 5.0)),
                    child: Icon(
                      Icons.close,
                      size: rw(context, 12),
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

