import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool horizontal;
  final VoidCallback? onTap;

  const ReportStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.horizontal = false,
    this.onTap,
  });

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral900.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  Widget _iconBox({double padding = 8, double iconSize = 18}) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(padding + 2),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = horizontal ? _buildHorizontal() : _buildVertical();

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }

  Widget _buildHorizontal() {
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
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.neutral500),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.neutral500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVertical() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral800,
              ),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }
}
