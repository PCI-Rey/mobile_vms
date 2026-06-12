import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/core.dart';
import '../../../core/helper/responsive_helper.dart';
import '../../../data/models/access_pass_model.dart';

class AccessPassDialog extends StatefulWidget {
  final List<AccessPassModel> items;

  const AccessPassDialog({super.key, required this.items});

  @override
  State<AccessPassDialog> createState() => _AccessPassDialogState();
}

class _AccessPassDialogState extends State<AccessPassDialog> {
  final GlobalKey _accessPassKey = GlobalKey();
  bool _isCapturing = false; // State untuk hide/show download button
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + 60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 28)),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rw(context, 28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Padding(
                      padding: EdgeInsets.only(top: rh(context, 12)),
                      child: Container(
                        width: rw(context, 40),
                        height: rh(context, 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(rw(context, 2)),
                        ),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: rw(context, 20),
                        vertical: rh(context, 14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(rw(context, 10)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF005596).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(rw(context, 10)),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFF005596),
                            ),
                          ),
                          hSpace(context, 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Your Access Pass',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: rfs(context, 16),
                                    color: Colors.black87,
                                  ),
                                ),
                                vSpace(context, 2),
                                Text(
                                  'Show this pass at the gate',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: rfs(context, 13),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.items.isNotEmpty) ...[
                            hSpace(context, 8),
                            (() {
                              final item = widget.items[_currentIndex];
                              final String badgeText;
                              if (item.flow.isNotEmpty) {
                                badgeText = item.flow.toLowerCase() == 'praregister' ? 'Praregis' : (item.flow.toLowerCase() == 'quickaccessvisit' ? 'Quick Access' : item.flow);
                              } else {
                                badgeText = item.visitorStatus.isNotEmpty ? item.visitorStatus : 'Invitation';
                              }
                              
                              final String cleanText = badgeText[0].toUpperCase() + badgeText.substring(1);
                              final Color badgeColor = _statusColor(badgeText);
                              
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rw(context, 10),
                                  vertical: rh(context, 5),
                                ),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(rw(context, 20)),
                                ),
                                child: Text(
                                  cleanText,
                                  style: TextStyle(
                                    fontSize: rfs(context, 11),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            })(),
                            hSpace(context, 6),
                            (() {
                              final item = widget.items[_currentIndex];
                              final isExpired = item.visitorPeriodEnd.isBefore(DateTime.now());
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rw(context, 10),
                                  vertical: rh(context, 5),
                                ),
                                decoration: BoxDecoration(
                                  color: isExpired
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF43A047),
                                  borderRadius: BorderRadius.circular(rw(context, 20)),
                                ),
                                child: Text(
                                  isExpired ? 'Expired' : 'Active',
                                  style: TextStyle(
                                    fontSize: rfs(context, 11),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            })(),
                          ],
                        ],
                      ),
                    ),
                    Container(height: 1, color: Colors.grey.shade100),

                    // Content - Carousel Body
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CarouselSlider.builder(
                              itemCount: widget.items.length,
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                height: rh(context, 550),
                                autoPlay: false,
                                enlargeCenterPage: true,
                                enlargeFactor: 0.15,
                                viewportFraction: 0.9,
                                enableInfiniteScroll: widget.items.length > 1,
                                scrollDirection: Axis.horizontal,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                              itemBuilder: (context, index, realIndex) {
                                final item = widget.items[index];
                                final startStr = DateFormat(
                                  'EEEE, dd MMMM yyyy • HH:mm',
                                  'en',
                                ).format(item.visitorPeriodStart);
                                final endStr = DateFormat(
                                  'HH:mm',
                                  'en',
                                ).format(item.visitorPeriodEnd);

                                return SingleChildScrollView(
                                  child: RepaintBoundary(
                                    key: index == _currentIndex
                                        ? _accessPassKey
                                        : null,
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.white,
                                      padding: EdgeInsets.only(
                                        left: rw(context, 24),
                                        right: rw(context, 24),
                                        top: rh(context, 16),
                                      ),
                                      child: Column(
                                        children: [
                                          // User info section
                                          Row(
                                            children: [
                                              // Profile picture with border
                                              Container(
                                                width: rw(context, 52),
                                                height: rw(context, 52),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                    width: 2,
                                                  ),
                                                  color: AppColors.grey200,
                                                ),
                                                child:
                                                    item.visitorName
                                                        .toLowerCase()
                                                        .contains('endru')
                                                    ? ClipOval(
                                                        child: Image.asset(
                                                          'assets/images/Endru.png',
                                                          width: rw(
                                                            context,
                                                            52,
                                                          ),
                                                          height: rw(
                                                            context,
                                                            52,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        size: rw(context, 32),
                                                        color:
                                                            AppColors.grey600,
                                                      ),
                                              ),
                                              hSpace(context, 12),

                                              // User details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.visitorName,
                                                      style: TextStyle(
                                                        fontSize: rfs(
                                                          context,
                                                          18,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: const Color(
                                                          0xFF0F172A,
                                                        ),
                                                        letterSpacing: -0.4,
                                                      ),
                                                    ),
                                                    vSpace(context, 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.access_time,
                                                          size: rw(context, 13),
                                                          color: const Color(
                                                            0xFF64748B,
                                                          ),
                                                        ),
                                                        hSpace(context, 4),
                                                        Expanded(
                                                          child: Text(
                                                            '$startStr - $endStr',
                                                            style: TextStyle(
                                                              fontSize: rfs(
                                                                context,
                                                                12,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  const Color(
                                                                    0xFF64748B,
                                                                  ),
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Download button - Hidden saat capturing
                                              AnimatedOpacity(
                                                opacity: _isCapturing
                                                    ? 0.0
                                                    : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                child: GestureDetector(
                                                  onTap: _isCapturing
                                                      ? null
                                                      : _downloadAccessPass,
                                                  child: Container(
                                                    width: rw(context, 42),
                                                    height: rw(context, 42),
                                                    decoration: BoxDecoration(
                                                      color: _isCapturing
                                                          ? Colors.transparent
                                                          : const Color(
                                                              0xFFE8F1FB,
                                                            ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: _isCapturing
                                                        ? const SizedBox.shrink()
                                                        : const Icon(
                                                            Icons
                                                                .download_rounded,
                                                            size: 20,
                                                            color: Color(
                                                              0xFF1976D2,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          vSpace(context, 20),

                                          // Structured Info Card Grid
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: rw(context, 16),
                                              vertical: rh(context, 16),
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    rw(context, 16),
                                                  ),
                                              border: Border.all(
                                                color: const Color(0xFFF1F5F9),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          right: rw(context, 8),
                                                        ),
                                                        child: _buildInfoCard(
                                                          item.invitationCode,
                                                          'Invitation Code',
                                                          Icons
                                                              .confirmation_number_outlined,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      height: rh(context, 36),
                                                      color: const Color(
                                                        0xFFE2E8F0,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          left: rw(context, 8),
                                                        ),
                                                        child: _buildInfoCard(
                                                          item.agenda,
                                                          'Agenda',
                                                          Icons
                                                              .event_note_outlined,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  color: const Color(
                                                    0xFFE2E8F0,
                                                  ),
                                                  height: rh(context, 24),
                                                  thickness: 1,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          right: rw(context, 8),
                                                        ),
                                                        child: _buildInfoCard(
                                                          item.sitePlaceName.isNotEmpty ? item.sitePlaceName : '-',
                                                          'Location',
                                                          Icons.location_on_outlined,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 1,
                                                      height: rh(context, 36),
                                                      color: const Color(
                                                        0xFFE2E8F0,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(
                                                          left: rw(context, 8),
                                                        ),
                                                        child: _buildInfoCard(
                                                          item
                                                                  .visitorPhone
                                                                  .isNotEmpty
                                                              ? item.visitorPhone
                                                              : (item
                                                                        .receiverPhone
                                                                        .isNotEmpty
                                                                    ? item.receiverPhone
                                                                    : '08123456789'),
                                                          'Phone',
                                                          Icons.phone_outlined,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          vSpace(context, 20),

                                          // QR Access Pass Card Container
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(
                                              rw(context, 16),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    rw(context, 16),
                                                  ),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    'Access Pass',
                                                    style: TextStyle(
                                                      fontSize: rfs(
                                                        context,
                                                        18,
                                                      ),
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                                vSpace(context, 12),

                                                Container(
                                                  width: rw(context, 195),
                                                  height: rw(context, 195),
                                                  padding: EdgeInsets.all(
                                                    rw(context, 10),
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          rw(context, 10),
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                  ),
                                                  child:
                                                      _buildQRCodePlaceholder(
                                                        item
                                                                .visitorNumber
                                                                .isNotEmpty
                                                            ? item.visitorNumber
                                                            : item.id,
                                                      ),
                                                ),
                                                vSpace(context, 12),

                                                if (item.visitorStatus
                                                        .toLowerCase()
                                                        .contains('track') ||
                                                    item.visitorStatus
                                                        .toLowerCase()
                                                        .contains('low')) ...[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (item.visitorStatus
                                                          .toLowerCase()
                                                          .contains('track'))
                                                        Text(
                                                          'Tracked',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .red
                                                                .shade600,
                                                            fontSize: rfs(
                                                              context,
                                                              11,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      if (item.visitorStatus
                                                              .toLowerCase()
                                                              .contains(
                                                                'track',
                                                              ) &&
                                                          item.visitorStatus
                                                              .toLowerCase()
                                                              .contains('low'))
                                                        hSpace(context, 16),
                                                      if (item.visitorStatus
                                                          .toLowerCase()
                                                          .contains('low'))
                                                        Text(
                                                          'Low Battery',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .red
                                                                .shade600,
                                                            fontSize: rfs(
                                                              context,
                                                              11,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  vSpace(context, 10),
                                                ],

                                                Text(
                                                  'Show this while visiting',
                                                  style: TextStyle(
                                                    fontSize: rfs(context, 12),
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                vSpace(context, 2),

                                                Text(
                                                  'ID : ${item.visitorNumber.isNotEmpty ? item.visitorNumber : item.id}',
                                                  style: TextStyle(
                                                    fontSize: rfs(context, 13),
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          vSpace(context, 24),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (widget.items.length > 1) ...[
                            vSpace(context, 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: rw(context, 20)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: widget.items.asMap().entries.map((
                                    entry,
                                  ) {
                                    final isActive = _currentIndex == entry.key;
                                    return GestureDetector(
                                      onTap: () => _carouselController
                                          .animateToPage(entry.key),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        width: isActive
                                            ? rw(context, 20.0)
                                            : rw(context, 6.0),
                                        height: rw(context, 6.0),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: rw(context, 3.0),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3.0),
                                          color: isActive
                                              ? const Color(0xFF005596)
                                              : const Color(
                                                  0xFF005596,
                                                ).withValues(alpha: 0.3),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Close button (Unified Blue color)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        rw(context, 24),
                        rh(context, 8),
                        rw(context, 24),
                        rh(context, 24),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: rh(context, 50),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005596),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                rw(context, 14),
                              ),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: rfs(context, 16),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String value, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: rw(context, 13), color: const Color(0xFF64748B)),
            hSpace(context, 6),
            Text(
              label,
              style: TextStyle(
                fontSize: rfs(context, 11),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        vSpace(context, 4),
        Text(
          value.isEmpty ? '-' : value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: rfs(context, 13),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodePlaceholder(String qrData) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: QrImageView(
        data: qrData.isNotEmpty ? qrData : 'N/A',
        version: QrVersions.auto,
        size: double.infinity,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _downloadAccessPass() async {
    try {
      // Check if Gal has access to photos
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final requestGranted = await Gal.requestAccess();
        if (!requestGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Permission diperlukan untuk menyimpan gambar ke galeri",
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: rw(context, 16),
                  height: rw(context, 16),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                hSpace(context, 16),
                const Text("Menyimpan Access Pass..."),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Set capturing state to true - Hide download button
      setState(() {
        _isCapturing = true;
      });

      // Wait for UI to update
      await Future.delayed(const Duration(milliseconds: 300));

      // Capture widget sebagai gambar
      RenderRepaintBoundary boundary =
          _accessPassKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Simpan ke galeri menggunakan Gal
      await Gal.putImageBytes(
        pngBytes,
        name: "access_pass_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                hSpace(context, 16),
                const Text("Access Pass berhasil disimpan ke galeri"),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on GalException catch (e) {
      debugPrint(
        "Gal error while saving access pass: ${e.type} - ${e.platformException}",
      );
      if (mounted) {
        String errorMessage = "Gagal menyimpan Access Pass ke galeri";

        switch (e.type) {
          case GalExceptionType.accessDenied:
            errorMessage =
                "Akses ditolak. Mohon berikan izin untuk menyimpan gambar.";
            break;
          case GalExceptionType.notEnoughSpace:
            errorMessage = "Ruang penyimpanan tidak cukup.";
            break;
          case GalExceptionType.notSupportedFormat:
            errorMessage = "Format gambar tidak didukung.";
            break;
          case GalExceptionType.unexpected:
            errorMessage = "Terjadi kesalahan tak terduga.";
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                hSpace(context, 16),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint("Unexpected error while saving access pass: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                hSpace(context, 16),
                const Text("Gagal menyimpan Access Pass ke galeri"),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset capturing state - Show download button again
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'checkin':
      case 'approved':
      case 'approve':
      case 'success':
        return const Color(0xFF00897B);
      case 'checkout':
        return const Color(0xFF3949AB);
      case 'available':
        return const Color(0xFF8E24AA);
      case 'waiting':
      case 'pending':
        return const Color(0xFFFB8C00);
      case 'denied':
      case 'deny':
      case 'rejected':
      case 'reject':
        return const Color(0xFFE53935);
      case 'quickaccess':
      case 'quickaccessvisit':
        return const Color(0xFFD81B60);
      case 'preregis':
      case 'praregister':
      case 'praregis':
        return const Color(0xFF00B0FF);
      default:
        return const Color(0xFF546E7A);
    }
  }
}

// Custom painter untuk QR Code placeholder
class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D3E50)
      ..style = PaintingStyle.fill;

    final blockSize = size.width / 21;

    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1],
      [1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0],
      [0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1],
      [1, 0, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0],
    ];

    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[i].length; j++) {
        if (pattern[i][j] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(j * blockSize, i * blockSize, blockSize, blockSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function to show the access pass bottom sheet
void showAccessPassDialog({
  required BuildContext context,
  required List<AccessPassModel> items,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    builder: (context) => AccessPassDialog(items: items),
  );
}
