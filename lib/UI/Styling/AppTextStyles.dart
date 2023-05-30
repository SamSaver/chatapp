import 'package:chatapp/Constants/AppColors.dart';
import 'package:chatapp/Constants/MiscDouble.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  // font16
  static const TextStyle font16 = TextStyle(
    fontSize: MiscDouble.size16,
  );
  static const TextStyle font16White =
      TextStyle(fontSize: MiscDouble.size16, color: AppColor.white);
  static const TextStyle fontWhite = TextStyle(color: AppColor.white);
  static const TextStyle fontBlue = TextStyle(color: AppColor.blue);
  static const TextStyle fontBlueBold45 = TextStyle(
      color: AppColor.blue, fontSize: 45, fontWeight: FontWeight.bold);
}
