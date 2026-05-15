import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../presentation/home/agenda/agenda_detail_page.dart';

class AgendaCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeRange;
  final String date;
  final Widget image;
  final String picName;

  const AgendaCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeRange,
    required this.date,
    required this.image,
    required this.picName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    // Enhanced responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    // Dynamic sizing based on screen size - REDUCED VALUES
    final cardPadding = isSmallScreen
        ? 8.0
        : isMediumScreen
        ? 10.0 // Reduced from 12.0
        : 12.0; // Reduced from 16.0

    final verticalSpacing = isSmallScreen
        ? 3.0 // Reduced from 4.0
        : isMediumScreen
        ? 4.0 // Reduced from 6.0
        : 6.0; // Reduced from 8.0

    final imageHeight = isSmallScreen
        ? 90.0 // Reduced from 100.0
        : isMediumScreen
        ? 110.0 // Reduced from 120.0
        : 150.0; // Reduced from 160.0

    final buttonHeight = isSmallScreen
        ? 30.0
        : isMediumScreen
        ? 34.0
        : 40.0;

    // Dynamic font sizes - reduced for better fit
    final titleFontSize = isSmallScreen
        ? 12.0
        : isMediumScreen
        ? 14.0
        : 16.0;
    final bodyFontSize = isSmallScreen
        ? 10.0
        : isMediumScreen
        ? 12.0
        : 14.0;
    final smallFontSize = isSmallScreen
        ? 9.0
        : isMediumScreen
        ? 10.0
        : 12.0;
    final buttonFontSize = isSmallScreen
        ? 9.0
        : isMediumScreen
        ? 10.0
        : 12.0;

    return Material(
      child: Container(
        padding: EdgeInsets.all(
          cardPadding, // Reduced bottom padding significantly
        ),
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min, // Ensures minimal height
          children: [
            // Header Section
            _buildHeaderSection(
              titleFontSize: titleFontSize,
              bodyFontSize: bodyFontSize,
              smallFontSize: smallFontSize,
              isSmallScreen: isSmallScreen,
            ),

            SizedBox(height: verticalSpacing),

            // Image Section
            _buildImageSection(imageHeight),

            SizedBox(height: verticalSpacing),

            // Bottom Section - Buttons and PIC
            _buildBottomSection(
              context: context,
              buttonHeight: buttonHeight,
              buttonFontSize: buttonFontSize,
              smallFontSize: smallFontSize,
              isSmallScreen: isSmallScreen,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection({
    required double titleFontSize,
    required double bodyFontSize,
    required double smallFontSize,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Added for minimal height
      children: [
        // Title and Description
        Text(
          title,
          style: TextStyles.bodySmall600.copyWith(
            fontSize: titleFontSize,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          description,
          style: TextStyles.bodySmall.copyWith(
            fontSize: bodyFontSize,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isSmallScreen ? 3 : 4), // Reduced spacing
        // Time and Date Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                timeRange,
                style: TextStyles.bodySmall.copyWith(
                  fontSize: smallFontSize,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              date,
              style: TextStyles.bodySmall.copyWith(
                fontSize: smallFontSize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageSection(double imageHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
        height: imageHeight,
        child: FittedBox(fit: BoxFit.cover, child: image),
      ),
    );
  }

  Widget _buildBottomSection({
    required BuildContext context,
    required double buttonHeight,
    required double buttonFontSize,
    required double smallFontSize,
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    if (isSmallScreen) {
      return Column(
        mainAxisSize: MainAxisSize.min, // Added for minimal height
        children: [
          // Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('Extend button pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(0, buttonHeight),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Extend',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.push(AgendaDetailPage());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary500,
                    side: BorderSide(color: AppColors.primary500),
                    minimumSize: Size(0, buttonHeight),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Detail',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2), // Further reduced spacing
          // PIC Information
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'PIC $picName',
              style: TextStyle(
                fontSize: smallFontSize,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    // Medium and large screens - Row layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                debugPrint('Extend button pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(isTablet ? 85 : 70, buttonHeight),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Extend',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                context.push(AgendaDetailPage());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
                minimumSize: Size(isTablet ? 85 : 70, buttonHeight),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Detail',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const Spacer(),
        // Right side - PIC Information
        Flexible(
          child: Text(
            'PIC $picName',
            style: TextStyle(
              fontSize: smallFontSize,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
