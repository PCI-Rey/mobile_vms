import 'package:flutter/material.dart';

import '../core.dart';

class CustomCard extends StatelessWidget {
  final Widget image;
  final double size;
  final String title;
  final String subtitle;
  final String additional;
  final String additionalDesc;
  final Color backgroundIconColor;
  final Widget? trailing;

  const CustomCard({
    super.key,
    required this.image,
    required this.size,
    required this.title,
    required this.subtitle,
    this.additional = '',
    this.additionalDesc = '',
    this.backgroundIconColor = AppColors.primary50,
    this.trailing,
  });

  // Helper method to get responsive values based on screen size
  Map<String, dynamic> _getResponsiveValues(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth <= 360) {
      // Small screen (phones like iPhone SE, small Android)
      return {
        'cardPadding': const EdgeInsets.all(6.0),
        'cardMargin': const EdgeInsets.only(top: 6.0),
        'borderRadius': 6.0,
        'iconSize': 32.0,
        'iconBorderRadius': 16.0,
        'titleStyle': TextStyles.subtitle1.copyWith(fontSize: 12),
        'subtitleStyle': TextStyles.subtitle3.copyWith(fontSize: 10),
        'additionalStyle': TextStyles.subtitle1.copyWith(fontSize: 11),
        'additionalDescStyle': TextStyles.subtitle3.copyWith(fontSize: 9),
        'contentPadding': const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        'minHeight': 60.0,
      };
    } else if (screenWidth <= 600) {
      // Medium screen (regular phones, small tablets)
      return {
        'cardPadding': const EdgeInsets.all(12.0),
        'cardMargin': const EdgeInsets.only(top: 8.0),
        'borderRadius': 12.0,
        'iconSize': 40.0,
        'iconBorderRadius': 12.0,
        'titleStyle': TextStyles.subtitle1.copyWith(fontSize: 14),
        'subtitleStyle': TextStyles.subtitle3.copyWith(fontSize: 12),
        'additionalStyle': TextStyles.subtitle1.copyWith(fontSize: 13),
        'additionalDescStyle': TextStyles.subtitle3.copyWith(fontSize: 11),
        'contentPadding': const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        'minHeight': 70.0,
      };
    } else if (screenWidth <= 1024) {
      // Large screen (tablets, small laptops)
      return {
        'cardPadding': const EdgeInsets.all(16.0),
        'cardMargin': const EdgeInsets.only(top: 12.0),
        'borderRadius': 16.0,
        'iconSize': 48.0,
        'iconBorderRadius': 16.0,
        'titleStyle': TextStyles.subtitle1.copyWith(fontSize: 18),
        'subtitleStyle': TextStyles.subtitle3.copyWith(fontSize: 14),
        'additionalStyle': TextStyles.subtitle1.copyWith(fontSize: 16),
        'additionalDescStyle': TextStyles.subtitle3.copyWith(fontSize: 13),
        'contentPadding': const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        'minHeight': 90.0,
      };
    } else {
      // Extra large screen (large tablets, desktop)
      return {
        'cardPadding': const EdgeInsets.all(20.0),
        'cardMargin': const EdgeInsets.only(top: 16.0),
        'borderRadius': 20.0,
        'iconSize': 56.0,
        'iconBorderRadius': 20.0,
        'titleStyle': TextStyles.subtitle1.copyWith(fontSize: 20),
        'subtitleStyle': TextStyles.subtitle3.copyWith(fontSize: 16),
        'additionalStyle': TextStyles.subtitle1.copyWith(fontSize: 18),
        'additionalDescStyle': TextStyles.subtitle3.copyWith(fontSize: 14),
        'contentPadding': const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        'minHeight': 100.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = _getResponsiveValues(context);
    
    return Container(
      margin: responsive['cardMargin'],
      constraints: BoxConstraints(
        minHeight: responsive['minHeight'],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive['borderRadius']),
        color: Colors.white,
        border: Border.all(width: 1, color: AppColors.grey200.withValues(alpha: 0.5)),
        // Premium Soft Shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: responsive['cardPadding'],
      child: Row(
        children: [
          // Leading icon
          Container(
            width: responsive['iconSize'],
            height: responsive['iconSize'],
            decoration: BoxDecoration(
              color: backgroundIconColor,
              borderRadius: BorderRadius.circular(responsive['iconBorderRadius']),
            ),
            child: Center(child: image),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: responsive['contentPadding'],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: responsive['titleStyle'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: responsive['subtitleStyle'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Trailing content
          if (additional.isNotEmpty || additionalDesc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (additional.isNotEmpty)
                    Text(
                      additional,
                      style: responsive['additionalStyle'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (additionalDesc.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      additionalDesc,
                      style: responsive['additionalDescStyle'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          
          // Trailing widget
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

// Alternative approach using LayoutBuilder for more precise control
class CustomCardLayoutBuilder extends StatelessWidget {
  final Widget image;
  final double size;
  final String title;
  final String subtitle;
  final String additional;
  final String additionalDesc;
  final Color backgroundIconColor;

  const CustomCardLayoutBuilder({
    super.key,
    required this.image,
    required this.size,
    required this.title,
    required this.subtitle,
    this.additional = '',
    this.additionalDesc = '',
    this.backgroundIconColor = AppColors.primary50,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive values based on available width
        final width = constraints.maxWidth;
        final isSmall = width < 300;
        // final isMedium = width >= 300 && width < 500;
        final isLarge = width >= 500;

        // Dynamic scaling factor
        double scaleFactor = 1.0;
        if (isSmall) scaleFactor = 0.75;
        if (isLarge) scaleFactor = 1.15;

        return Container(
          margin: EdgeInsets.only(top: 8.0 * scaleFactor),
          constraints: BoxConstraints(
            minHeight: 70.0 * scaleFactor,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0 * scaleFactor),
            color: Colors.white,
            border: Border.all(width: 1, color: AppColors.grey200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4 * scaleFactor,
                offset: Offset(0, 2 * scaleFactor),
              ),
            ],
          ),
          padding: EdgeInsets.all(12.0 * scaleFactor),
          child: Row(
            children: [
              // Leading icon
              Container(
                width: 32.0 * scaleFactor,
                height: 32.0 * scaleFactor,
                decoration: BoxDecoration(
                  color: backgroundIconColor,
                  borderRadius: BorderRadius.circular(16.0 * scaleFactor),
                ),
                child: Center(child: image),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0 * scaleFactor,
                    vertical: 4.0 * scaleFactor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyles.subtitle1.copyWith(
                          fontSize: (TextStyles.subtitle1.fontSize ?? 16) * scaleFactor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2 * scaleFactor),
                      Text(
                        subtitle,
                        style: TextStyles.subtitle3.copyWith(
                          fontSize: (TextStyles.subtitle3.fontSize ?? 14) * scaleFactor,
                        ),
                        maxLines: isSmall ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Trailing content
              if (additional.isNotEmpty || additionalDesc.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 8 * scaleFactor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (additional.isNotEmpty)
                        Text(
                          additional,
                          style: TextStyles.subtitle1.copyWith(
                            fontSize: (TextStyles.subtitle1.fontSize ?? 16) * scaleFactor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (additionalDesc.isNotEmpty) ...[
                        SizedBox(height: 2 * scaleFactor),
                        Text(
                          additionalDesc,
                          style: TextStyles.subtitle3.copyWith(
                            fontSize: (TextStyles.subtitle3.fontSize ?? 14) * scaleFactor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}