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
    }
  }

  Color get color {
    switch (this) {
      case InquiryStatus.newInquiry:
        return AppColors.primary;
      case InquiryStatus.contacted:
        return AppColors.warning;
    }
  }

  IconData get icon {
    switch (this) {
      case InquiryStatus.newInquiry:
        return Icons.fiber_new_rounded;
      case InquiryStatus.contacted:
        return Icons.phone_in_talk_rounded;
    }
  }
}