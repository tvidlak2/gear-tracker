/// Generates assets/icon/app_icon.png  – a 1024×1024 PNG with:
///   • Rounded-rect green background  (#1D9E75)
///   • White backpack silhouette (handle, straps, lid, body, front pocket)
///   • Clock badge bottom-right (#0F6E56 ring + white face + green hands at ~10:10)
///
/// Run with:  dart run tool/gen_icon.dart
///
/// Uses only dart:io, dart:typed_data, dart:math, dart:convert  (no pub packages).
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

// ── Tiny PNG encoder (no dependencies) ───────────────────────────────────────

Uint8List encodePng(int w, int h, Uint8List pixels) {
  final rawRgb = BytesBuilder();
  for (int y = 0; y < h; y++) {
    rawRgb.addByte(0);
    for (int x = 0; x < w; x++) {
      final base = (y * w + x) * 4;
      rawRgb.addByte(pixels[base]);
      rawRgb.addByte(pixels[base + 1]);
      rawRgb.addByte(pixels[base + 2]);
    }
  }
  final compressedRgb = _deflate(rawRgb.toBytes());

  Uint8List chunk(String type, Uint8List data) {
    final len = data.length;
    final buf = ByteData(12 + len);
    buf.setUint32(0, len);
    final ascii = type.codeUnits;
    buf.setUint8(4, ascii[0]);
    buf.setUint8(5, ascii[1]);
    buf.setUint8(6, ascii[2]);
    buf.setUint8(7, ascii[3]);
    for (int i = 0; i < len; i++) buf.setUint8(8 + i, data[i]);
    final crcBuf = Uint8List(4 + len);
    crcBuf.setRange(0, 4, ascii);
    crcBuf.setRange(4, 4 + len, data);
    buf.setUint32(8 + len, _crc32(crcBuf));
    return buf.buffer.asUint8List();
  }

  final ihdrData = ByteData(13)
    ..setUint32(0, w)
    ..setUint32(4, h)
    ..setUint8(8, 8)
    ..setUint8(9, 2)
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);

  final out = BytesBuilder();
  out.add([137, 80, 78, 71, 13, 10, 26, 10]);
  out.add(chunk('IHDR', ihdrData.buffer.asUint8List()));
  out.add(chunk('IDAT', compressedRgb));
  out.add(chunk('IEND', Uint8List(0)));
  return out.toBytes();
}

Uint8List _deflate(Uint8List data) => Uint8List.fromList(zlib.encode(data));

int _crc32(Uint8List data) {
  const poly = 0xEDB88320;
  int crc = 0xFFFFFFFF;
  for (final b in data) {
    crc ^= b;
    for (int i = 0; i < 8; i++) {
      if (crc & 1 != 0) {
        crc = (crc >>> 1) ^ poly;
      } else {
        crc >>>= 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}

// ── Pixel canvas ─────────────────────────────────────────────────────────────

class Canvas {
  final int w, h;
  final Uint8List pixels;

  Canvas(this.w, this.h) : pixels = Uint8List(w * h * 4);

  void setPixel(int x, int y, int r, int g, int b, [int a = 255]) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    final i = (y * w + x) * 4;
    pixels[i] = r;
    pixels[i + 1] = g;
    pixels[i + 2] = b;
    pixels[i + 3] = a;
  }

  void fill(int r, int g, int b, [int a = 255]) {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) setPixel(x, y, r, g, b, a);
    }
  }

  void fillCircle(double cx, double cy, double radius, int r, int g, int b,
      [int a = 255]) {
    final x0 = (cx - radius - 1).floor().clamp(0, w - 1);
    final x1 = (cx + radius + 1).ceil().clamp(0, w - 1);
    final y0 = (cy - radius - 1).floor().clamp(0, h - 1);
    final y1 = (cy + radius + 1).ceil().clamp(0, h - 1);
    for (int py = y0; py <= y1; py++) {
      for (int px = x0; px <= x1; px++) {
        final dx = px - cx, dy = py - cy;
        final dist = sqrt(dx * dx + dy * dy);
        if (dist <= radius - 0.5) {
          setPixel(px, py, r, g, b, a);
        } else if (dist < radius + 0.5) {
          final alpha = ((radius + 0.5 - dist) * a).round().clamp(0, 255);
          _blend(px, py, r, g, b, alpha);
        }
      }
    }
  }

  void fillRect(int x0, int y0, int x1, int y1, int r, int g, int b,
      [int a = 255]) {
    for (int y = y0; y <= y1; y++) {
      for (int x = x0; x <= x1; x++) setPixel(x, y, r, g, b, a);
    }
  }

  void fillRoundedRect(int x0, int y0, int x1, int y1, double radius, int r,
      int g, int b, [int a = 255]) {
    fillRect(x0 + radius.round(), y0, x1 - radius.round(), y1, r, g, b, a);
    fillRect(x0, y0 + radius.round(), x1, y1 - radius.round(), r, g, b, a);
    fillCircle(x0 + radius, y0 + radius, radius, r, g, b, a);
    fillCircle(x1 - radius, y0 + radius, radius, r, g, b, a);
    fillCircle(x0 + radius, y1 - radius, radius, r, g, b, a);
    fillCircle(x1 - radius, y1 - radius, radius, r, g, b, a);
  }

  void fillPolygon(List<(double, double)> pts, int r, int g, int b,
      [int a = 255]) {
    if (pts.length < 3) return;
    final minY = pts.map((p) => p.$2).reduce(min).floor().clamp(0, h - 1);
    final maxY = pts.map((p) => p.$2).reduce(max).ceil().clamp(0, h - 1);
    for (int py = minY; py <= maxY; py++) {
      final intersections = <double>[];
      for (int i = 0; i < pts.length; i++) {
        final (ax, ay) = pts[i];
        final (bx, by) = pts[(i + 1) % pts.length];
        if ((ay <= py && by > py) || (by <= py && ay > py)) {
          intersections.add(ax + (py - ay) / (by - ay) * (bx - ax));
        }
      }
      intersections.sort();
      for (int k = 0; k + 1 < intersections.length; k += 2) {
        final fx = intersections[k].round().clamp(0, w - 1);
        final tx = intersections[k + 1].round().clamp(0, w - 1);
        for (int px = fx; px <= tx; px++) setPixel(px, py, r, g, b, a);
      }
    }
  }

  void _blend(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || x >= w || y < 0 || y >= h || a == 0) return;
    final i = (y * w + x) * 4;
    final sa = a / 255.0;
    final da = pixels[i + 3] / 255.0;
    final oa = sa + da * (1 - sa);
    if (oa < 0.001) return;
    pixels[i] = ((r * sa + pixels[i] * da * (1 - sa)) / oa).round();
    pixels[i + 1] = ((g * sa + pixels[i + 1] * da * (1 - sa)) / oa).round();
    pixels[i + 2] = ((b * sa + pixels[i + 2] * da * (1 - sa)) / oa).round();
    pixels[i + 3] = (oa * 255).round();
  }
}

// ── Clock hand helper ─────────────────────────────────────────────────────────

void _drawHand(Canvas c, double cx, double cy, double angle, double length,
    double halfW, int r, int g, int b) {
  final perp = angle + pi / 2;
  final dx = cos(angle) * length;
  final dy = sin(angle) * length;
  final px = cos(perp) * halfW;
  final py = sin(perp) * halfW;
  c.fillPolygon([
    (cx + px, cy + py),
    (cx - px, cy - py),
    (cx - px + dx, cy - py + dy),
    (cx + px + dx, cy + py + dy),
  ], r, g, b);
}

// ── Draw the GearTracker icon ─────────────────────────────────────────────────

void drawIcon(Canvas c) {
  final s = c.w.toDouble();

  // Color palette
  const bgR = 0x1D, bgG = 0x9E, bgB = 0x75; // #1D9E75 primary green
  const wr = 255, wg = 255, wb = 255;        // white
  const dkR = 0x0F, dkG = 0x6E, dkB = 0x56; // #0F6E56 dark green

  // ── Background ────────────────────────────────────────────────────────────
  c.fill(bgR, bgG, bgB);
  c.fillRoundedRect(0, 0, c.w - 1, c.h - 1, s * 0.22, bgR, bgG, bgB);

  // Helper to convert fractional coords → int pixel
  int px(double f) => (f * s).round();

  // ── Backpack ──────────────────────────────────────────────────────────────

  // Handle loop (top centre)
  // Outer rounded rect
  c.fillRoundedRect(px(0.420), px(0.130), px(0.580), px(0.230),
      s * 0.040, wr, wg, wb);
  // Cut-out (inner green hole to form the loop)
  c.fillRoundedRect(px(0.448), px(0.152), px(0.552), px(0.210),
      s * 0.028, bgR, bgG, bgB);

  // Left shoulder strap
  c.fillRoundedRect(px(0.305), px(0.200), px(0.390), px(0.400),
      s * 0.028, wr, wg, wb);
  // Right shoulder strap
  c.fillRoundedRect(px(0.610), px(0.200), px(0.695), px(0.400),
      s * 0.028, wr, wg, wb);

  // Top lid / flap (wider than body, connects to straps)
  c.fillRoundedRect(px(0.268), px(0.305), px(0.732), px(0.430),
      s * 0.045, wr, wg, wb);

  // Main body
  c.fillRoundedRect(px(0.268), px(0.375), px(0.732), px(0.850),
      s * 0.055, wr, wg, wb);

  // Dividing line between lid and body (subtle green stripe)
  c.fillRect(px(0.268), px(0.416), px(0.732), px(0.428),
      bgR, bgG, bgB);

  // Front pocket — positioned left-of-centre to leave room for clock badge
  // Pocket border (green)
  c.fillRoundedRect(px(0.300), px(0.565), px(0.570), px(0.820),
      s * 0.032, bgR, bgG, bgB);
  // Pocket fill (white)
  c.fillRoundedRect(px(0.315), px(0.580), px(0.555), px(0.805),
      s * 0.026, wr, wg, wb);

  // ── Clock badge ───────────────────────────────────────────────────────────
  // Positioned at lower-right area of the main body
  final clkCx = s * 0.655;
  final clkCy = s * 0.710;
  final clkOuter = s * 0.148; // dark green ring radius
  final clkFace = clkOuter * 0.78; // white face radius

  // Dark green outer ring
  c.fillCircle(clkCx, clkCy, clkOuter, dkR, dkG, dkB);
  // White clock face
  c.fillCircle(clkCx, clkCy, clkFace, wr, wg, wb);

  // Hour markers: 4 dots at 12 / 3 / 6 / 9
  final dotRadius = clkFace * 0.092;
  final dotDist = clkFace * 0.730;
  c.fillCircle(clkCx, clkCy - dotDist, dotRadius, bgR, bgG, bgB);
  c.fillCircle(clkCx + dotDist, clkCy, dotRadius, bgR, bgG, bgB);
  c.fillCircle(clkCx, clkCy + dotDist, dotRadius, bgR, bgG, bgB);
  c.fillCircle(clkCx - dotDist, clkCy, dotRadius, bgR, bgG, bgB);

  // Hands showing ~10:10
  //   Hour  at 10:10 → 10×30 + 10×0.5 = 305° CW from 12
  //   Minute at :10  → 10×6           = 60°  CW from 12
  // angle = –π/2 + degrees × π/180  (0° = up, CW positive)
  final hourAngle = -pi / 2 + 305.0 * pi / 180.0;
  final minAngle = -pi / 2 + 60.0 * pi / 180.0;

  _drawHand(c, clkCx, clkCy, hourAngle,
      clkFace * 0.50, clkFace * 0.072, bgR, bgG, bgB);
  _drawHand(c, clkCx, clkCy, minAngle,
      clkFace * 0.70, clkFace * 0.052, bgR, bgG, bgB);

  // Centre pivot dot
  c.fillCircle(clkCx, clkCy, clkFace * 0.095, bgR, bgG, bgB);
}

// ── Entry point ───────────────────────────────────────────────────────────────

void main() {
  const size = 1024;
  const outPath = 'assets/icon/app_icon.png';

  final canvas = Canvas(size, size);
  drawIcon(canvas);
  final png = encodePng(size, size, canvas.pixels);
  File(outPath).writeAsBytesSync(png);
  print('Written $outPath  (${png.length} bytes, ${size}x${size} px)');
}
