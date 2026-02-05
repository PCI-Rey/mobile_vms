import 'package:flutter/material.dart';
import '../../core/components/components.dart';
import '../../core/constants/colors.dart';
import 'package:signature/signature.dart';

class SignAgreementPage extends StatefulWidget {
  const SignAgreementPage({super.key});

  @override
  State<SignAgreementPage> createState() => _SignAgreementPageState();
}

class _SignAgreementPageState extends State<SignAgreementPage> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tandatangan perjanjian'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NON DISCLOSURE AGREEMENT\n\n'
                'This NDA is made between ...\n\n'
                'You can replace this with actual text or PDF viewer.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tanda tangan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              height: 160,
              width: double.infinity,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _signatureController.clear(),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Button.outlined(
                    label: 'Sebelumnya',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button.filled(
                    label: 'Selanjutnya',
                    onPressed: () {
                      if (_signatureController.isNotEmpty) {}
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
