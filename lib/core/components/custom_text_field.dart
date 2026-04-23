import 'package:flutter/material.dart';

import '../core.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final Function(String value)? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool showLabel;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final VoidCallback? onTapSuffixIcon;
  final bool isObscure;
  final IconData? suffixIconData;
  final String? errorText;
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.showLabel = true,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onTapSuffixIcon,
    this.isObscure = false,
    this.suffixIconData,
    this.errorText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpaceHeight(10.0),
        if (showLabel) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          const SpaceHeight(10.0),
        ],
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: isObscure,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon:
                suffixIcon ??
                (suffixIconData != null
                    ? GestureDetector(
                        onTap: onTapSuffixIcon,
                        child: Icon(
                          suffixIconData,
                          color: AppColors.grey550,
                          size: 18,
                        ),
                      )
                    : null),

            hintText: hintText,
            filled: true,
            fillColor: AppColors.primary50,
            contentPadding: const EdgeInsets.all(12.0),

            errorText: null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.grey300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primary500,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
