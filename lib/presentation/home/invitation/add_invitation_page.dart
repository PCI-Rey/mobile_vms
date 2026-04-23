import 'package:flutter/material.dart';
import '../../../../data/models/agenda_model.dart';
import '../../../core/core.dart';
import 'widgets/selected_agenda_slider.dart';

class AddInvitationPage extends StatefulWidget {
  const AddInvitationPage({super.key});

  @override
  State<AddInvitationPage> createState() => _AddInvitationPageState();
}

class _AddInvitationPageState extends State<AddInvitationPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController organisasiController = TextEditingController();

  AgendaModel? selectedAgenda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Add Invitation"),
        leading: const BackButton(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selectable Agenda Slider
            SelectableAgendaSlider(
              selectedAgenda: selectedAgenda,
              onAgendaSelected: (agenda) {
                setState(() {
                  selectedAgenda = agenda;
                });
              },
            ),

            const SizedBox(height: 24),

            // Selected Agenda Info
            if (selectedAgenda != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Agenda',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedAgenda!.destination,
                      style: TextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedAgenda!.jenis,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${formatTime(selectedAgenda!.visitStart)} - ${formatTime(selectedAgenda!.visitEnd)}",
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            // Form Fields
            CustomTextField(controller: nameController, label: 'Nama'),
            CustomTextField(controller: emailController, label: 'Email'),
            CustomTextField(controller: phoneController, label: 'Nomor Hp'),
            CustomTextField(
              controller: organisasiController,
              label: 'Organisasi',
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 50),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAgenda == null
                    ? null // otomatis disable kalau null
                    : () {
                        _showSuccessDialog(context);
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // 🔹 tinggi 40
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: selectedAgenda == null
                      ? Colors.grey[300]
                      : Theme.of(context).primaryColor,
                  foregroundColor: selectedAgenda == null
                      ? Colors.grey[600]
                      : Colors.white,
                ),
                child: const Text('Send Invitation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Assets.images.success.image(height: 50),
              const SizedBox(height: 16),
              Text(
                'Invitation\nSuccessfully Sent!',
                style: TextStyles.headline5,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your guest has been added to "${selectedAgenda?.destination}" and will receive a confirmation email with a QR Access Pass for check-in.',
                style: TextStyles.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Button.filled(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Clear form and selection
                  setState(() {
                    selectedAgenda = null;
                    nameController.clear();
                    emailController.clear();
                    phoneController.clear();
                    organisasiController.clear();
                  });
                },
                label: 'OK',
              ),
            ],
          ),
        );
      },
    );
  }
}
