import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '/../../../core/components/custom_card.dart';
import '/../../../core/core.dart';
import '../agenda/widgets/extend_visit_bottom_sheet.dart';
import '../agenda/widgets/profile_dialog.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;
// import 'dart:io';

import 'package:gal/gal.dart';

class AgendaDetailPage extends StatefulWidget {
  const AgendaDetailPage({super.key});

  @override
  State<AgendaDetailPage> createState() => _AgendaDetailPageState();
}

class _AgendaDetailPageState extends State<AgendaDetailPage> {
  final GlobalKey _accessPassKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail', style: TextStyles.subtitle1),
            Text('Agenda Kedatangan', style: TextStyles.caption),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Meeting', style: TextStyles.subtitle1),
          ),
        ],
        elevation: 0,
        leading: BackButton(),
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFEEEFEF),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Button.filled(
                      onPressed: () {},
                      label: 'Track Visitor',
                      fontSize: 12,
                      textColor: AppColors.grey900,
                      color: AppColors.info500,
                    ),
                    SpaceHeight(15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Decline',
                            color: AppColors.error500,
                            fontSize: 12,
                          ),
                        ),
                        SpaceWidth(10),
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Accept',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SpaceHeight(20),
              CustomCard(
                image: Assets.icons.calendar.image(height: 18),
                size: 12,
                title: 'Mon, 26 June 2025',
                subtitle: '10.00 - 13.00',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.building.image(height: 18),
                size: 12,
                title: 'Gedung HQ',
                subtitle: 'Tap to see maps',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.lucideGroup.image(height: 18),
                size: 12,
                title: '4567892',
                subtitle: 'Group code',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.mingcuteCarFill.image(height: 18),
                size: 12,
                title: 'Slot A1',
                subtitle: 'Parking slot',
                additional: 'B1245K',
                additionalDesc: 'Vehicle Plate No.',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.person.image(height: 18),
                size: 12,
                title: 'PIC Jhon',
                subtitle: 'Host',
                backgroundIconColor: AppColors.primary500,
              ),

              const SpaceHeight(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengunjunga lain',
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'More',
                    style: TextStyles.subtitle1.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
              const SpaceHeight(20),

              Row(
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.all(5),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ProfileDialog(
                            name: 'Julian',
                            company: 'Microsoft Inc',
                            email: 'julian@mic.com',
                            image: 'assets/images/ava_person1.png',
                          ),
                        );
                      },
                      child: CustomCircleImage(
                        size: 45,
                        image: Assets.images.avaPerson1.image(height: 40),
                      ),
                    ),
                  );
                }),
              ),
              SpaceHeight(20),
              Divider(height: 1, color: AppColors.grey300),
              const SpaceHeight(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Access Pass',
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: _downloadAccessPass,
                    child: Container(
                      width: 40,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(15),
                        color: AppColors.primary500,
                      ),
                      child: Assets.icons.download.image(height: 20),
                    ),
                  ),
                ],
              ),
              const SpaceHeight(20),

              RepaintBoundary(
                key: _accessPassKey,
                child: Container(
                  color: Color(0xffFAFCFF),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '727093',
                                style: TextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Invitation code',
                                style: TextStyles.caption,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '6237181930',
                                style: TextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Card', style: TextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                      const SpaceHeight(20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFEEEFEF),
                                    offset: Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Assets.images.fakeQr.image(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Tracked',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Low Battery',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Show this while visiting',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID : 7E20A56D62B',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.grey900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SpaceHeight(20),

              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Button.filled(
                      onPressed: () {
                        showModalBottomSheet(
                          enableDrag: true,
                          isDismissible: true,
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (context) => const ExtendVisitBottomSheet(),
                        );
                      },
                      label: 'Extend',
                      color: Colors.greenAccent,
                      textColor: Colors.black,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Deny',
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Approve',
                            color: Colors.blueAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadAccessPass() async {
    try {
      // Check if Gal has access to photos
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        // Request access
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
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text("Menyimpan Access Pass..."),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

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
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text("Access Pass berhasil disimpan ke galeri"),
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

        // Handle specific Gal errors
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
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
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
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Text("Gagal menyimpan Access Pass ke galeri"),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
