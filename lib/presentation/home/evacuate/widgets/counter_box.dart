import 'package:flutter/material.dart';
import '../../../../core/helper/responsive_helper.dart';

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
      boxWidth = (screenWidth - rw(context, 48)) / 3;
      fontSize = rfs(context, 16);
      titleFontSize = rfs(context, 11);
      padding = EdgeInsets.symmetric(vertical: rh(context, 12), horizontal: rw(context, 4));
    } else if (screenWidth < 400) {
      // Small screens
      boxWidth = (screenWidth - rw(context, 56)) / 3;
      fontSize = rfs(context, 18);
      titleFontSize = rfs(context, 12);
      padding = EdgeInsets.symmetric(vertical: rh(context, 16), horizontal: rw(context, 6));
    } else {
      // Normal screens and above
      boxWidth = screenWidth * 0.28;
      fontSize = rfs(context, 20);
      titleFontSize = rfs(context, 14);
      padding = EdgeInsets.symmetric(vertical: rh(context, 20), horizontal: rw(context, 8));
    }

    return Container(
      padding: padding,
      width: boxWidth,
      constraints: BoxConstraints(
        minWidth: rw(context, 80),
        minHeight: rh(context, 70),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rw(context, 10)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, rh(context, 4)),
            color: const Color(0xffE5E7EB).withValues(alpha: 0.5),
            blurRadius: rw(context, 12),
            spreadRadius: rw(context, 2),
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
          vSpace(context, 4),
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
    double spacing = screenWidth < 360 ? rw(context, 6) : rw(context, 12);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          // Untuk layar sangat kecil, gunakan Column
          return Column(
            children: counters.map((counter) => 
              Padding(
                padding: EdgeInsets.only(bottom: rh(context, 12)),
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