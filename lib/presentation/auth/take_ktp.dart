import 'dart:io';
import 'package:flutter/material.dart';
import '../../presentation/term_of_service_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../../core/core.dart';

class TakeKtpPage extends StatefulWidget {
  const TakeKtpPage({super.key});

  @override
  State<TakeKtpPage> createState() => _TakeKtpPageState();
}

class _TakeKtpPageState extends State<TakeKtpPage> {
  File? ktpImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> takeKtpPhoto() async {
    // Navigate to camera page with frame
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KtpCameraPage(),
      ),
    );
    
    if (result != null && result is File) {
      setState(() {
        ktpImage = result;
      });
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        ktpImage = File(photo.path);
      });
    }
  }

  void goToNextStep() {
    if (ktpImage != null) {
      context.push(TermsOfServicePage());
    } else {
      context.push(TermsOfServicePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto KTP'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ktpImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            ktpImage!,
                            width: 200,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Assets.images.ktpImg.image(height: 142),

                  const SizedBox(height: 16),
                  const Text(
                    'Foto KTP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ambil KTP, SIM, atau foto paspor.\nPastikan foto jelas dan seluruh dokumen terlihat.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: takeKtpPhoto,
                        icon: const FaIcon(
                          FontAwesomeIcons.camera,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          'Ambil Foto',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: pickFromGallery,
                        icon: const FaIcon(
                          FontAwesomeIcons.image,
                          color: Colors.blue,
                        ),
                        label: const Text(
                          'Dari Galeri',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sebelumnya',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selanjutnya',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class KtpCameraPage extends StatefulWidget {
  const KtpCameraPage({super.key});

  @override
  State<KtpCameraPage> createState() => _KtpCameraPageState();
}

class _KtpCameraPageState extends State<KtpCameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      try {
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
      }
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await _controller!.takePicture();
      final File imageFile = File(photo.path);
      
      if (mounted) {
        Navigator.pop(context, imageFile);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ambil Foto KTP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),
          
          // Frame overlay
          CustomPaint(
            painter: KtpFramePainter(),
            child: Container(),
          ),
          
          // Instructions
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Posisikan KTP di dalam frame\nPastikan semua bagian terlihat jelas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Capture button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing ? Colors.grey : Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: _isCapturing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black54,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.black87,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KtpFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final cornerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Calculate frame dimensions (credit card ratio: 85.6 × 53.98 mm ≈ 1.59:1)
    final frameWidth = size.width * 0.8;
    final frameHeight = frameWidth / 1.59;
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;

    // Draw overlay (darken everything except the frame)
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, paint);

    // Draw frame border
    final frameRect = Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(12)),
      framePaint,
    );

    // Draw corner guidelines
    final cornerLength = 30.0;
    
    // Top-left corner
    canvas.drawLine(
      Offset(frameLeft, frameTop + cornerLength),
      Offset(frameLeft, frameTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft + cornerLength, frameTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(frameLeft + frameWidth - cornerLength, frameTop),
      Offset(frameLeft + frameWidth, frameTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameWidth, frameTop),
      Offset(frameLeft + frameWidth, frameTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameHeight - cornerLength),
      Offset(frameLeft, frameTop + frameHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameHeight),
      Offset(frameLeft + cornerLength, frameTop + frameHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(frameLeft + frameWidth - cornerLength, frameTop + frameHeight),
      Offset(frameLeft + frameWidth, frameTop + frameHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameWidth, frameTop + frameHeight - cornerLength),
      Offset(frameLeft + frameWidth, frameTop + frameHeight),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}