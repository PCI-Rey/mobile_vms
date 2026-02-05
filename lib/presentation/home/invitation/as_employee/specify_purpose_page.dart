import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../presentation/home/invitation/as_employee/purpose_information_page.dart';

class SpecifyPurposePage extends StatefulWidget {
  const SpecifyPurposePage({super.key});

  @override
  State<SpecifyPurposePage> createState() => _SpecifyPurposePageState();
}

class _SpecifyPurposePageState extends State<SpecifyPurposePage> {
  String? selectedPurpose;

  final List<Map<String, String>> purposes = [
    {'value': 'occassion', 'label': 'Occassion'},
    {'value': 'meeting', 'label': 'Meeting'},
    {'value': 'delivery', 'label': 'Delivery'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Specify Purpose",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Building Image Section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Assets.images.avaBuilding.image(
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ),

          // Purpose Selection Section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purpose For Your Visit',
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Radio Button Options
                  Expanded(
                    child: Column(
                      children: purposes.map((purpose) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedPurpose = purpose['value'];
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedPurpose == purpose['value']
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300]!,
                                  width: selectedPurpose == purpose['value']
                                      ? 2
                                      : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: selectedPurpose == purpose['value']
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.05)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            selectedPurpose == purpose['value']
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color: selectedPurpose == purpose['value']
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                    ),
                                    child: selectedPurpose == purpose['value']
                                        ? const Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    purpose['label']!,
                                    style: TextStyles.bodyMedium.copyWith(
                                      color: selectedPurpose == purpose['value']
                                          ? Theme.of(context).primaryColor
                                          : Colors.black87,
                                      fontWeight:
                                          selectedPurpose == purpose['value']
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedPurpose == null
                          ? null
                          : () {
                              // Handle next action
                              _handleNext();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPurpose == null
                            ? Colors.grey[300]
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selectedPurpose == null
                              ? Colors.grey[600]
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
  context.push(PurposeInformationPage(selectedPurpose: selectedPurpose,));
  }
}
