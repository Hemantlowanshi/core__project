import 'package:flutter/material.dart';
import '../../../core/theme/color/app_color.dart';
import '../../../core/theme/style/theme_style.dart';

class LocationBottomSheet extends StatelessWidget {
  final String address;
  final TextEditingController locationNameController;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const LocationBottomSheet({
    super.key,
    required this.address,
    required this.locationNameController,
    required this.onClose,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Address Label
              Text(
                'Address',
                style: AppTextStyle.interRegular(
                  textSize: 13,
                  textColor: AppColors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address.isNotEmpty ? address : 'Getting address...',
                style: AppTextStyle.interSemiBold(
                  textSize: 15,
                  textColor: AppColors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Location Name Label
              Text(
                'Location Name',
                style: AppTextStyle.interRegular(
                  textSize: 13,
                  textColor: AppColors.grey,
                ),
              ),
              const SizedBox(height: 8),
              // TextField
              TextField(
                controller: locationNameController,
                style: AppTextStyle.interRegular(
                  textSize: 14,
                  textColor: AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Location Name',
                  hintStyle: AppTextStyle.interRegular(
                    textSize: 14,
                    textColor: AppColors.grey,
                  ),
                  filled: true,
                  fillColor: AppColors.ultraLightGrey.withOpacity(0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Save Address Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EE6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Save Address',
                    style: AppTextStyle.interBold(
                      textSize: 16,
                      textColor: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
