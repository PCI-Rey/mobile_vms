import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/core.dart';

class ReactionPieChart extends StatefulWidget {
  final Map<String, dynamic>? groupData;
  final bool showLegend;
  final double? radius;

  const ReactionPieChart({
    super.key,
    this.groupData,
    this.showLegend = true,
    this.radius,
  });

  @override
  State<ReactionPieChart> createState() => _ReactionPieChartState();
}

class _ReactionPieChartState extends State<ReactionPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 50),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 6),
            color: AppColors.primary900.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: widget.radius != null ? widget.radius! * 2 : 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: widget.radius != null
                    ? widget.radius! * 0.3
                    : 30,
                sections: _buildPieChartSections(),
              ),
            ),
          ),

          const SpaceHeight(20),
          if (widget.showLegend) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    // Get data from groupData or use default values
    final int confirmed = widget.groupData?['confirmed'] ?? 0;
    final int noReaction = widget.groupData?['noReaction'] ?? 0;
    final int decline = widget.groupData?['decline'] ?? 0;

    final int total = confirmed + noReaction + decline;

    if (total == 0) {
      // Return empty state
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 1,
          title: 'No Data',
          radius: widget.radius ?? 80,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ];
    }

    return [
      // Confirmed section (Green)
      PieChartSectionData(
        color: AppColors.info500,
        value: confirmed.toDouble(),
        title: touchedIndex == 0
            ? '$confirmed\n(${(confirmed / total * 100).toStringAsFixed(1)}%)'
            : '${(confirmed / total * 100).toStringAsFixed(1)}%',
        radius: touchedIndex == 0
            ? (widget.radius ?? 80) + 10
            : widget.radius ?? 80,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      ),

      // No Reaction section (Orange)
      PieChartSectionData(
        color: AppColors.warning500,
        value: noReaction.toDouble(),
        title: touchedIndex == 1
            ? '$noReaction\n(${(noReaction / total * 100).toStringAsFixed(1)}%)'
            : '${(noReaction / total * 100).toStringAsFixed(1)}%',
        radius: touchedIndex == 1
            ? (widget.radius ?? 80) + 10
            : widget.radius ?? 80,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      ),

      // Decline section (Red)
      PieChartSectionData(
        color: AppColors.error500,
        value: decline.toDouble(),
        title: touchedIndex == 2
            ? '$decline\n(${(decline / total * 100).toStringAsFixed(1)}%)'
            : '${(decline / total * 100).toStringAsFixed(1)}%',
        radius: touchedIndex == 2
            ? (widget.radius ?? 80) + 10
            : widget.radius ?? 80,
        titleStyle: TextStyle(
          fontSize: touchedIndex == 2 ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.6,
      ),
    ];
  }

  Widget _buildLegend() {
    final int confirmed = widget.groupData?['confirmed'] ?? 0;
    final int noReaction = widget.groupData?['noReaction'] ?? 0;
    final int decline = widget.groupData?['decline'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika lebar layar kecil, gunakan layout vertikal (wrap)
        if (constraints.maxWidth < 400) {
          return Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(
                color: AppColors.info500,
                label: 'Total',
                value: confirmed + noReaction + decline,
                isCompact: true,
              ),
              _buildLegendItem(
                color: AppColors.success500,
                label: 'Confirmed',
                value: confirmed,
                isCompact: true,
              ),
              _buildLegendItem(
                color: AppColors.warning500,
                label: 'No Reaction',
                value: noReaction,
                isCompact: true,
              ),
              _buildLegendItem(
                color: AppColors.error500,
                label: 'Decline',
                value: decline,
                isCompact: true,
              ),
            ],
          );
        } else {
          // Untuk layar besar, gunakan Row seperti sebelumnya
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                color: AppColors.info500,
                label: 'Total',
                value: confirmed + noReaction + decline,
              ),
              _buildLegendItem(
                color: AppColors.success500,
                label: 'Confirmed',
                value: confirmed,
              ),
              _buildLegendItem(
                color: AppColors.warning500,
                label: 'No Reaction',
                value: noReaction,
              ),
              _buildLegendItem(
                color: AppColors.error500,
                label: 'Decline',
                value: decline,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int value,
    bool isCompact = false,
  }) {
    if (isCompact) {
      // Layout horizontal kompak untuk layar kecil
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Layout original untuk layar besar
      return Flexible(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$value Person',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}

// Alternative version for showing total data (for main evacuate page)
class ReactionPieChartTotal extends StatefulWidget {
  final List<Map<String, dynamic>> allGroups;
  final bool showLegend;
  final double? radius;

  const ReactionPieChartTotal({
    super.key,
    required this.allGroups,
    this.showLegend = true,
    this.radius,
  });

  @override
  State<ReactionPieChartTotal> createState() => _ReactionPieChartTotalState();
}

class _ReactionPieChartTotalState extends State<ReactionPieChartTotal> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Calculate totals from all groups
    int totalConfirmed = 0;
    int totalNoReaction = 0;
    int totalDecline = 0;

    for (var group in widget.allGroups) {
      totalConfirmed += (group['confirmed'] as int? ?? 0);
      totalNoReaction += (group['noReaction'] as int? ?? 0);
      totalDecline += (group['decline'] as int? ?? 0);
    }

    // Create combined data
    Map<String, dynamic> totalData = {
      'confirmed': totalConfirmed,
      'noReaction': totalNoReaction,
      'decline': totalDecline,
    };

    return ReactionPieChart(
      groupData: totalData,
      showLegend: widget.showLegend,
      radius: widget.radius,
    );
  }
}