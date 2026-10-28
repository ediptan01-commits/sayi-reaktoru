import 'dart:math' as math;

/// Pure game engine. Empty cells are 0; only orthogonally adjacent numbers merge.
/// A cell reaching threshold explodes, becomes empty, and adds 2 energy to
/// each occupied orthogonal neighbour. Secondary explosions form a chain.
class Level {
  const Level(this.title, this.grid, this.target, this.moves, {this.threshold = 8});
  final String title;
  final List<List<int>> grid;
  final int target;
  final int moves;
  final int threshold;
}

const levels = <Level>[
  Level('İlk Kıvılcım', [[2, 2, 1, 1], [1, 4, 2, 1], [2, 1, 2, 2], [1, 1, 2, 1]], 2, 8),
  Level('Çifte Etki', [[2, 4, 2, 1], [1, 2, 4, 2], [2, 1, 2, 2], [1, 2, 1, 1]], 3, 9),
  Level('Dar Koridor', [[1, 2, 1, 2], [2, 4, 4, 2], [1, 2, 2, 1], [2, 1, 2, 1]], 3, 9),
  Level('Sıcak Bölge', [[2, 4, 2, 2], [4, 2, 4, 1], [2, 4, 2, 2], [1, 2, 1, 2]], 4, 10),
  Level('Dört Yön', [[2, 2, 4, 2], [2, 4, 2, 4], [4, 2, 4, 2], [2, 4, 2, 2]], 5, 11),
  Level('Reaktör Odası', [[4, 2, 4, 2], [2, 4, 4, 2], [4, 2, 2, 4], [2, 4, 2, 2]], 5, 11),
  Level('Zincir Yolu', [[4, 4, 2, 2], [2, 4, 4, 2], [4, 2, 4, 4], [2, 4, 2, 2]], 6, 12),
  Level('Kritik Eşik', [[2, 4, 4, 2], [4, 4, 4, 2], [2, 4, 4, 4], [4, 2, 2, 4]], 6, 12),
  Level('Büyük Patlama', [[4, 4, 4, 2], [4, 4, 4, 4], [2, 4, 4, 4], [4, 4, 2, 4]], 7, 13),
  Level('Usta Reaktör', [[4, 4, 4, 4], [4, 4, 4, 4], [4, 4, 4, 4], [4, 4, 4, 4]], 8, 14),
];

class MoveResult {
  const MoveResult({required this.valid, this.explosions = 0, this.chain = 0, this.message = ''});
  final bool valid;
  final int explosions;
  final int chain;
  final String message;
}

class ReactorGame {
  ReactorGame(this.level) : board = level.grid.map((r) => List<int>.from(r)).toList();
  final Level level;
  final List<List<int>> board;
  int movesUsed = 0;
  int explosions = 0;
  int longestChain = 0;
  int score = 0;

  bool get won => explosions >= level.target;
  bool get lost => !won && (movesUsed >= level.moves || !hasMoves);
  int get movesLeft => math.max(0, level.moves - movesUsed);
  bool get hasMoves {
    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        if (board[r][c] == 0) continue;
        if (r + 1 < board.length && board[r + 1][c] > 0) return true;
        if (c + 1 < board[r].length && board[r][c + 1] > 0) return true;
      }
    }
    return false;
  }

  MoveResult merge(int fromRow, int fromCol, int toRow, int toCol) {
    final rows = board.length;
    final cols = board.first.length;
    if (won || lost || fromRow < 0 || toRow < 0 || fromCol < 0 || toCol < 0 ||
        fromRow >= rows || toRow >= rows || fromCol >= cols || toCol >= cols ||
        (fromRow - toRow).abs() + (fromCol - toCol).abs() != 1 ||
        board[fromRow][fromCol] == 0 || board[toRow][toCol] == 0) {
      return const MoveResult(valid: false, message: 'Yan yana iki dolu kare seç.');
    }
    board[toRow][toCol] += board[fromRow][fromCol];
    board[fromRow][fromCol] = 0;
    movesUsed++;

    // Process all critical cells wave by wave. Each wave is one chain level.
    var chain = 0;
    var burstCount = 0;
    while (true) {
      final critical = <(int, int)>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (board[r][c] >= level.threshold) critical.add((r, c));
        }
      }
      if (critical.isEmpty) break;
      chain++;
      // Simultaneous wave: explosions propagate after all critical cells clear.
      final additions = List.generate(rows, (_) => List.filled(cols, 0));
      for (final (r, c) in critical) {
        board[r][c] = 0;
        burstCount++;
        for (final (dr, dc) in const [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
          final nr = r + dr, nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols &&
              board[nr][nc] > 0) additions[nr][nc] += 2;
        }
      }
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          board[r][c] += additions[r][c];
        }
      }
    }
    explosions += burstCount;
    longestChain = math.max(longestChain, chain);
    score += burstCount * 100 + math.max(0, chain - 1) * 75;
    return MoveResult(valid: true, explosions: burstCount, chain: chain,
        message: burstCount == 0 ? 'Enerji birikti. Eşik: ${level.threshold}' :
            chain > 1 ? 'ZİNCİR x$chain! $burstCount patlama!' : '$burstCount patlama!');
  }
}
