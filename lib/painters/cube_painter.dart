import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cube_state.dart';

// Sticker colors
const List<Color> stickerColors = [
  Color(0xFFFFFFFF), // U white
  Color(0xFFFFD700), // D yellow
  Color(0xFF009B48), // F green
  Color(0xFF0046AD), // B blue
  Color(0xFFFF5800), // L orange
  Color(0xFFB90000), // R red
];

class CubePainter extends CustomPainter {
  final CubeState cube;
  final double rotX;
  final double rotY;
  final int? animatingFace;
  final double animAngle;

  CubePainter({
    required this.cube,
    required this.rotX,
    required this.rotY,
    this.animatingFace,
    this.animAngle = 0,
  });

  // 3D point
  static List<double> _rotatePoint(List<double> p, double rx, double ry) {
    double x = p[0], y = p[1], z = p[2];
    // Rotate around Y
    double x2 = x * cos(ry) + z * sin(ry);
    double z2 = -x * sin(ry) + z * cos(ry);
    x = x2; z = z2;
    // Rotate around X
    double y2 = y * cos(rx) - z * sin(rx);
    double z3 = y * sin(rx) + z * cos(rx);
    return [x, y2, z3];
  }

  static Offset _project(List<double> p, Size size) {
    const fov = 6.0;
    final scale = size.width / fov;
    final cx = size.width / 2;
    final cy = size.height / 2;
    return Offset(cx + p[0] * scale, cy - p[1] * scale);
  }

  // Face normal vectors (unit)
  static const List<List<double>> faceNormals = [
    [0,  1,  0], // U
    [0, -1,  0], // D
    [0,  0,  1], // F
    [0,  0, -1], // B
    [-1, 0,  0], // L
    [1,  0,  0], // R
  ];

  // For each face, origin corner (top-left of sticker grid) and two direction vectors
  static const List<List<List<double>>> faceAxes = [
    // U: origin at (-1,1,-1), right=(2/3,0,0), down=(0,0,2/3)
    [[-1,1,-1], [1,0,0], [0,0,1]],
    // D: origin at (-1,-1,1), right=(2/3,0,0), down=(0,0,-2/3)
    [[-1,-1,1], [1,0,0], [0,0,-1]],
    // F: origin at (-1,1,1), right=(2/3,0,0), down=(0,-2/3,0)
    [[-1,1,1], [1,0,0], [0,-1,0]],
    // B: origin at (1,1,-1), right=(-2/3,0,0), down=(0,-2/3,0)
    [[1,1,-1], [-1,0,0], [0,-1,0]],
    // L: origin at (-1,1,-1), right=(0,0,2/3), down=(0,-2/3,0)
    [[-1,1,-1], [0,0,1], [0,-1,0]],
    // R: origin at (1,1,1), right=(0,0,-2/3), down=(0,-2/3,0)
    [[1,1,1], [0,0,-1], [0,-1,0]],
  ];

  List<double> _computeStickerCenter(int face, int row, int col) {
    final axes = faceAxes[face];
    final o = axes[0];
    final r = axes[1];
    final d = axes[2];
    final step = 2.0 / 3.0;
    final half = step / 2;
    return [
      o[0] + r[0] * (col * step + half) + d[0] * (row * step + half),
      o[1] + r[1] * (col * step + half) + d[1] * (row * step + half),
      o[2] + r[2] * (col * step + half) + d[2] * (row * step + half),
    ];
  }

  List<Offset> _stickerCorners(int face, int row, int col, double rx, double ry, Size size) {
    final axes = faceAxes[face];
    final o = axes[0];
    final r = axes[1];
    final d = axes[2];
    const step = 2.0 / 3.0;
    const gap = 0.04;
    final corners3D = [
      [o[0]+r[0]*(col*step+gap)+d[0]*(row*step+gap), o[1]+r[1]*(col*step+gap)+d[1]*(row*step+gap), o[2]+r[2]*(col*step+gap)+d[2]*(row*step+gap)],
      [o[0]+r[0]*((col+1)*step-gap)+d[0]*(row*step+gap), o[1]+r[1]*((col+1)*step-gap)+d[1]*(row*step+gap), o[2]+r[2]*((col+1)*step-gap)+d[2]*(row*step+gap)],
      [o[0]+r[0]*((col+1)*step-gap)+d[0]*((row+1)*step-gap), o[1]+r[1]*((col+1)*step-gap)+d[1]*((row+1)*step-gap), o[2]+r[2]*((col+1)*step-gap)+d[2]*((row+1)*step-gap)],
      [o[0]+r[0]*(col*step+gap)+d[0]*((row+1)*step-gap), o[1]+r[1]*(col*step+gap)+d[1]*((row+1)*step-gap), o[2]+r[2]*(col*step+gap)+d[2]*((row+1)*step-gap)],
    ];
    return corners3D.map((p) => _project(_rotatePoint(p, rx, ry), size)).toList();
  }

  double _faceDepth(int face, double rx, double ry) {
    final n = faceNormals[face];
    final rn = _rotatePoint(n, rx, ry);
    return rn[2];
  }

  bool _faceVisible(int face, double rx, double ry) {
    return _faceDepth(face, rx, ry) > 0.05;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Sort faces by depth (back to front)
    final faces = List.generate(6, (i) => i);
    faces.sort((a, b) => _faceDepth(a, rotX, rotY).compareTo(_faceDepth(b, rotX, rotY)));

    final bgPaint = Paint()..color = const Color(0xFF1A1A2E);

    for (final face in faces) {
      if (!_faceVisible(face, rotX, rotY)) continue;
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          final idx = row * 3 + col;
          final colorIdx = cube.f[face][idx];
          final corners = _stickerCorners(face, row, col, rotX, rotY, size);
          final path = Path()
            ..moveTo(corners[0].dx, corners[0].dy)
            ..lineTo(corners[1].dx, corners[1].dy)
            ..lineTo(corners[2].dx, corners[2].dy)
            ..lineTo(corners[3].dx, corners[3].dy)
            ..close();

          // Background slot
          canvas.drawPath(path, bgPaint);

          // Sticker color
          final paint = Paint()..color = stickerColors[colorIdx];
          canvas.drawPath(path, paint);

          // Subtle highlight
          canvas.drawPath(
            path,
            Paint()
              ..color = Colors.white.withOpacity(0.08)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CubePainter old) =>
      old.rotX != rotX || old.rotY != rotY || old.cube != cube || old.animAngle != animAngle;
}
