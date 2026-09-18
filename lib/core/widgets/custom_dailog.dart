import 'package:core_project/core/theme/color/app_color.dart';
import 'package:core_project/core/theme/style/theme_style.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String negativeButtonText;
  final String positiveButtonText;
  final Color positiveTextColor;
  final VoidCallback onNegativePressed;
  final VoidCallback onPositivePressed;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.negativeButtonText = 'No',
    this.positiveButtonText = 'Yes',
    this.positiveTextColor = Colors.deepOrange,
    required this.onNegativePressed,
    required this.onPositivePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyle.interBold(textSize: 20,textColor: AppColors.black),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        SizedBox(
          width: 110,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5EA),
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: onNegativePressed,
            child: Text(negativeButtonText),
          ),
        ),
        SizedBox(
          width: 110,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5EA),
              foregroundColor: positiveTextColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: onPositivePressed,
            child: Text(positiveButtonText),
          ),
        ),
      ],
    );
  }
}