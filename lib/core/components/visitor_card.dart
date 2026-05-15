import 'package:flutter/material.dart';
// import '../../core/components/components.dart';
import '../../core/core.dart';

enum VisitorStatus {
  pending,
  approved,
  denied, checkedIn, checkedOut,
}

class VisitorCard extends StatelessWidget {
  final String visitorName;
  final String companyName;
  final String destination;
  final String timeRange;
  final String date;
  final Widget avatar;
  final VoidCallback? onDeny;
  final VoidCallback? onApprove;
  final String? idVisitor;
  final String? invitationCode;
  final VisitorStatus status;

  const VisitorCard({
    super.key,
    required this.visitorName,
    required this.companyName,
    required this.destination,
    required this.timeRange,
    required this.date,
    required this.avatar,
    this.onDeny,
    this.onApprove,
    this.idVisitor,
    this.invitationCode,
    this.status = VisitorStatus.pending,
  });

  Color _getCardBackgroundColor() {
    switch (status) {
      case VisitorStatus.approved:
        return Colors.white;
      case VisitorStatus.denied:
        return Colors.red[50] ?? Colors.red.shade50;
      case VisitorStatus.pending:
      default:
        return Colors.white;
    }
  }

  Color _getCardBorderColor() {
    switch (status) {
      case VisitorStatus.approved:
        return Colors.grey[300] ?? Colors.grey.shade300;
      case VisitorStatus.denied:
        return Colors.red[200] ?? Colors.red.shade200;
      case VisitorStatus.pending:
      default:
        return Colors.transparent;
    }
  }

  Widget _buildStatusWidget() {
    switch (status) {
      case VisitorStatus.approved:
        return Container(
          alignment: Alignment.centerRight,
          child: Text(
            'Approved',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case VisitorStatus.denied:
        return Container(
          alignment: Alignment.centerRight,
          child: Text(
            'Denied',
            style: TextStyles.bodyMedium.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      case VisitorStatus.pending:
      default:
        return const SizedBox.shrink();
    }
  }

  bool _shouldShowActionButtons() {
    return status == VisitorStatus.pending && (onDeny != null || onApprove != null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getCardBackgroundColor(),
          borderRadius: BorderRadius.circular(10),
          border: status != VisitorStatus.pending 
              ? Border.all(color: _getCardBorderColor(), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 6),
              color: AppColors.primary900.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section - User info and date/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      // Avatar
                      CustomCircleImage(image: avatar),

                      const SizedBox(width: 12),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visitorName,
                              style: TextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              companyName,
                              style: TextStyles.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Date and time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(date, style: TextStyles.bodySmall),
                    Text(timeRange, style: TextStyles.bodySmall),
                  ],
                ),
              ],
            ),

            const SpaceHeight(12),

            // Middle section - Destination and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    destination,
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (invitationCode != null && invitationCode!.isNotEmpty)
                  Text(
                    invitationCode!,
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),

            const SpaceHeight(16),

            // Status or Action buttons section
            if (status != VisitorStatus.pending)
              _buildStatusWidget()
            else if (_shouldShowActionButtons())
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDeny != null)
                    Button.filledRed(
                      onPressed: onDeny!,
                      label: 'Deny',
                      height: 30,
                      width: 100,
                      fontSize: 12,
                    ),
                  if (onDeny != null && onApprove != null)
                    const SizedBox(width: 6),
                  if (onApprove != null)
                    Button.filled(
                      onPressed: onApprove!,
                      label: 'Approve',
                      height: 30,
                      width: 100,
                      fontSize: 12,
                    ),
                ],
              ),

            // ID Visitor section (if exists)
            if (idVisitor != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'ID: ',
                        style: TextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: idVisitor,
                        style: TextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}