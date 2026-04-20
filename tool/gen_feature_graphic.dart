/// Generates docs/feature_graphic.png – 1024×500 Google Play feature graphic.
///
/// Design:
///   • Green #1D9E75 background with subtle dark-green accent panel on right
///   • Left side: "GearTracker" large white bold text + tagline
///   • Right side: large backpack + clock badge illustration
///   • Corner decorative circles for depth
///
/// Run with:  dart run tool/gen_feature_graphic.dart
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

// ── Tiny PNG encoder ─────────────────────────────────────────────────────────

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
      crc = (crc & 1 != 0) ? (crc >>> 1) ^ poly : crc >>> 1;
    }
  }
  return crc ^ 0xFFFFFFFF;
}

// ── Canvas ────────────────────────────────────────────────────────────────────

class Canvas {
  final int w, h;
  final Uint8List pixels;
  Canvas(this.w, this.h) : pixels = Uint8List(w * h * 4);

  void setPixel(int x, int y, int r, int g, int b, [int a = 255]) {
    if (x < 0 || x >= w || y < 0 || y >= h) return;
    final i = (y * w + x) * 4;
    pixels[i] = r; pixels[i+1] = g; pixels[i+2] = b; pixels[i+3] = a;
  }

  void fill(int r, int g, int b) {
    for (int y = 0; y < h; y++)
      for (int x = 0; x < w; x++) setPixel(x, y, r, g, b);
  }

  void _blend(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || x >= w || y < 0 || y >= h || a == 0) return;
    final i = (y * w + x) * 4;
    final sa = a / 255.0, da = pixels[i+3] / 255.0;
    final oa = sa + da * (1 - sa);
    if (oa < 0.001) return;
    pixels[i]   = ((r * sa + pixels[i]   * da * (1 - sa)) / oa).round();
    pixels[i+1] = ((g * sa + pixels[i+1] * da * (1 - sa)) / oa).round();
    pixels[i+2] = ((b * sa + pixels[i+2] * da * (1 - sa)) / oa).round();
    pixels[i+3] = (oa * 255).round();
  }

  void fillCircle(double cx, double cy, double radius, int r, int g, int b, [int a = 255]) {
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

  void fillRect(int x0, int y0, int x1, int y1, int r, int g, int b, [int a = 255]) {
    for (int y = y0; y <= y1; y++)
      for (int x = x0; x <= x1; x++) setPixel(x, y, r, g, b, a);
  }

  void fillRoundedRect(double x0, double y0, double x1, double y1,
      double radius, int r, int g, int b, [int a = 255]) {
    final ix0 = x0.round(), iy0 = y0.round();
    final ix1 = x1.round(), iy1 = y1.round();
    final ir = radius.round();
    fillRect(ix0 + ir, iy0, ix1 - ir, iy1, r, g, b, a);
    fillRect(ix0, iy0 + ir, ix1, iy1 - ir, r, g, b, a);
    fillCircle(x0 + radius, y0 + radius, radius, r, g, b, a);
    fillCircle(x1 - radius, y0 + radius, radius, r, g, b, a);
    fillCircle(x0 + radius, y1 - radius, radius, r, g, b, a);
    fillCircle(x1 - radius, y1 - radius, radius, r, g, b, a);
  }

  void fillPolygon(List<(double, double)> pts, int r, int g, int b, [int a = 255]) {
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
}

// ── Bitmap font (5×7 pixels per glyph) ───────────────────────────────────────

// Each glyph: 5 columns × 7 rows, packed as 5 ints (one per column, bits 0-6 = rows top-to-bottom)
const _fontData = <int, List<int>>{
  0x20: [0,0,0,0,0], // space
  0x21: [0,0,95,0,0], // !
  0x41: [124,18,17,18,124], // A
  0x42: [127,73,73,73,54],  // B
  0x43: [62,65,65,65,34],   // C
  0x44: [127,65,65,34,28],  // D
  0x45: [127,73,73,65,65],  // E
  0x46: [127,9,9,1,1],      // F
  0x47: [62,65,65,81,114],  // G
  0x48: [127,8,8,8,127],    // H
  0x49: [0,65,127,65,0],    // I
  0x4A: [32,64,65,63,1],    // J
  0x4B: [127,8,20,34,65],   // K
  0x4C: [127,64,64,64,64],  // L
  0x4D: [127,2,12,2,127],   // M
  0x4E: [127,4,8,16,127],   // N
  0x4F: [62,65,65,65,62],   // O
  0x50: [127,9,9,9,6],      // P
  0x51: [62,65,81,33,94],   // Q
  0x52: [127,9,25,41,70],   // R
  0x53: [38,73,73,73,50],   // S
  0x54: [1,1,127,1,1],      // T
  0x55: [63,64,64,64,63],   // U
  0x56: [31,32,64,32,31],   // V
  0x57: [63,64,56,64,63],   // W
  0x58: [99,20,8,20,99],    // X
  0x59: [3,4,120,4,3],      // Y
  0x5A: [97,81,73,69,67],   // Z
  0x61: [32,84,84,84,120],  // a
  0x62: [127,72,68,68,56],  // b
  0x63: [56,68,68,68,32],   // c
  0x64: [56,68,68,72,127],  // d
  0x65: [56,84,84,84,24],   // e
  0x66: [8,126,9,1,2],      // f
  0x67: [12,82,82,82,62],   // g
  0x68: [127,8,4,4,120],    // h
  0x69: [0,68,125,64,0],    // i
  0x6A: [32,64,68,61,0],    // j
  0x6B: [127,16,40,68,0],   // k
  0x6C: [0,65,127,64,0],    // l
  0x6D: [124,4,24,4,120],   // m
  0x6E: [124,8,4,4,120],    // n
  0x6F: [56,68,68,68,56],   // o
  0x70: [124,20,20,20,8],   // p
  0x71: [8,20,20,24,124],   // q
  0x72: [124,8,4,4,8],      // r
  0x73: [72,84,84,84,36],   // s
  0x74: [4,63,68,64,32],    // t
  0x75: [60,64,64,32,124],  // u
  0x76: [28,32,64,32,28],   // v
  0x77: [60,64,48,64,60],   // w
  0x78: [68,40,16,40,68],   // x
  0x79: [12,80,80,80,60],   // y
  0x7A: [68,100,84,76,68],  // z
};

/// Draw text at (x,y) with given pixel scale.
void drawText(Canvas c, String text, int x, int y, int scale,
    int r, int g, int b, [int a = 255]) {
  int cx = x;
  for (final ch in text.codeUnits) {
    final glyph = _fontData[ch] ?? _fontData[0x20]!;
    for (int col = 0; col < 5; col++) {
      final colBits = glyph[col];
      for (int row = 0; row < 7; row++) {
        if (colBits & (1 << row) != 0) {
          for (int sy = 0; sy < scale; sy++) {
            for (int sx = 0; sx < scale; sx++) {
              c._blend(cx + col * scale + sx, y + row * scale + sy, r, g, b, a);
            }
          }
        }
      }
    }
    cx += (5 + 1) * scale; // 5 columns + 1 gap
  }
}

int textWidth(String text, int scale) => text.length * 6 * scale;

// ── Clock hand ────────────────────────────────────────────────────────────────

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

// ── Backpack + clock illustration ────────────────────────────────────────────

/// Draw a backpack centered at (cx, cy) with given size s.
void drawBackpack(Canvas c, double cx, double cy, double s) {
  // Colors
  const wr = 255, wg = 255, wb = 255;
  const bgR = 0x1D, bgG = 0x9E, bgB = 0x75;
  const dkR = 0x0F, dkG = 0x6E, dkB = 0x56;

  double px(double f) => cx - s * 0.5 + f * s;
  double py(double f) => cy - s * 0.5 + f * s;

  // Handle loop
  c.fillRoundedRect(px(0.420), py(0.130), px(0.580), py(0.230),
      s * 0.040, wr, wg, wb);
  c.fillRoundedRect(px(0.448), py(0.152), px(0.552), py(0.210),
      s * 0.028, bgR, bgG, bgB);

  // Shoulder straps
  c.fillRoundedRect(px(0.305), py(0.200), px(0.390), py(0.400),
      s * 0.028, wr, wg, wb);
  c.fillRoundedRect(px(0.610), py(0.200), px(0.695), py(0.400),
      s * 0.028, wr, wg, wb);

  // Lid / flap
  c.fillRoundedRect(px(0.268), py(0.305), px(0.732), py(0.430),
      s * 0.045, wr, wg, wb);

  // Main body
  c.fillRoundedRect(px(0.268), py(0.375), px(0.732), py(0.850),
      s * 0.055, wr, wg, wb);

  // Lid-body divider stripe
  c.fillRect((px(0.268) + s * 0.055).round(), py(0.415).round(),
      (px(0.732) - s * 0.055).round(), py(0.440).round(),
      bgR, bgG, bgB);

  // Front pocket
  c.fillRoundedRect(px(0.310), py(0.560), px(0.640), py(0.820),
      s * 0.040, bgR, bgG, bgB);
  c.fillRoundedRect(px(0.325), py(0.572), px(0.628), py(0.810),
      s * 0.032, wr, wg, wb);

  // ── Clock badge ─────────────────────────────────────────────────────────────
  final clockCx = px(0.650);
  final clockCy = py(0.720);
  final clockR  = s * 0.155;

  // Dark green ring
  c.fillCircle(clockCx, clockCy, clockR, dkR, dkG, dkB);
  // White face
  c.fillCircle(clockCx, clockCy, clockR * 0.84, wr, wg, wb);

  // 4 dots at 12/3/6/9
  for (int i = 0; i < 4; i++) {
    final ang = i * pi / 2 - pi / 2;
    final dx = cos(ang) * clockR * 0.65;
    final dy = sin(ang) * clockR * 0.65;
    c.fillCircle(clockCx + dx, clockCy + dy, clockR * 0.07, dkR, dkG, dkB);
  }

  // Hour hand (~10 o'clock = -60° from 12 = 300°)
  final hourAngle  = 300.0 * pi / 180 - pi / 2;
  // Minute hand (~10 min past = 60° from 12)
  final minAngle   = 60.0  * pi / 180 - pi / 2;

  _drawHand(c, clockCx, clockCy, hourAngle, clockR * 0.50, clockR * 0.065,
      dkR, dkG, dkB);
  _drawHand(c, clockCx, clockCy, minAngle,  clockR * 0.65, clockR * 0.050,
      dkR, dkG, dkB);

  // Centre dot
  c.fillCircle(clockCx, clockCy, clockR * 0.08, dkR, dkG, dkB);
}

// ── Main ─────────────────────────────────────────────────────────────────────

void main() {
  const W = 1024, H = 500;
  final c = Canvas(W, H);

  // ── Background ──────────────────────────────────────────────────────────────
  const bgR = 0x1D, bgG = 0x9E, bgB = 0x75;   // #1D9E75
  const dkR = 0x17, dkG = 0x87, dkB = 0x62;   // slightly darker green panel
  const wr = 255, wg = 255, wb = 255;

  c.fill(bgR, bgG, bgB);

  // Decorative dark-green panel — right half diagonal
  // Draw as a large polygon: right side of canvas, cut diagonally
  c.fillPolygon([
    (W * 0.52, 0.0),
    (W * 1.0,  0.0),
    (W * 1.0,  H * 1.0),
    (W * 0.60, H * 1.0),
  ], dkR, dkG, dkB);

  // Decorative circles (subtle, semi-transparent darker green)
  c.fillCircle(-30, -30, 140, 0x15, 0x78, 0x58, 60);
  c.fillCircle(W + 20, H + 20, 160, 0x15, 0x78, 0x58, 60);
  c.fillCircle(W * 0.35, H * 1.15, 120, 0x15, 0x78, 0x58, 45);

  // ── Backpack illustration (right side) ──────────────────────────────────────
  drawBackpack(c, W * 0.78, H * 0.50, H * 0.82);

  // ── Text (left side) ────────────────────────────────────────────────────────
  // "GearTracker" — large, scale 8 (each pixel = 8×8)
  const title = 'GearTracker';
  const titleScale = 8;
  final titleW = textWidth(title, titleScale);
  final titleX = 72;
  final titleY = (H * 0.28).round();
  drawText(c, title, titleX, titleY, titleScale, wr, wg, wb);

  // Separator line under title
  c.fillRect(titleX, titleY + 7 * titleScale + 16,
      titleX + titleW, titleY + 7 * titleScale + 20, wr, wg, wb, 180);

  // Tagline line 1: "Never miss a"  scale 4
  const tag1 = 'Never miss a';
  const tag2 = 'maintenance deadline';
  const tagScale = 4;
  final tagY1 = titleY + 7 * titleScale + 36;
  final tagY2 = tagY1 + 7 * tagScale + 10;
  drawText(c, tag1, titleX, tagY1, tagScale, wr, wg, wb, 230);
  drawText(c, tag2, titleX, tagY2, tagScale, wr, wg, wb, 230);

  // ── Save ────────────────────────────────────────────────────────────────────
  final outPath = 'docs/feature_graphic.png';
  final png = encodePng(W, H, c.pixels);
  File(outPath).writeAsBytesSync(png);
  print('Written $outPath  (${png.length} bytes, ${W}x${H} px)');
}
