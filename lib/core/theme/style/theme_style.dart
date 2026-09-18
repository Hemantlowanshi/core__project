import 'package:flutter/material.dart';

import '../color/app_color.dart';
import '../font/font.dart';


class AppTextStyle {
  AppTextStyle._();

  static TextStyle interRegular({
    Color? textColor,
    double? textSize,
  }) {
    return TextStyle(
      fontSize: textSize ?? 14.0,
      fontFamily: Fonts.interRegular,
      color: textColor ?? AppColors.textPrimary,
    );
  }

  static TextStyle interMedium({
    Color? textColor,
    double? textSize,
  }) {
    return TextStyle(
      fontSize: textSize ?? 14.0,
      fontFamily: Fonts.interMedium,
      color: textColor ?? AppColors.textPrimary,
    );
  }

  static TextStyle interSemiBold({
    Color? textColor,
    double? textSize,
  }) {
    return TextStyle(
      fontSize: textSize ?? 14.0,
      fontFamily: Fonts.interSemiBold,
      color: textColor ?? AppColors.textPrimary,
    );
  }

  static TextStyle interBold({
    Color? textColor,
    double? textSize,
  }) {
    return TextStyle(
      fontSize: textSize ?? 14.0,
      fontFamily: Fonts.interBold,
      color: textColor ?? AppColors.textPrimary,
    );
  }

  static TextStyle ppMoriSemiBold({
    Color? textColor,
    double? textSize,
  }) {
    return TextStyle(
      fontSize: textSize ?? 14.0,
      fontFamily: Fonts.ppMoriSemiBold,
      color: textColor ?? AppColors.textPrimary,
    );
  }

  static TextStyle ppMoriRegular({
    Color? textColor,
    double? textSize,
  }) {
    return TextStyle(
      fontSize: textSize ?? 14.0,
      fontFamily: Fonts.ppMoriRegular,
      color: textColor ?? AppColors.textPrimary,
    );
  }
}

