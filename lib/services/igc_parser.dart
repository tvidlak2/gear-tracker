/// IGC (International Gliding Commission) file parser.
///
/// Parses a single-flight IGC text file and extracts:
///   - Flight date (HFDTE record)
///   - Start/end time and duration from B records
///   - Maximum barometric altitude
///   - Start GPS coordinates
library;

class IgcFlight {
  final DateTime flightDate;
  final int      startHour;
  final int      startMinute;
  final int      endHour;
  final int      endMinute;
  final int      durationMinutes;
  final int      maxAltitudeM;    // barometric, metres
  final double   startLat;        // decimal degrees, N positive
  final double   startLon;        // decimal degrees, E positive

  const IgcFlight({
    required this.flightDate,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.durationMinutes,
    required this.maxAltitudeM,
    required this.startLat,
    required this.startLon,
  });
}

class IgcParser {
  /// Parse IGC file content and return flight data, or null if the file
  /// is not a valid IGC file.
  static IgcFlight? parse(String content) {
    DateTime? flightDate;
    _BRecord? firstB;
    _BRecord? lastB;
    int maxAlt = 0;

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (flightDate == null &&
          line.length >= 11 &&
          line.startsWith('HFDTE')) {
        flightDate = _parseDate(line);
        continue;
      }

      if (line.startsWith('B') && line.length >= 35) {
        final rec = _parseBRecord(line);
        if (rec != null) {
          firstB ??= rec;
          lastB = rec;
          if (rec.pressureAlt > maxAlt) maxAlt = rec.pressureAlt;
        }
      }
    }

    if (flightDate == null || firstB == null || lastB == null) return null;

    int durationSec = lastB.totalSeconds - firstB.totalSeconds;
    if (durationSec < 0) durationSec += 86400; // midnight crossing
    final durationMin = (durationSec / 60).round();

    return IgcFlight(
      flightDate: flightDate,
      startHour: firstB.hour,
      startMinute: firstB.minute,
      endHour: lastB.hour,
      endMinute: lastB.minute,
      durationMinutes: durationMin,
      maxAltitudeM: maxAlt,
      startLat: firstB.lat,
      startLon: firstB.lon,
    );
  }

  // ── HFDTE parsing ──────────────────────────────────────────────────────────

  static DateTime? _parseDate(String line) {
    // Supports: HFDTEDDMMYY  and  HFDTEDATE:DDMMYY,NN
    String raw;
    if (line.startsWith('HFDTEDATE:') && line.length >= 16) {
      raw = line.substring(10, 16); // DDMMYY after "HFDTEDATE:"
    } else if (line.length >= 11) {
      raw = line.substring(5, 11);  // DDMMYY after "HFDTE"
    } else {
      return null;
    }

    final dd = int.tryParse(raw.substring(0, 2));
    final mm = int.tryParse(raw.substring(2, 4));
    final yy = int.tryParse(raw.substring(4, 6));
    if (dd == null || mm == null || yy == null) return null;
    if (dd < 1 || dd > 31 || mm < 1 || mm > 12) return null;

    final year = yy < 80 ? 2000 + yy : 1900 + yy;
    return DateTime(year, mm, dd);
  }

  // ── B record parsing ───────────────────────────────────────────────────────
  //
  // Format (0-indexed, no spaces):
  //   0        : 'B'
  //   1- 6     : HHMMSS (UTC)
  //   7-14     : DDMMmmmN  (lat: 2 deg + 2 min + 3 dec-min + hemisphere)
  //  15-23     : DDDMMmmmE (lon: 3 deg + 2 min + 3 dec-min + hemisphere)
  //  24        : validity ('A' = 3D fix, 'V' = invalid)
  //  25-29     : pressure altitude, 5 digits, metres
  //  30-34     : GNSS altitude, 5 digits, metres

  static _BRecord? _parseBRecord(String line) {
    if (line.length < 35 || line[0] != 'B') return null;

    final hh = int.tryParse(line.substring(1, 3));
    final mm = int.tryParse(line.substring(3, 5));
    final ss = int.tryParse(line.substring(5, 7));
    if (hh == null || mm == null || ss == null) return null;

    // Pressure altitude
    final pressAlt = int.tryParse(line.substring(25, 30));
    if (pressAlt == null) return null;

    // Latitude: DDMMmmmN
    final latDeg = int.tryParse(line.substring(7, 9));
    final latMinInt = int.tryParse(line.substring(9, 11));
    final latMinDec = int.tryParse(line.substring(11, 14));
    final latHem = line[14];
    if (latDeg == null || latMinInt == null || latMinDec == null) return null;

    // Longitude: DDDMMmmmE/W
    final lonDeg = int.tryParse(line.substring(15, 18));
    final lonMinInt = int.tryParse(line.substring(18, 20));
    final lonMinDec = int.tryParse(line.substring(20, 23));
    final lonHem = line[23];
    if (lonDeg == null || lonMinInt == null || lonMinDec == null) return null;

    double lat = latDeg + (latMinInt + latMinDec / 1000.0) / 60.0;
    if (latHem == 'S') lat = -lat;

    double lon = lonDeg + (lonMinInt + lonMinDec / 1000.0) / 60.0;
    if (lonHem == 'W') lon = -lon;

    return _BRecord(
      hour: hh,
      minute: mm,
      second: ss,
      pressureAlt: pressAlt,
      lat: lat,
      lon: lon,
    );
  }
}

// ── Internal ──────────────────────────────────────────────────────────────────

class _BRecord {
  final int    hour;
  final int    minute;
  final int    second;
  final int    pressureAlt;
  final double lat;
  final double lon;

  const _BRecord({
    required this.hour,
    required this.minute,
    required this.second,
    required this.pressureAlt,
    required this.lat,
    required this.lon,
  });

  int get totalSeconds => hour * 3600 + minute * 60 + second;
}
