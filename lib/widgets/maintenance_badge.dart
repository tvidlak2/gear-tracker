import 'package:flutter/material.dart';

import '../services/maintenance_service.dart';

class MaintenanceBadge extends StatelessWidget {
  final MaintenanceStatus status;
  final bool compact;

  const MaintenanceBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (status) {
      MaintenanceStatus.overdue => (Icons.warning, Colors.red, 'Servis!'),
      MaintenanceStatus.warning => (Icons.info_outline, Colors.orange, 'Brzy'),
      MaintenanceStatus.ok => (Icons.check_circle_outline, Colors.green, 'OK'),
    };

    if (compact) {
      return Icon(icon, color: color, size: 18);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
