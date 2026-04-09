import 'dart:io';

import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/gear_item.dart';
import '../services/maintenance_service.dart';
import 'category_icon.dart';
import 'maintenance_badge.dart';

class GearCard extends StatelessWidget {
  final GearItem item;
  final Category? category;
  final MaintenanceStatus maintenanceStatus;
  final int? totalMinutes;
  final VoidCallback? onTap;

  const GearCard({
    super.key,
    required this.item,
    this.category,
    required this.maintenanceStatus,
    this.totalMinutes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant, width: 0.8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _CategoryAvatar(category: category),
              const SizedBox(width: 12),
              Expanded(child: _ItemInfo(item: item, category: category, totalMinutes: totalMinutes)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MaintenanceBadge(status: maintenanceStatus),
                  const SizedBox(height: 4),
                  if (item.status != GearStatus.active)
                    _StatusPill(status: item.status),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: cs.outlineVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Barevný avatar s ikonou kategorie ──────────────────────────────────────

class _CategoryAvatar extends StatelessWidget {
  final Category? category;
  const _CategoryAvatar({required this.category});

  /// Barva podle sportu kategorie
  static Color _sportColor(String? sport) {
    return switch (sport) {
      'lezení' => const Color(0xFF5C6BC0),       // indigo
      'skialpinismus' => const Color(0xFF0288D1), // blue
      'cyklistika' => const Color(0xFFE65100),    // deep orange
      _ => const Color(0xFF1D9E75),               // brand green
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _sportColor(category?.sport);
    final iconName = category?.icon ?? 'backpack';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CategoryIcon(iconName: iconName, size: 26, color: color),
      ),
    );
  }
}

// ── Textová část karty ─────────────────────────────────────────────────────

class _ItemInfo extends StatelessWidget {
  final GearItem item;
  final Category? category;
  final int? totalMinutes;

  const _ItemInfo({
    required this.item,
    required this.category,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final subtitle = [
      if (category != null) category!.name,
      if (item.brand != null) item.brand!,
      if (item.model != null) item.model!,
    ].join(' · ');

    final hours = totalMinutes != null
        ? (totalMinutes! / 60.0).toStringAsFixed(1)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (hours != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 13, color: cs.outline),
              const SizedBox(width: 3),
              Text(
                '$hours h',
                style: tt.labelSmall?.copyWith(color: cs.outline),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Status pill (non-active items) ─────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final GearStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      GearStatus.retired => Colors.grey,
      GearStatus.lent => Colors.blue,
      GearStatus.service => Colors.purple,
      GearStatus.active => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
