import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/inquiry_model.dart';

extension InquiryStatusExtension on InquiryStatus {
  String get displayName {
    switch (this) {
      case InquiryStatus.newInquiry:
        return 'Yangi';
      case InquiryStatus.contacted:
        return 'Bog\'lanildi';
      case InquiryStatus.enrolled:
        return 'Ro\'yxatdan o\'tdi';
      case InquiryStatus.rejected:
        return 'Rad etildi';
    }
  }

  Color get color {
    switch (this) {
      case InquiryStatus.newInquiry:
        return AppColors.primary;
      case InquiryStatus.contacted:
        return AppColors.warning;
      case InquiryStatus.enrolled:
        return AppColors.success;
      case InquiryStatus.rejected:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case InquiryStatus.newInquiry:
        return Icons.fiber_new_rounded;
      case InquiryStatus.contacted:
        return Icons.phone_in_talk_rounded;
      case InquiryStatus.enrolled:
        return Icons.check_circle_rounded;
      case InquiryStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}