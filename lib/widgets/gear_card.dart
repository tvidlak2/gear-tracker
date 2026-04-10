import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/gear_item.dart';
import '../services/maintenance_service.dart';
import '../theme/app_theme.dart';
import 'category_icon.dart';
import 'maintenance_badge.dart';

class GearCard extends StatelessWidget {
  final GearItem item;
  final Category? category;
  final MaintenanceStatus maintenanceStatus;
  final int? totalMinutes;
  final double? totalKm;
  final bool isAlternate;
  final VoidCallback? onTap;

  const GearCard({
    super.key,
    required this.item,
    this.category,
    required this.maintenanceStatus,
    this.totalMinutes,
    this.totalKm,
    this.isAlternate = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.isDark
            ? AppColors.darkCard
            : (isAlternate ? const Color(0xFFFAFAFA) : Colors.white),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.cardBorderColor, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _SportAvatar(category: category),
                const SizedBox(width: 12),
                Expanded(
                  child: _ItemInfo(
                    item: item,
                    category: category,
                    totalMinutes: totalMinutes,
                    totalKm: totalKm,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MaintenanceBadge(status: maintenanceStatus),
                    if (item.status != GearStatus.active) ...[
                      const SizedBox(height: 4),
                      _StatusPill(status: item.status),
                    ],
                  ],
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.subtitleColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Barevný čtverec s ikonou sportu ─────────────────────────────────────────

class _SportAvatar extends StatelessWidget {
  final Category? category;
  const _SportAvatar({required this.category});

  // Ikona barva podle icon name
  static Color _iconColor(String? icon) => switch (icon) {
    'rope'        => const Color(0xFFE8A020),  // oranžová – lano/horolezení
    'bike'        => const Color(0xFF378ADD),  // modrá    – kolo/MTB
    'harness'     => const Color(0xFF7F77DD),  // fialová  – úvazek
    'skis'        => const Color(0xFF7F77DD),  // fialová  – lyže
    'paraglider'  => const Color(0xFF1D9E75),  // zelená   – paragliding
    _             => const Color(0xFF757575),  // šedá     – obecné
  };

  // Pozadí čtverce podle icon name (light mode)
  static Color _iconBgColor(String? icon) => switch (icon) {
    'rope'        => const Color(0xFFFAEEDA),  // oranžová – lano
    'bike'        => const Color(0xFFE6F1FB),  // modrá    – kolo
    'harness'     => const Color(0xFFEDE7F6),  // fialová  – úvazek
    'skis'        => const Color(0xFFEDE7F6),  // fialová  – lyže
    'paraglider'  => const Color(0xFFE1F5EE),  // zelená   – paragliding
    _             => const Color(0xFFF5F5F5),  // šedá     – obecné
  };

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColor(category?.icon);
    final bgColor   = context.isDark
        ? iconColor.withOpacity(0.18)
        : _iconBgColor(category?.icon);
    final iconName  = category?.icon ?? 'backpack';

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CategoryIcon(iconName: iconName, size: 24, color: iconColor),
      ),
    );
  }
}

// ─── Textová část ─────────────────────────────────────────────────────────────

class _ItemInfo extends StatelessWidget {
  final GearItem item;
  final Category? category;
  final int? totalMinutes;
  final double? totalKm;

  const _ItemInfo({
    required this.item,
    required this.category,
    required this.totalMinutes,
    this.totalKm,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (category != null) category!.name,
      if (item.brand != null) item.brand!,
      if (item.model != null) item.model!,
    ].join(' · ');

    final hours = totalMinutes != null
        ? (totalMinutes! / 60.0).round().toString()
        : null;

    final kmParts = <String>[];
    if (hours != null) kmParts.add('$hours h');
    if (totalKm != null && totalKm! > 0) {
      final rounded = totalKm!.round();
      final kmStr = rounded >= 1000
          ? '${(rounded ~/ 1000)} ${(rounded % 1000).toString().padLeft(3, '0')} km'
          : '$rounded km';
      kmParts.add(kmStr);
    }
    final usageLine = kmParts.isEmpty ? null : kmParts.join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: context.subtitleColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (usageLine != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 12, color: context.subtitleColor),
              const SizedBox(width: 3),
              Text(
                usageLine,
                style: TextStyle(fontSize: 11, color: context.subtitleColor),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Status pill pro ne-aktivní položky ───────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final GearStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GearStatus.retired => Colors.grey,
      GearStatus.lent    => Colors.blue,
      GearStatus.service => Colors.purple,
      GearStatus.active  => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
