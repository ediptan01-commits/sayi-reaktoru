import 'package:flutter_test/flutter_test.dart';
import 'package:sayi_reaktoru/engine.dart';

void main() {
  test('Only orthogonal occupied cells can merge', () {
    final g = ReactorGame(const Level('test', [[2, 2], [0, 4]], 1, 3));
    expect(g.merge(0, 0, 1, 1).valid, false);
    expect(g.merge(0, 0, 1, 0).valid, false);
    expect(g.movesUsed, 0);
    expect(g.merge(0, 0, 0, 1).valid, true);
    expect(g.board[0][1], 4);
    expect(g.movesUsed, 1);
  });

  test('Explosion clears critical tile and energizes occupied neighbors', () {
    final g = ReactorGame(const Level('test', [[4, 4, 2], [2, 2, 0]], 1, 3));
    final result = g.merge(0, 0, 0, 1);
    expect(result.explosions, 1);
    expect(g.board[0][1], 0);
    expect(g.board[0][2], 4);
    expect(g.board[1][1], 4);
    expect(g.won, true);
  });

  test('Secondary explosion gives chain length two', () {
    final g = ReactorGame(const Level('test', [[4, 4, 6], [1, 1, 1]], 2, 2));
    final result = g.merge(0, 0, 0, 1);
    expect(result.explosions, 2);
    expect(result.chain, 2);
    expect(g.won, true);
  });
}
