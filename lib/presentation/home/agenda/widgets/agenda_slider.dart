import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/core.dart';
import '../../../../data/models/agenda_model.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/agenda_controller.dart';

class AgendaSlider extends StatefulWidget {
  const AgendaSlider({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AgendaSliderState();
  }
}

class _AgendaSliderState extends State<AgendaSlider> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  late final AgendaController agendaController;

  @override
  void initState() {
    super.initState();
    // Inject controller if not already present
    if (Get.isRegistered<AgendaController>()) {
      agendaController = Get.find<AgendaController>();
    } else {
      agendaController = Get.put(AgendaController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (agendaController.isLoading.value) {
        return _buildLoadingSlider();
      }

      if (agendaController.errorMessage.value != null) {
        return _buildErrorSlider(agendaController.errorMessage.value!);
      }

      return _buildSuccessSlider(agendaController.agendas);
    });
  }

  Widget _buildLoadingSlider() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 800;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shimmer loading with same height calculation
        ClipRect(
          child: Container(
            height: _getCarouselHeight(
              screenWidth,
              screenHeight,
              isSmallScreen,
              isMediumScreen,
              isTablet,
              isLargeTablet,
            ),
            width: double.infinity,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: CarouselSlider.builder(
                itemCount: 3, // Show 3 shimmer cards
                itemBuilder: (context, index, realIndex) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                      bottom: isSmallScreen
                          ? 2
                          : isMediumScreen
                          ? 3
                          : 4,
                      right: isSmallScreen
                          ? 6
                          : isMediumScreen
                          ? 10
                          : 12,
                      left: isSmallScreen ? 2 : 4,
                    ),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: _getActualCarouselHeight(
                    screenWidth,
                    screenHeight,
                    isSmallScreen,
                    isMediumScreen,
                    isTablet,
                    isLargeTablet,
                  ),
                  enlargeCenterPage: !isSmallScreen,
                  viewportFraction: _getViewportFraction(
                    isSmallScreen,
                    isMediumScreen,
                    isTablet,
                    isLargeTablet,
                  ),
                  enableInfiniteScroll: false,
                ),
              ),
            ),
          ),
        ),

        // Shimmer dots
        _buildShimmerDots(isSmallScreen, isMediumScreen, isTablet),
      ],
    );
  }

  Widget _buildSuccessSlider(List<AgendaModel> agendas) {
    if (agendas.isEmpty) {
      return _buildEmptyState();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Enhanced responsive breakpoints with ultra-wide screen support
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 800;
    final isUltraWide = screenWidth >= 1200; // Add ultra-wide detection

    final List<Widget> imageSliders = agendas
        .map(
          (agenda) => Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(
              // REDUCED bottom padding to eliminate excessive spacing
              bottom: isSmallScreen
                  ? 2
                  : isMediumScreen
                  ? 3
                  : 4, // Reduced significantly
              right: isSmallScreen
                  ? 6
                  : isMediumScreen
                  ? 10
                  : 12,
              left: isSmallScreen ? 2 : 4,
            ),
            child: AgendaCard(
              title: agenda.destination,
              description: agenda.jenis,
              timeRange:
                  "${formatTime(agenda.visitStart)} - ${formatTime(agenda.visitEnd)}",
              date: formatDate(agenda.visitStart),
              image: Assets.images.avaBuilding.image(
                height: isSmallScreen
                    ? 100
                    : isMediumScreen
                    ? 120
                    : 160,
                fit: BoxFit.cover,
              ),
              picName: agenda.picOrHost,
            ),
          ),
        )
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min, // Added to reduce excessive height
      children: [
        // Alternative approach: Use ClipRect to prevent overflow
        ClipRect(
          child: Container(
            height: _getCarouselHeight(
              screenWidth,
              screenHeight,
              isSmallScreen,
              isMediumScreen,
              isTablet,
              isLargeTablet,
            ),
            width: double.infinity,
            child: CarouselSlider(
              items: imageSliders,
              carouselController: _controller,
              options: CarouselOptions(
                height: _getActualCarouselHeight(
                  screenWidth,
                  screenHeight,
                  isSmallScreen,
                  isMediumScreen,
                  isTablet,
                  isLargeTablet,
                ),
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: !isSmallScreen,
                enlargeFactor: isLargeTablet
                    ? 0.1
                    : isTablet
                    ? 0.12
                    : 0.15, // Further reduced for wide screens
                viewportFraction: _getViewportFraction(
                  isSmallScreen,
                  isMediumScreen,
                  isTablet,
                  isLargeTablet,
                ),
                enableInfiniteScroll:
                    agendas.length > 1, // Use agendas instead of dummyAgendas
                scrollDirection: Axis.horizontal,
                padEnds: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
          ),
        ),

        // Dot indicators with REDUCED spacing
        if (agendas.length > 1) // Use agendas instead of dummyAgendas
          _buildDotIndicators(agendas, isSmallScreen, isMediumScreen, isTablet),
      ],
    );
  }

  Widget _buildErrorSlider(String message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 800;

    return Container(
      height: _getCarouselHeight(
        screenWidth,
        screenHeight,
        isSmallScreen,
        isMediumScreen,
        isTablet,
        isLargeTablet,
      ),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isSmallScreen ? 40 : 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat agenda',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                agendaController.loadAgendas();
              },
              child: Text(
                'Coba Lagi',
                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    final isTablet = screenWidth >= 600;
    final isLargeTablet = screenWidth >= 800;

    return Container(
      height: _getCarouselHeight(
        screenWidth,
        screenHeight,
        isSmallScreen,
        isMediumScreen,
        isTablet,
        isLargeTablet,
      ),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: isSmallScreen ? 40 : 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada agenda hari ini',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerDots(
    bool isSmallScreen,
    bool isMediumScreen,
    bool isTablet,
  ) {
    final inactiveSize = isSmallScreen
        ? 6.0
        : isMediumScreen
        ? 8.0
        : 10.0;
    final horizontalMargin = isSmallScreen
        ? 2.0
        : isMediumScreen
        ? 3.0
        : 4.0;
    final verticalPadding = isSmallScreen
        ? 2.0
        : isMediumScreen
        ? 3.0
        : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: inactiveSize,
              height: inactiveSize,
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(inactiveSize / 2),
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }

  // Container height that accounts for enlargement
  double _getCarouselHeight(
    double screenWidth,
    double screenHeight,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isTablet,
    bool isLargeTablet,
  ) {
    double baseHeight;
    final isUltraWide = screenWidth >= 1200;

    if (isSmallScreen) {
      baseHeight = screenHeight * 0.30;
      return baseHeight;
    } else if (isMediumScreen) {
      baseHeight = screenHeight * 0.34;
      return baseHeight * 1.2;
    } else if (isTablet && !isLargeTablet) {
      baseHeight = screenHeight * 0.38;
      return baseHeight * 1.25;
    } else if (isLargeTablet && !isUltraWide) {
      baseHeight = screenHeight * 0.40;
      return baseHeight * 1.3;
    } else if (isUltraWide) {
      baseHeight = screenHeight * 0.35; // Smaller base height for ultra-wide
      return baseHeight *
          1.1; // Minimal extra height since enlargement is disabled/minimal
    } else {
      baseHeight = screenHeight * 0.36;
      return baseHeight * 1.2;
    }
  }

  // Actual carousel content height
  double _getActualCarouselHeight(
    double screenWidth,
    double screenHeight,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isTablet,
    bool isLargeTablet,
  ) {
    if (isSmallScreen) {
      return screenHeight * 0.30; // No enlargement, so same as container
    } else if (isMediumScreen) {
      return screenHeight * 0.34;
    } else if (isTablet && !isLargeTablet) {
      return screenHeight * 0.38;
    } else if (isLargeTablet) {
      return screenHeight * 0.40; // Increased height for large tablets
    } else {
      return screenHeight * 0.36;
    }
  }

  double _getViewportFraction(
    bool isSmallScreen,
    bool isMediumScreen,
    bool isTablet,
    bool isLargeTablet,
  ) {
    if (isSmallScreen) {
      return 0.92;
    } else if (isMediumScreen) {
      return 0.88;
    } else if (isTablet && !isLargeTablet) {
      return 0.75; // Show more of adjacent cards on tablets
    } else if (isLargeTablet) {
      return 0.65; // Show even more on large tablets
    } else {
      return 0.85;
    }
  }

  Widget _buildDotIndicators(
    List<AgendaModel> agendas,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isTablet,
  ) {
    // Dynamic sizing for indicators
    final activeWidth = isSmallScreen
        ? 20.0
        : isMediumScreen
        ? 24.0
        : 28.0;
    final inactiveSize = isSmallScreen
        ? 6.0
        : isMediumScreen
        ? 8.0
        : 10.0;
    final indicatorHeight = inactiveSize;
    final horizontalMargin = isSmallScreen
        ? 2.0
        : isMediumScreen
        ? 3.0
        : 4.0;

    // REDUCED vertical padding significantly
    final verticalPadding = isSmallScreen
        ? 2.0
        : isMediumScreen
        ? 3.0
        : 4.0; // Reduced from 6-10

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: agendas.asMap().entries.map((entry) {
          // Use agendas instead of dummyAgendas
          final isActive = _current == entry.key;
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isActive ? activeWidth : inactiveSize,
              height: indicatorHeight,
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(indicatorHeight / 2),
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.3),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ===== USAGE DI PARENT WIDGET =====

// Di parent widget atau page, cukup panggil AgendaSlider.
// Controller akan di-inject otomatis oleh Get.put() di dalam AgendaSlider
// atau bisa di-inject via Binding jika menggunakan GetX Navigation.
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitor App')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header atau widget lain...

            // Agenda Slider dengan GetX
            const AgendaSlider(),

            // Widget lain...
          ],
        ),
      ),
    );
  }
}
