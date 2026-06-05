import 'package:flutter/material.dart';
import '../core.dart';
import '../helper/responsive_helper.dart';

class NotificationCard extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final Color? backgroundColor;
  final Color backgroundIconColor;
  final Color textColor;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final Widget iconData;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    this.backgroundColor = AppColors.info100,
    this.backgroundIconColor = AppColors.primary500,
    this.textColor = AppColors.grey900,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryActionLabel = 'OK',
    this.secondaryActionLabel,
    required this.iconData,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _showActions = false;

  void _toggleActions() {
    setState(() {
      _showActions = !_showActions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleActions,
      child: Container(
        padding: EdgeInsets.all(rw(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rw(context, 10)),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, rh(context, 6)),
              color: AppColors.primary900.withValues(alpha: 0.1),
              blurRadius: rw(context, 10),
              spreadRadius: rw(context, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: rw(context, 20),
              backgroundColor: widget.backgroundIconColor,
              child: Padding(
                padding: EdgeInsets.all(rw(context, 5)),
                child: widget.iconData,
              ),
            ),
            hSpace(context, 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: rfs(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  vSpace(context, 8),
                  Text(
                    widget.description,
                    style: TextStyles.caption.copyWith(fontSize: rfs(context, 14)),
                  ),
                  Text(
                    widget.date,
                    style: TextStyles.caption.copyWith(
                      fontSize: rfs(context, 14),
                      color: AppColors.grey600,
                    ),
                  ),
                  if (_showActions) ...[
                    vSpace(context, 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.secondaryActionLabel != null)
                          Button.filledRed(
                            onPressed: widget.onSecondaryAction ?? () {},
                            label: widget.secondaryActionLabel!,
                            height: 32,
                            width: 100,
                            fontSize: 12,
                          ),
                        if (widget.secondaryActionLabel != null)
                          hSpace(context, 8),
                        Button.filled(
                          onPressed: widget.onPrimaryAction ?? () {},
                          label: widget.primaryActionLabel,
                          height: 32,
                          width: 100,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
