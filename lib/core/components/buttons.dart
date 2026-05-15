import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum ButtonStyleType { filled, outlined }

class Button extends StatelessWidget {
  const Button.filled({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyleType.filled,
    this.color = AppColors.primary500,
    this.textColor = Colors.white,
    this.borderColor = AppColors.primary500,
    this.width = double.infinity,
    this.height = 40.0,
    this.borderRadius = 12.0,
    this.icon,
    this.suffixIcon,
    this.disabled = false,
    this.fontSize = 18.0,
    this.isLoading = false,
  });

  const Button.filledRed({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyleType.filled,
    this.color = AppColors.error500,
    this.textColor = Colors.white,
    this.borderColor = AppColors.error500,
    this.width = double.infinity,
    this.height = 40.0,
    this.borderRadius = 12.0,
    this.icon,
    this.suffixIcon,
    this.disabled = false,
    this.fontSize = 18.0,
    this.isLoading = false,
  });

  const Button.outlined({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyleType.outlined,
    this.color = Colors.transparent,
    this.textColor = AppColors.grey800,
    this.borderColor = AppColors.primary500,
    this.width = double.infinity,
    this.height = 40.0,
    this.borderRadius = 12.0,
    this.icon,
    this.suffixIcon,
    this.disabled = false,
    this.fontSize = 18.0,
    this.isLoading = false,
  });

  const Button.outlinedRed({
    super.key,
    required this.onPressed,
    required this.label,
    this.style = ButtonStyleType.outlined,
    this.color = Colors.transparent,
    this.textColor = AppColors.error500,
    this.borderColor = AppColors.error500,
    this.width = double.infinity,
    this.height = 40.0,
    this.borderRadius = 12.0,
    this.icon,
    this.suffixIcon,
    this.disabled = false,
    this.fontSize = 18.0,
    this.isLoading = false,
  });

  const Button.iconOnly({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color = AppColors.primary500,
    this.borderColor = AppColors.primary500,
    this.borderRadius = 10.0,
    this.disabled = false,
    this.height = 44.0,
    this.width = 44.0,
    this.style = ButtonStyleType.filled,
    this.isLoading = false,
  }) : label = '',
       suffixIcon = null,
       textColor = Colors.white,
       fontSize = 18.0;

  final Function() onPressed;
  final String label;
  final ButtonStyleType style;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double? width;
  final double height;
  final double borderRadius;
  final Widget? icon;
  final Widget? suffixIcon;
  final bool disabled;
  final double fontSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isIconOnly = label.isEmpty && icon != null && suffixIcon == null;

    if (isIconOnly) {
      return SizedBox(
        height: height,
        width: width,
        child: style == ButtonStyleType.filled
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.9),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: disabled ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Center(child: icon),
                ),
              )
            : OutlinedButton(
                onPressed: disabled ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: color,
                  side: BorderSide(color: borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Center(child: icon),
              ),
      );
    }
    return SizedBox(
      height: height,
      width: width,
      child: style == ButtonStyleType.filled
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.9),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: (disabled || isLoading) ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: textColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon ?? const SizedBox.shrink(),
                          if (icon != null && label.isNotEmpty)
                            const SizedBox(width: 10.0),
                          Flexible(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: textColor,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (suffixIcon != null && label.isNotEmpty)
                            const SizedBox(width: 10.0),
                          suffixIcon ?? const SizedBox.shrink(),
                        ],
                      ),
              ),
            )
          : OutlinedButton(
              onPressed: disabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: color,
                side: BorderSide(color: borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon ?? const SizedBox.shrink(),
                  if (icon != null && label.isNotEmpty)
                    const SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (suffixIcon != null && label.isNotEmpty)
                    const SizedBox(width: 10.0),
                  suffixIcon ?? const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }
}
