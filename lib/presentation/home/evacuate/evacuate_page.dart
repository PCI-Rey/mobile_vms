import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../presentation/home/evacuate/evacuate_history_page.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import 'widgets/counter_box.dart';
import 'widgets/progress_bar.dart';
import 'widgets/reaction_group_card.dart';
import 'widgets/reaction_pie_chart.dart';
import '../../widgets/evacuate_overlay.dart';

class EvacuatePage extends StatefulWidget {
  const EvacuatePage({super.key});

  @override
  State<EvacuatePage> createState() => _EvacuatePageState();
}

class _EvacuatePageState extends State<EvacuatePage> {
  Duration duration = const Duration(minutes: 2);
  Timer? timer;
  bool isEvacuateActive = false;

  void startTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (duration.inSeconds > 0) {
        if (mounted) {
          setState(() {
            duration = duration - const Duration(seconds: 1);
          });
        }
      } else {
        timer?.cancel();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;

    setState(() {
      duration = const Duration(minutes: 2);
      isEvacuateActive = false;
    });
  }

  void _handleStartEvacuate() {
    setState(() {
      isEvacuateActive = true;
    });
    startTimer();
  }

  void _handleCheckinEvacuate() {
    setState(() => isEvacuateActive = false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
  }

  List<Map<String, dynamic>> groups = [
    {"title": "Finance", "confirmed": 23, "noReaction": 0, "decline": 2},
    {"title": "HR", "confirmed": 10, "noReaction": 3, "decline": 1},
    {"title": "Tax", "confirmed": 10, "noReaction": 3, "decline": 1},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                "Evacuate",
                style: TextStyle(fontSize: rfs(context, 18)),
              ),
              leading: const BackButton(),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: rw(context, 12)),
                  child: SizedBox(
                    width: rw(context, 100),
                    height: rh(context, 40),
                    child: Button.filled(
                      onPressed: () {
                        context.push(EvacuateHistoryPage());
                      },
                      label: 'History',
                      color: AppColors.primary500,
                      borderRadius: rw(context, 12),
                      fontSize: rfs(context, 13),
                    ),
                  ),
                ),
              ],

              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: AppColors.grey300, height: 1.0),
              ),
            ),

            body: SingleChildScrollView(
              padding: EdgeInsets.all(rw(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      formatDuration(duration),
                      style: TextStyle(
                        fontSize: rfs(context, 36),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  vSpace(context, 16),

                  ReactionPieChartTotal(
                    allGroups: groups,
                    showLegend: true,
                    radius: rw(context, 70),
                  ),
                  vSpace(context, 16),

                  ProgressSection(allGroups: groups),
                  vSpace(context, 16),

                  vSpace(context, 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      CounterBox(title: "Visitor", count: 12),
                      CounterBox(title: "Employee", count: 9),
                      CounterBox(title: "Not Reaction", count: 2),
                    ],
                  ),
                  vSpace(context, 18),

                  Text(
                    "Reactions per group",
                    style: TextStyle(fontSize: rfs(context, 16), fontWeight: FontWeight.bold),
                  ),

                  vSpace(context, 10),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;

                      int columnCount = screenWidth < 600 ? 2 : 3;
                      double spacing = rw(context, 10);
                      double totalSpacing = spacing * (columnCount - 1);
                      double itemWidth =
                          (screenWidth - totalSpacing) / columnCount;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: groups.map((group) {
                          return SizedBox(
                            width: itemWidth,
                            child: ReactionGroupCardFromData(group: group),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  vSpace(context, 18),
                  Button.filled(
                    onPressed: _handleStartEvacuate,
                    label: 'Start Evacuate',
                  ),
                  vSpace(context, 10),
                  Button.filledRed(onPressed: stopTimer, label: 'End Evacuate'),
                ],
              ),
            ),
          ),

          // Evacuate Overlay
          if (isEvacuateActive)
            EvacuateOverlay(
              onCheckin: _handleCheckinEvacuate,
              initialDuration: duration,
            ),
        ],
      ),
    );
  }
}
