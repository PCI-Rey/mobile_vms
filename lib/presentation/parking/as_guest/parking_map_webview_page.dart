import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import '../../../data/models/access_pass_model.dart';
import '../../dashboard.dart';

class ParkingMapWebViewPage extends StatefulWidget {
  final dynamic item;
  final String? customUrl;

  const ParkingMapWebViewPage({
    super.key,
    this.item,
    this.customUrl,
  });

  static const String defaultMapUrl =
      'https://parking-app.app.bio-experience.com/Maps/Public?blockSlotUid=d46a6a89-2c3f-4046-ac65-42af27b7287d';

  @override
  State<ParkingMapWebViewPage> createState() => _ParkingMapWebViewPageState();
}

class _ParkingMapWebViewPageState extends State<ParkingMapWebViewPage> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _timerPassed = false;
  bool _pageLoaded = false;
  bool _isInfoVisible = true;
  int _loadingProgress = 0;

  String get _mapUrl {
    // 1. Explicit customUrl parameter if valid
    if (widget.customUrl != null &&
        widget.customUrl!.trim().isNotEmpty &&
        widget.customUrl != 'null' &&
        widget.customUrl != '-') {
      return widget.customUrl!.trim();
    }

    // 2. Dynamic parking_map payload from AccessPassModel or Map
    if (widget.item != null) {
      String? dynamicUrl;
      try {
        if (widget.item is AccessPassModel) {
          dynamicUrl = (widget.item as AccessPassModel).parkingMap;
        } else if (widget.item is Map) {
          final raw = widget.item['parking_map'] ??
              widget.item['parkingMap'] ??
              widget.item['parking_map_url'] ??
              widget.item['map_url'];
          if (raw is Map) {
            dynamicUrl =
                (raw['url'] ?? raw['link'] ?? raw['src'])?.toString();
          } else {
            dynamicUrl = raw?.toString();
          }
        } else {
          dynamicUrl = widget.item.parkingMap?.toString();
        }
      } catch (_) {}

      if (dynamicUrl != null &&
          dynamicUrl.trim().isNotEmpty &&
          dynamicUrl.trim() != 'null' &&
          dynamicUrl.trim() != '-') {
        return dynamicUrl.trim();
      }
    }

    // 3. Fallback static URL
    return ParkingMapWebViewPage.defaultMapUrl;
  }

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E293B))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            _pageLoaded = true;
            _checkIfLoadingComplete();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[ParkingMap] Error loading page: ${error.description}');
            // Even if resource error occurs, allow display after timer
            _pageLoaded = true;
            _checkIfLoadingComplete();
          },
        ),
      )
      ..loadRequest(Uri.parse(_mapUrl));

    // User requirement: minimum 3-second loading period for 2D map
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _timerPassed = true;
        _checkIfLoadingComplete();
      }
    });

    // Fallback safety: hide loader after 6 seconds maximum
    Timer(const Duration(seconds: 6), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _checkIfLoadingComplete() {
    if (_timerPassed && (_pageLoaded || _loadingProgress >= 80)) {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.parse(_mapUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch external map URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve vehicle & parking info from passed item
    final String vehicleType = () {
      if (widget.item != null &&
          widget.item.vehicleType != null &&
          widget.item.vehicleType.toString().trim().isNotEmpty) {
        final t = widget.item.vehicleType.toString().trim();
        return t[0].toUpperCase() + t.substring(1).toLowerCase();
      }
      return 'Car';
    }();

    final String vehiclePlate = () {
      if (widget.item != null &&
          widget.item.vehiclePlateNumber != null &&
          widget.item.vehiclePlateNumber.toString().trim().isNotEmpty) {
        return widget.item.vehiclePlateNumber.toString().trim();
      }
      return '-';
    }();

    final String parkingArea = () {
      if (widget.item != null &&
          widget.item.parkingArea != null &&
          widget.item.parkingArea.toString().trim().isNotEmpty) {
        return widget.item.parkingArea.toString().trim();
      }
      return 'AREA PARKIR';
    }();

    final String parkingSlot = () {
      if (widget.item != null &&
          widget.item.parkingSlot != null &&
          widget.item.parkingSlot.toString().trim().isNotEmpty) {
        return widget.item.parkingSlot.toString().trim();
      }
      return '-';
    }();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAll(() => const Dashboard());
            }
          },
        ),
        title: Text(
          'Parking Map',
          style: TextStyle(
            fontSize: rfs(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E293B)),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _timerPassed = false;
                _pageLoaded = false;
              });
              _webViewController.reload();
              Timer(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    _timerPassed = true;
                    _isLoading = false;
                  });
                }
              });
            },
          ),
          IconButton(
            tooltip: 'Open in Browser',
            icon: const Icon(Icons.open_in_browser_rounded, color: Color(0xFF1E293B)),
            onPressed: _openExternalBrowser,
          ),
          hSpace(context, 6),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey200, height: rh(context, 1.0)),
        ),
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAll(() => const Dashboard());
            }
          }
        },
        child: Stack(
        children: [
          // ── 1. WebView 2D/3D Map ────────────────────────────────────
          Positioned.fill(
            child: WebViewWidget(controller: _webViewController),
          ),

          // ── 2. Floating Parking Information Bottom Card ─────────────
          if (_isInfoVisible)
            Positioned(
              left: rw(context, 16),
              right: rw(context, 16),
              bottom: rh(context, 20),
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.all(rw(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(rw(context, 16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: rw(context, 20),
                        offset: Offset(0, rh(context, 6)),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(rw(context, 8)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(rw(context, 10)),
                            ),
                            child: Icon(
                              Icons.directions_car_rounded,
                              color: AppColors.primary600,
                              size: rw(context, 20),
                            ),
                          ),
                          hSpace(context, 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Parking Information',
                                  style: TextStyle(
                                    fontSize: rfs(context, 15),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Your registered parking details',
                                  style: TextStyle(
                                    fontSize: rfs(context, 11),
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _isInfoVisible = false;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(rw(context, 4)),
                              child: Container(
                                width: rw(context, 28),
                                height: rw(context, 28),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF1F5F9),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: rw(context, 18),
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      vSpace(context, 12),

                      // Vehicle Details Subheading Box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(rw(context, 12)),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(rw(context, 10)),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vehicle Details',
                              style: TextStyle(
                                fontSize: rfs(context, 12),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            vSpace(context, 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailCell(
                                    context,
                                    label: 'Vehicle Type',
                                    value: vehicleType,
                                  ),
                                ),
                                Expanded(
                                  child: _buildDetailCell(
                                    context,
                                    label: 'Vehicle Plate',
                                    value: vehiclePlate,
                                  ),
                                ),
                              ],
                            ),
                            vSpace(context, 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailCell(
                                    context,
                                    label: 'Parking Area',
                                    value: parkingArea,
                                  ),
                                ),
                                Expanded(
                                  child: _buildDetailCell(
                                    context,
                                    label: 'Parking Slot',
                                    value: parkingSlot,
                                    highlight: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      vSpace(context, 10),

                      // Footer instruction note
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: rw(context, 14),
                            color: const Color(0xFF64748B),
                          ),
                          hSpace(context, 6),
                          Expanded(
                            child: Text(
                              'Please ensure your vehicle is parked in the assigned parking slot',
                              style: TextStyle(
                                fontSize: rfs(context, 11),
                                color: const Color(0xFF64748B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Collapsed Info Pill to reopen
            Positioned(
              right: rw(context, 16),
              bottom: rh(context, 20),
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isInfoVisible = true;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rw(context, 14),
                      vertical: rh(context, 10),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rw(context, 24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: rw(context, 12),
                          offset: Offset(0, rh(context, 4)),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          color: AppColors.primary600,
                          size: rw(context, 18),
                        ),
                        hSpace(context, 8),
                        Text(
                          'Parking Info',
                          style: TextStyle(
                            fontSize: rfs(context, 13),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── 3. 3-Second Loading Overlay ─────────────────────────────
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.96),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: rw(context, 32)),
                    padding: EdgeInsets.all(rw(context, 24)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(rw(context, 20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: rw(context, 24),
                          offset: Offset(0, rh(context, 8)),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: rw(context, 64),
                          height: rw(context, 64),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF4FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        vSpace(context, 18),
                        Text(
                          'Loading 2D Parking Map...',
                          style: TextStyle(
                            fontSize: rfs(context, 16),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        vSpace(context, 6),
                        Text(
                          'Connecting to parking navigation system',
                          style: TextStyle(
                            fontSize: rfs(context, 12),
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        vSpace(context, 14),
                        // Loading progress pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rw(context, 12),
                            vertical: rh(context, 4),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(rw(context, 12)),
                          ),
                          child: Text(
                            'Please wait a moment',
                            style: TextStyle(
                              fontSize: rfs(context, 11),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
  }

  Widget _buildDetailCell(
    BuildContext context, {
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: rfs(context, 10),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        vSpace(context, 2),
        Text(
          value,
          style: TextStyle(
            fontSize: rfs(context, 12),
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            color: highlight ? AppColors.primary600 : const Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
