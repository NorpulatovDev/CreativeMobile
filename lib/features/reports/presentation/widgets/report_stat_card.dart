import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// A compact stat card used in report pages.
///
/// [horizontal] = false (default): icon + title in a row at top, then value + subtitle below.
/// [horizontal] = true: icon on the left, title / value / subtitle stacked on the right.
class ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool horizontal;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.horizontal = false,
  });

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _iconBox({double padding = 8, double iconSize = 18}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(padding + 2),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration,
        child: Row(
          children: [
            _iconBox(padding: 12, iconSize: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: AppColors.neutral500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Vertical layout
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}
