import 'package:flutter/material.dart';

class CounterBox extends StatelessWidget {
  final String title;
  final int count;
  
  const CounterBox({
    super.key, 
    required this.title, 
    required this.count
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing berdasarkan lebar layar
    double boxWidth;
    double fontSize;
    double titleFontSize;
    EdgeInsets padding;
    
    if (screenWidth < 360) {
      // Extra small screens
      boxWidth = (screenWidth - 48) / 3; // 48 = total margin/padding
      fontSize = 16;
      titleFontSize = 11;
      padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 4);
    } else if (screenWidth < 400) {
      // Small screens
      boxWidth = (screenWidth - 56) / 3; // 56 = total margin/padding
      fontSize = 18;
      titleFontSize = 12;
      padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 6);
    } else {
      // Normal screens and above
      boxWidth = screenWidth * 0.28; // Slightly reduced from 0.3
      fontSize = 20;
      titleFontSize = 14;
      padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 8);
    }

    return Container(
      padding: padding,
      width: boxWidth,
      constraints: const BoxConstraints(
        minWidth: 80, // Minimum width to prevent too small boxes
        minHeight: 70, // Minimum height
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            color: const Color(0xffE5E7EB).withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Wrapper widget untuk Row yang lebih responsive
class ResponsiveCounterRow extends StatelessWidget {
  final List<CounterBoxData> counters;
  
  const ResponsiveCounterRow({
    super.key,
    required this.counters,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Untuk layar sangat kecil, gunakan spacing yang lebih kecil
    double spacing = screenWidth < 360 ? 6 : 12;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          // Untuk layar sangat kecil, gunakan Column
          return Column(
            children: counters.map((counter) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: constraints.maxWidth * 0.8,
                  child: CounterBox(
                    title: counter.title,
                    count: counter.count,
                  ),
                ),
              )
            ).toList(),
          );
        } else {
          // Untuk layar normal, gunakan Row dengan spacing yang disesuaikan
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: counters.map((counter) => 
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: CounterBox(
                    title: counter.title,
                    count: counter.count,
                  ),
                ),
              )
            ).toList(),
          );
        }
      },
    );
  }
}

// Data class untuk counter
class CounterBoxData {
  final String title;
  final int count;
  
  const CounterBoxData({
    required this.title,
    required this.count,
  });
}

// Example usage widget
class EvacuatePageCounters extends StatelessWidget {
  const EvacuatePageCounters({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCounterRow(
      counters: const [
        CounterBoxData(title: "Visitor", count: 12),
        CounterBoxData(title: "Employee", count: 9),
        CounterBoxData(title: "Not Reaction", count: 2),
      ],
    );
  }
}