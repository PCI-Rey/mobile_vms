import 'package:flutter/material.dart';
import '../../../../data/models/agenda_model.dart';
import '../../../core/helper/responsive_helper.dart';
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
          preferredSize: Size.fromHeight(rh(context, 1.0)),
          child: Container(color: AppColors.grey300, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(rw(context, 20.0)),
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

            vSpace(context, 24),

            // Selected Agenda Info
            if (selectedAgenda != null)
              Container(
                margin: EdgeInsets.only(bottom: rh(context, 20)),
                padding: EdgeInsets.all(rw(context, 16)),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(rw(context, 12)),
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
                          size: rw(context, 20),
                        ),
                        hSpace(context, 8),
                        Text(
                          'Selected Agenda',
                          style: TextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    vSpace(context, 8),
                    Text(
                      selectedAgenda!.destination,
                      style: TextStyles.bodyMedium,
                    ),
                    vSpace(context, 4),
                    Text(
                      selectedAgenda!.jenis,
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    vSpace(context, 4),
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
              margin: EdgeInsets.symmetric(vertical: rh(context, 50)),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAgenda == null
                    ? null // otomatis disable kalau null
                    : () {
                        _showSuccessDialog(context);
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, rh(context, 50)), // 🔹 tinggi 50
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rw(context, 10)),
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
            borderRadius: BorderRadius.circular(rw(context, 16)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Assets.images.success.image(height: rh(context, 50)),
              vSpace(context, 16),
              Text(
                'Invitation\nSuccessfully Sent!',
                style: TextStyles.headline5,
                textAlign: TextAlign.center,
              ),
              vSpace(context, 8),
              Text(
                'Your guest has been added to "${selectedAgenda?.destination}" and will receive a confirmation email with a QR Access Pass for check-in.',
                style: TextStyles.caption,
                textAlign: TextAlign.center,
              ),
              vSpace(context, 24),
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
