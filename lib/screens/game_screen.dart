import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cube_state.dart';
import '../painters/cube_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  CubeState cube = CubeState();
  double rotX = -0.5;
  double rotY = 0.6;
  double _startX = 0, _startY = 0, _prevRotX = 0, _prevRotY = 0;

  int moves = 0;
  int seconds = 0;
  Timer? _timer;
  bool _started = false;
  bool _solved = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_started) return;
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() { seconds = 0; moves = 0; _started = false; _solved = false; });
  }

  String get _timeStr {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  void _applyMove(void Function() move) {
    _startTimer();
    setState(() {
      move();
      moves++;
      if (cube.isSolved) {
        _solved = true;
        _timer?.cancel();
      }
    });
  }

  void _shuffle() {
    _resetTimer();
    setState(() {
      cube = CubeState();
      cube.shuffle(25);
    });
  }

  void _reset() {
    _resetTimer();
    setState(() { cube = CubeState(); });
  }

  Widget _moveBtn(String label, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 42,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: (color ?? const Color(0xFF2D2D5E)).withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 4)],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timer
                  _statChip(Icons.timer_outlined, _timeStr),
                  // Title
                  Text('مكعب روبيك',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                  // Moves
                  _statChip(Icons.touch_app_outlined, '$moves'),
                ],
              ),
            ),

            // Solved banner
            if (_solved)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.green.withOpacity(0.25),
                child: Text(
                  '🎉 تم الحل! في $_timeStr و$moves حركة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

            // 3D Cube
            Expanded(
              child: GestureDetector(
                onPanStart: (d) {
                  _startX = d.localPosition.dx;
                  _startY = d.localPosition.dy;
                  _prevRotX = rotX;
                  _prevRotY = rotY;
                },
                onPanUpdate: (d) {
                  setState(() {
                    rotY = _prevRotY + (d.localPosition.dx - _startX) * 0.01;
                    rotX = (_prevRotX - (d.localPosition.dy - _startY) * 0.01)
                        .clamp(-1.2, 1.2);
                  });
                },
                child: CustomPaint(
                  painter: CubePainter(cube: cube, rotX: rotX, rotY: rotY),
                  child: SizedBox(width: size.width, height: double.infinity),
                ),
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF12122A),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                children: [
                  // Face move buttons row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _moveBtn('U', () => _applyMove(cube.moveU), color: const Color(0xFF3A3A7A)),
                      _moveBtn("U'", () => _applyMove(cube.moveUi), color: const Color(0xFF3A3A7A)),
                      _moveBtn('D', () => _applyMove(cube.moveD), color: const Color(0xFF3A3A7A)),
                      _moveBtn("D'", () => _applyMove(cube.moveDi), color: const Color(0xFF3A3A7A)),
                      _moveBtn('F', () => _applyMove(cube.moveF), color: const Color(0xFF2A5A2A)),
                      _moveBtn("F'", () => _applyMove(cube.moveFi), color: const Color(0xFF2A5A2A)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Face move buttons row 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _moveBtn('B', () => _applyMove(cube.moveB), color: const Color(0xFF1A3A6A)),
                      _moveBtn("B'", () => _applyMove(cube.moveBi), color: const Color(0xFF1A3A6A)),
                      _moveBtn('L', () => _applyMove(cube.moveL), color: const Color(0xFF6A3A1A)),
                      _moveBtn("L'", () => _applyMove(cube.moveLi), color: const Color(0xFF6A3A1A)),
                      _moveBtn('R', () => _applyMove(cube.moveR), color: const Color(0xFF6A1A1A)),
                      _moveBtn("R'", () => _applyMove(cube.moveRi), color: const Color(0xFF6A1A1A)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Shuffle & Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionBtn('خلط', Icons.shuffle, const Color(0xFFFFD700), Colors.black, _shuffle),
                      const SizedBox(width: 16),
                      _actionBtn('إعادة', Icons.refresh, const Color(0xFF3D3D8A), Colors.white, _reset),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 5),
        Text(value, style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 14)),
      ]),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: bg.withOpacity(0.4), blurRadius: 10)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo(color: fg, fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
