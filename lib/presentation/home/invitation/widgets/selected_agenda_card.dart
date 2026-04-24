import 'package:flutter/material.dart';
import '../../../../presentation/home/agenda/agenda_detail_page.dart';
import '../../../../core/core.dart';

class SelectableAgendaCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeRange;
  final String date;
  final Widget image;
  final String picName;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;
  final bool isSelectable;

  const SelectableAgendaCard({
    super.key,
    required this.title,
    required this.description,
    required this.timeRange,
    required this.date,
    required this.image,
    required this.picName,
    this.isSelected = false,
    this.onSelectionChanged,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    // Enhanced responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;

    // Dynamic sizing based on screen size
    final cardPadding = isSmallScreen ? 8.0 : isMediumScreen ? 10.0 : 12.0;
    final verticalSpacing = isSmallScreen ? 5.0 : isMediumScreen ? 8.0 : 10.0;
    final buttonHeight = isSmallScreen ? 32.0 : isMediumScreen ? 36.0 : 40.0;
    
    // Dynamic font sizes
    final titleFontSize = isSmallScreen ? 12.0 : isMediumScreen ? 14.0 : 16.0;
    final bodyFontSize = isSmallScreen ? 10.0 : isMediumScreen ? 12.0 : 14.0;
    final smallFontSize = isSmallScreen ? 9.0 : isMediumScreen ? 10.0 : 12.0;
    final buttonFontSize = isSmallScreen ? 9.0 : isMediumScreen ? 10.0 : 12.0;

    return GestureDetector(
      onTap: isSelectable ? onSelectionChanged : null,
      child: Material(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(cardPadding),
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            border: isSelectable && isSelected 
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                color: isSelectable && isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.25)
                  : AppColors.primary900.withValues(alpha: 0.15),
                blurRadius: isSmallScreen ? 8 : 12,
                spreadRadius: isSmallScreen ? 1 : 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  _buildHeaderSection(
                    titleFontSize: titleFontSize,
                    bodyFontSize: bodyFontSize,
                    smallFontSize: smallFontSize,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: verticalSpacing),

                  // Image Section - Made Expanded to prevent overflow
                  Expanded(
                    child: _buildImageSection(),
                  ),

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
              
              // Checkbox in top right corner
              if (isSelectable)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : Colors.white,
                      border: Border.all(
                        color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                  ),
                ),
            ],
          ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add padding to prevent text overlap with checkbox
        Padding(
          padding: EdgeInsets.only(right: isSelectable ? 30 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 5 : 8),
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

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: double.infinity,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Buttons Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgendaDetailPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgendaDetailPage(),
                  ),
                );
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