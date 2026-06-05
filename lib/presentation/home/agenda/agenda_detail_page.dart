import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/components/custom_card.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
import 'widgets/extend_visit_bottom_sheet.dart';
import 'widgets/profile_dialog.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

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
            Text('Detail', style: TextStyle(fontSize: rfs(context, 16), fontWeight: FontWeight.bold, color: Colors.black)),
            Text('Agenda Kedatangan', style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey)),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(rw(context, 8.0)),
            child: Center(
              child: Text(
                'Meeting',
                style: TextStyle(fontSize: rfs(context, 16), fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ],
        elevation: 0,
        leading: const BackButton(),
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(rw(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(rw(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEEEFEF),
                      offset: Offset(0, rh(context, 4)),
                      blurRadius: rw(context, 12),
                      spreadRadius: 0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(rw(context, 12)),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Button.filled(
                      onPressed: () {},
                      label: 'Track Visitor',
                      fontSize: rfs(context, 12),
                      textColor: AppColors.grey900,
                      color: AppColors.info500,
                    ),
                    vSpace(context, 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Decline',
                            color: AppColors.error500,
                            fontSize: rfs(context, 12),
                          ),
                        ),
                        hSpace(context, 10),
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Accept',
                            fontSize: rfs(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              vSpace(context, 20),
              CustomCard(
                image: Assets.icons.calendar.image(height: rh(context, 18)),
                size: 12,
                title: 'Mon, 26 June 2025',
                subtitle: '10.00 - 13.00',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.building.image(height: rh(context, 18)),
                size: 12,
                title: 'Gedung HQ',
                subtitle: 'Tap to see maps',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.lucideGroup.image(height: rh(context, 18)),
                size: 12,
                title: '4567892',
                subtitle: 'Group code',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.mingcuteCarFill.image(height: rh(context, 18)),
                size: 12,
                title: 'Slot A1',
                subtitle: 'Parking slot',
                additional: 'B1245K',
                additionalDesc: 'Vehicle Plate No.',
                backgroundIconColor: AppColors.primary500,
              ),
              CustomCard(
                image: Assets.icons.person.image(height: rh(context, 18)),
                size: 12,
                title: 'PIC Jhon',
                subtitle: 'Host',
                backgroundIconColor: AppColors.primary500,
              ),

              vSpace(context, 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengunjunga lain',
                    style: TextStyle(
                      fontSize: rfs(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: rfs(context, 14),
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
              vSpace(context, 20),

              Row(
                children: List.generate(6, (index) {
                  return Container(
                    margin: EdgeInsets.all(rw(context, 5)),
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
                        size: rw(context, 45),
                        image: Assets.images.avaPerson1.image(height: rw(context, 40)),
                      ),
                    ),
                  );
                }),
              ),
              vSpace(context, 20),
              Divider(height: 1, color: AppColors.grey300),
              vSpace(context, 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Access Pass',
                    style: TextStyle(
                      fontSize: rfs(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: _downloadAccessPass,
                    child: Container(
                      width: rw(context, 40),
                      padding: EdgeInsets.all(rw(context, 5)),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(rw(context, 15)),
                        color: AppColors.primary500,
                      ),
                      child: Assets.icons.download.image(height: rh(context, 20)),
                    ),
                  ),
                ],
              ),
              vSpace(context, 20),

              RepaintBoundary(
                key: _accessPassKey,
                child: Container(
                  color: const Color(0xffFAFCFF),
                  width: double.infinity,
                  padding: EdgeInsets.all(rw(context, 20)),

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
                                style: TextStyle(
                                  fontSize: rfs(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Invitation code',
                                style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '6237181930',
                                style: TextStyle(
                                  fontSize: rfs(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Card',
                                style: TextStyle(fontSize: rfs(context, 12), color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      vSpace(context, 20),
                      SizedBox(
                        width: rw(context, 172),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(rw(context, 12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEEEFEF),
                                    offset: Offset(0, rh(context, 4)),
                                    blurRadius: rw(context, 12),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Assets.images.fakeQr.image(),
                              ),
                            ),
                            vSpace(context, 8),

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

                      vSpace(context, 16),

                      Text(
                        'Show this while visiting',
                        style: TextStyle(
                          fontSize: rfs(context, 12),
                          color: AppColors.grey500,
                        ),
                      ),
                      vSpace(context, 4),
                      Text(
                        'ID : 7E20A56D62B',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: rfs(context, 16),
                          color: AppColors.grey900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              vSpace(context, 20),

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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(rw(context, 20)),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (context) => const ExtendVisitBottomSheet(),
                        );
                      },
                      label: 'Extend',
                      color: Colors.greenAccent,
                      textColor: Colors.black,
                      fontSize: rfs(context, 13),
                    ),
                    vSpace(context, 10),

                    Row(
                      children: [
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Deny',
                            color: Colors.redAccent,
                            fontSize: rfs(context, 13),
                          ),
                        ),
                        hSpace(context, 10),
                        Expanded(
                          child: Button.filled(
                            onPressed: () {},
                            label: 'Approve',
                            color: Colors.blueAccent,
                            fontSize: rfs(context, 13),
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
    }
  }
}
