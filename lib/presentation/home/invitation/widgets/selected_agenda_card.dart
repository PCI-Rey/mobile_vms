import 'package:flutter/material.dart';
import '../../../../presentation/home/agenda/agenda_detail_page.dart';
import '../../../../core/helper/responsive_helper.dart';
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
    // Dynamic sizing based on screen size
    final cardPadding = rw(context, 12.0);
    final verticalSpacing = rh(context, 10.0);
    final buttonHeight = rh(context, 40.0);
    
    // Dynamic font sizes
    final titleFontSize = rfs(context, 16.0);
    final bodyFontSize = rfs(context, 14.0);
    final smallFontSize = rfs(context, 12.0);
    final buttonFontSize = rfs(context, 12.0);

    return GestureDetector(
      onTap: isSelectable ? onSelectionChanged : null,
      child: Material(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(cardPadding),
          margin: EdgeInsets.only(bottom: rh(context, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rw(context, 12)),
            border: isSelectable && isSelected 
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, rh(context, 4)),
                color: isSelectable && isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.25)
                  : AppColors.primary900.withValues(alpha: 0.15),
                blurRadius: rw(context, 12),
                spreadRadius: rw(context, 2),
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
                    context: context,
                    titleFontSize: titleFontSize,
                    bodyFontSize: bodyFontSize,
                    smallFontSize: smallFontSize,
                  ),

                  vSpace(context, verticalSpacing / rh(context, 1.0)),

                  // Image Section - Made Expanded to prevent overflow
                  Expanded(
                    child: _buildImageSection(context),
                  ),

                  vSpace(context, verticalSpacing / rh(context, 1.0)),

                  // Bottom Section - Buttons and PIC
                  _buildBottomSection(
                    context: context,
                    buttonHeight: buttonHeight,
                    buttonFontSize: buttonFontSize,
                    smallFontSize: smallFontSize,
                  ),
                ],
              ),
              
              // Checkbox in top right corner
              if (isSelectable)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: rw(context, 24),
                    height: rw(context, 24),
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
                      borderRadius: BorderRadius.circular(rw(context, 4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: rw(context, 2),
                          offset: Offset(0, rh(context, 1)),
                        ),
                      ],
                    ),
                    child: isSelected
                      ? Icon(
                          Icons.check,
                          size: rw(context, 16),
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
    required BuildContext context,
    required double titleFontSize,
    required double bodyFontSize,
    required double smallFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add padding to prevent text overlap with checkbox
        Padding(
          padding: EdgeInsets.only(right: isSelectable ? rw(context, 30) : 0),
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
              vSpace(context, 4),
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
        vSpace(context, 8),
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

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(rw(context, 8)),
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
  }) {
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
                minimumSize: Size(rw(context, 70), buttonHeight),
                padding: EdgeInsets.symmetric(horizontal: rw(context, 8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 8)),
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
            hSpace(context, 8),
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
                minimumSize: Size(rw(context, 70), buttonHeight),
                padding: EdgeInsets.symmetric(horizontal: rw(context, 8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rw(context, 8)),
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