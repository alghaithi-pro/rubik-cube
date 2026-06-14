import 'dart:math';

// Face indices: U=0 D=1 F=2 B=3 L=4 R=5
// Sticker layout per face:
//  0 1 2
//  3 4 5
//  6 7 8

class CubeState {
  late List<List<int>> f; // f[face][sticker]

  CubeState() {
    f = List.generate(6, (i) => List.filled(9, i));
  }

  CubeState.from(CubeState other) {
    f = List.generate(6, (i) => List.from(other.f[i]));
  }

  // Rotate a face's 9 stickers clockwise
  void _rotateFaceCW(int face) {
    final t = List.from(f[face]);
    f[face][0] = t[6]; f[face][1] = t[3]; f[face][2] = t[0];
    f[face][3] = t[7]; f[face][4] = t[4]; f[face][5] = t[1];
    f[face][6] = t[8]; f[face][7] = t[5]; f[face][8] = t[2];
  }

  void _rotateFaceCCW(int face) {
    _rotateFaceCW(face); _rotateFaceCW(face); _rotateFaceCW(face);
  }

  // Cycle 4 sets of 3 stickers: a→b→c→d→a
  void _cycle(
    int f0, List<int> s0,
    int f1, List<int> s1,
    int f2, List<int> s2,
    int f3, List<int> s3,
  ) {
    final tmp = [f[f3][s3[0]], f[f3][s3[1]], f[f3][s3[2]]];
    f[f3][s3[0]] = f[f2][s2[0]]; f[f3][s3[1]] = f[f2][s2[1]]; f[f3][s3[2]] = f[f2][s2[2]];
    f[f2][s2[0]] = f[f1][s1[0]]; f[f2][s2[1]] = f[f1][s1[1]]; f[f2][s2[2]] = f[f1][s1[2]];
    f[f1][s1[0]] = f[f0][s0[0]]; f[f1][s1[1]] = f[f0][s0[1]]; f[f1][s1[2]] = f[f0][s0[2]];
    f[f0][s0[0]] = tmp[0]; f[f0][s0[1]] = tmp[1]; f[f0][s0[2]] = tmp[2];
  }

  // U move (top face CW)
  void moveU() {
    _rotateFaceCW(0);
    _cycle(2,[0,1,2], 5,[0,1,2], 3,[0,1,2], 4,[0,1,2]);
  }
  void moveUi() { moveU(); moveU(); moveU(); }

  // D move (bottom face CW when viewed from below)
  void moveD() {
    _rotateFaceCW(1);
    _cycle(4,[6,7,8], 3,[6,7,8], 5,[6,7,8], 2,[6,7,8]);
  }
  void moveDi() { moveD(); moveD(); moveD(); }

  // F move (front face CW)
  void moveF() {
    _rotateFaceCW(2);
    _cycle(
      0, [6,7,8],
      5, [0,3,6],
      1, [2,1,0],
      4, [8,5,2],
    );
  }
  void moveFi() { moveF(); moveF(); moveF(); }

  // B move (back face CW)
  void moveB() {
    _rotateFaceCW(3);
    _cycle(
      4, [0,3,6],
      0, [2,1,0],
      5, [8,5,2],
      1, [6,7,8],
    );
  }
  void moveBi() { moveB(); moveB(); moveB(); }

  // L move (left face CW)
  void moveL() {
    _rotateFaceCW(4);
    _cycle(
      0, [0,3,6],
      2, [0,3,6],
      1, [0,3,6],
      3, [8,5,2],
    );
  }
  void moveLi() { moveL(); moveL(); moveL(); }

  // R move (right face CW)
  void moveR() {
    _rotateFaceCW(5);
    _cycle(
      3, [0,3,6],
      0, [2,5,8],
      2, [2,5,8],
      1, [2,5,8],
    );
  }
  void moveRi() { moveR(); moveR(); moveR(); }

  void shuffle(int moves) {
    final rng = Random();
    final allMoves = [
      moveU, moveUi, moveD, moveDi,
      moveF, moveFi, moveB, moveBi,
      moveL, moveLi, moveR, moveRi,
    ];
    for (int i = 0; i < moves; i++) {
      allMoves[rng.nextInt(allMoves.length)]();
    }
  }

  bool get isSolved {
    for (final face in f) {
      if (face.any((s) => s != face[0])) return false;
    }
    return true;
  }
}
