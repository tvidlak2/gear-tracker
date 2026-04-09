import 'package:flutter/material.dart';

/// Mapuje řetězcový identifikátor kategorie na ikonu Material.
class CategoryIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.size = 24,
    this.color,
  });

  static IconData iconDataFor(String name) {
    return switch (name) {
      'rope' => Icons.cable,
      'harness' => Icons.accessibility_new,
      'helmet' => Icons.sports_motorsports,
      'belay' => Icons.loop,
      'carabiner' => Icons.link,
      'ice_axe' => Icons.carpenter,
      'crampons' => Icons.grid_on,
      'skis' => Icons.downhill_skiing,
      'backpack' => Icons.backpack,
      'tent' => Icons.cabin,
      'sleeping_bag' => Icons.bedtime,
      'bike' => Icons.directions_bike,
      _ => Icons.category_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconDataFor(iconName),
      size: size,
      color: color,
    );
  }
}
