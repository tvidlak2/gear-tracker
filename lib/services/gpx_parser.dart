/// Minimal GPX file parser.
///
/// Extracts date, total track distance, duration, and track name
/// using simple string/regex search (no XML dependency).
library;

import 'dart:math' as math;

class GpxActivity {
  final DateTime? date;
  final double?   distanceKm;
  final int?      durationMinutes;
  final String?   trackName;

  const GpxActivity({
    this.date,
    this.distanceKm,
    this.durationMinutes,
    this.trackName,
  });
}

class GpxParser {
  // Regexes – GPX is well-formed XML so these are reliable enough
  static final _timeTag    = RegExp(r'<time>\s*([^<]+)\s*</time>');
  static final _trkpt      = RegExp(
    r'<trkpt\s[^>]*lat="([^"]+)"[^>]*lon="([^"]+)"',
  );
  static final _trkptWithTime = RegExp(
    r'<trkpt\s[^>]*lat="([^"]+)"[^>]*lon="([^"]+)"[^>]*>(?:(?!<\/trkpt>).)*'
    r'<time>\s*([^<]+)\s*</time>',
    dotAll: true,
  );
  static final _nameTag    = RegExp(r'<name>\s*([^<]+)\s*</name>');

  static GpxActivity parse(String content) {
    // ── Name ───────────────────────────────────────────────────────────────
    final nameMatch = _nameTag.firstMatch(content);
    final trackName = nameMatch?.group(1)?.trim();

    // ── Date: first <time> in the file ────────────────────────────────────
    DateTime? date;
    final firstTime = _timeTag.firstMatch(content);
    if (firstTime != null) {
      date = _parseIso(firstTime.group(1)!.trim());
    }

    // ── Track points with timestamps ───────────────────────────────────────
    final ptMatches = _trkptWithTime.allMatches(content).toList();

    // ── Duration from first/last trkpt time ───────────────────────────────
    int? durationMinutes;
    if (ptMatches.length >= 2) {
      final t0 = _parseIso(ptMatches.first.group(3)!.trim());
      final t1 = _parseIso(ptMatches.last.group(3)!.trim());
      if (t0 != null && t1 != null) {
        final diffSec = t1.difference(t0).inSeconds;
        durationMinutes = (diffSec / 60).round();
        date ??= t0;
      }
    }

    // If no trkpt timestamps, fall back to plain trkpt matches for coords
    final coords = <({double lat, double lon})>[];
    if (ptMatches.isNotEmpty) {
      for (final m in ptMatches) {
        final lat = double.tryParse(m.group(1)!);
        final lon = double.tryParse(m.group(2)!);
        if (lat != null && lon != null) coords.add((lat: lat, lon: lon));
      }
    } else {
      for (final m in _trkpt.allMatches(content)) {
        final lat = double.tryParse(m.group(1)!);
        final lon = double.tryParse(m.group(2)!);
        if (lat != null && lon != null) coords.add((lat: lat, lon: lon));
      }
    }

    // ── Distance from consecutive coordinates ──────────────────────────────
    double? distanceKm;
    if (coords.length >= 2) {
      double total = 0;
      for (int i = 1; i < coords.length; i++) {
        total += _haversineKm(
          coords[i - 1].lat, coords[i - 1].lon,
          coords[i].lat,     coords[i].lon,
        );
      }
      distanceKm = total;
    }

    return GpxActivity(
      date: date,
      distanceKm: distanceKm != null
          ? double.parse(distanceKm.toStringAsFixed(2))
          : null,
      durationMinutes: durationMinutes,
      trackName: trackName,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static DateTime? _parseIso(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  /// Haversine formula, returns distance in kilometres.
  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius km
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
}
