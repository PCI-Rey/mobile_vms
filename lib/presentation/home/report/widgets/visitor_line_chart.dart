import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/helper/responsive_helper.dart';

class VisitorLineChart extends StatelessWidget {
  VisitorLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rh(context, 500), // Set tinggi tetap di sini
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rw(context, 16)),
          side: BorderSide(width: 1, color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: EdgeInsets.all(rw(context, 30)),
          child: LineChart(
            LineChartData(
              backgroundColor: Colors.white,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Hari',
                    style: TextStyle(fontSize: rfs(context, 12)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const days = [
                        'Sen',
                        'Sel',
                        'Rab',
                        'Kam',
                        'Jum',
                        'Sab',
                        'Min',
                      ];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(
                          days[value.toInt()],
                          style: TextStyle(fontSize: rfs(context, 10)),
                        );
                      }
                      return Text('', style: TextStyle(fontSize: rfs(context, 10)));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Jumlah',
                    style: TextStyle(fontSize: rfs(context, 12)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: rfs(context, 10)),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: true),

              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                _buildLineBarData(visitorData, Colors.blue),
                _buildLineBarData(checkInData, Colors.green),
                _buildLineBarData(checkOutData, Colors.orange),
                _buildLineBarData(denyData, Colors.red),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.bar.color == Colors.red
                            ? "Deny"
                            : spot.bar.color == Colors.green
                            ? "Check-In"
                            : spot.bar.color == Colors.orange
                            ? "Check-Out"
                            : "Visitor"}: ${spot.y.toInt()}',
                        TextStyle(color: Colors.white, fontSize: rfs(context, 12)),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
      color: color,
    );
  }

  // Dummy data
  final List<double> visitorData = [60, 70, 50, 80, 90, 40, 30];
  final List<double> checkInData = [50, 60, 40, 70, 80, 30, 20];
  final List<double> checkOutData = [30, 40, 25, 60, 65, 20, 10];
  final List<double> denyData = [5, 7, 4, 6, 8, 3, 2];
}

