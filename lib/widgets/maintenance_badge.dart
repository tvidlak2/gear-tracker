import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/maintenance_service.dart';
import '../theme/app_theme.dart';

class MaintenanceBadge extends StatelessWidget {
  final MaintenanceStatus status;

  /// compact = true → malá barevná tečka (8 px)
  /// compact = false → pill s textem (výchozí)
  final bool compact;

  const MaintenanceBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Přesné barvy dle design specifikace (light mode),
    // tmavší varianty v dark mode přes SemanticColors extension.
    final textColor = switch (status) {
      MaintenanceStatus.overdue => context.isDark
          ? AppColors.dangerDark
          : const Color(0xFFA32D2D),
      MaintenanceStatus.warning => context.isDark
          ? AppColors.warningDark
          : const Color(0xFF854F0B),
      MaintenanceStatus.ok      => context.isDark
          ? AppColors.successDark
          : const Color(0xFF3B6D11),
    };

    final bgColor = switch (status) {
      MaintenanceStatus.overdue => context.isDark
          ? AppColors.dangerBgDark
          : const Color(0xFFFCEBEB),
      MaintenanceStatus.warning => context.isDark
          ? AppColors.warningBgDark
          : const Color(0xFFFAEEDA),
      MaintenanceStatus.ok      => context.isDark
          ? AppColors.successBgDark
          : const Color(0xFFEAF3DE),
    };

    final l10n = AppLocalizations.of(context);
    final label = switch (status) {
      MaintenanceStatus.overdue => l10n.statusOverdue,
      MaintenanceStatus.warning => l10n.statusWarning,
      MaintenanceStatus.ok      => l10n.statusOk,
    };

    if (compact) {
      // Malá barevná tečka – beze změny
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
      );
    }

    // Pill tvar – border-radius 20px
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }
}
