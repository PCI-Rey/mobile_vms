import 'package:flutter/material.dart';
import '../../../../core/core.dart';
import '../../../../core/helper/responsive_helper.dart';
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
        title: Text(
          "Specify Purpose",
          style: TextStyle(
            color: Colors.black,
            fontSize: rfs(context, 18),
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
              padding: EdgeInsets.all(rw(context, 20)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(rw(context, 16)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(rw(context, 16)),
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
              padding: EdgeInsets.all(rw(context, 20)),
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
                  vSpace(context, 20),

                  // Radio Button Options
                  Expanded(
                    child: Column(
                      children: purposes.map((purpose) {
                        return Container(
                          margin: EdgeInsets.only(bottom: rh(context, 12)),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedPurpose = purpose['value'];
                              });
                            },
                            borderRadius: BorderRadius.circular(rw(context, 8)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: rh(context, 16),
                                horizontal: rw(context, 12),
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
                                borderRadius: BorderRadius.circular(rw(context, 8)),
                                color: selectedPurpose == purpose['value']
                                    ? Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.05)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: rw(context, 20),
                                    height: rw(context, 20),
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
                                        ? Icon(
                                            Icons.circle,
                                            size: rw(context, 8),
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  hSpace(context, 12),
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

                  vSpace(context, 20),

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
                        minimumSize: Size(double.infinity, rh(context, 50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rw(context, 8)),
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
