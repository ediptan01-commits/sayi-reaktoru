
import 'package:flutter/material.dart';
import 'engine.dart';

void main() {
  runApp(const ReactorApp());
}

class ReactorApp extends StatelessWidget {
  const ReactorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayı Reaktörü',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1121),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF52D7FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const ReactorPage(),
    );
  }
}

class ReactorPage extends StatefulWidget {
  const ReactorPage({super.key});

  @override
  State<ReactorPage> createState() => _ReactorPageState();
}

class _ReactorPageState extends State<ReactorPage> {
  int levelIndex = 0;
  late ReactorGame game;
  (int, int)? selected;
  String status = 'Bir kareye, ardından komşusuna dokun.';
  final completed = <int>{};

  @override
  void initState() {
    super.initState();
    game = ReactorGame(levels[levelIndex]);
  }

  void openLevel(int index) {
    setState(() {
      levelIndex = index;
      game = ReactorGame(levels[index]);
      selected = null;
      status = 'Komşu sayıları birleştir; 8 ve üzeri patlar!';
    });
  }

  void tap(int r, int c) {
    if (game.won || game.lost || game.board[r][c] == 0) {
      return;
    }

    if (selected == null) {
      setState(() {
        selected = (r, c);
      });
      return;
    }

    final (sr, sc) = selected!;

    setState(() {
      selected = null;

      if (sr == r && sc == c) {
        return;
      }

      final result = game.merge(sr, sc, r, c);
      status = result.message;

      if (game.won) {
        completed.add(levelIndex);
        status = 'REAKTÖR TAMAMLANDI! +${game.score} puan';
      } else if (game.lost) {
        status = 'Enerji tükendi! Yeniden dene.';
      }
    });
  }

  Color tileColor(int value) {
    if (value >= 6) {
      return const Color(0xFFB45309);
    }
    if (value >= 4) {
      return const Color(0xFF155E75);
    }
    if (value >= 2) {
      return const Color(0xFF1D4ED8);
    }
    return const Color(0xFF334155);
  }

  Widget stat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF17243B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTile(int r, int c) {
    final value = game.board[r][c];
    final isSelected = selected == (r, c);

    return Semantics(
      label: 'Satır ${r + 1}, sütun ${c + 1}, sayı $value',
      button: value > 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: value == 0
              ? const Color(0xFF111C30)
              : tileColor(value),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFE082)
                : const Color(0xFF334155),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: value >= 6
              ? [
                  const BoxShadow(
                    color: Color(0x66F59E0B),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: value > 0 ? () => tap(r, c) : null,
            child: Center(
              child: Text(
                value == 0 ? '' : '$value',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: value >= 6
                      ? const Color(0xFFFFEDD5)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showRules() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Nasıl oynanır?'),
          content: const Text(
            'Önce bir sayıya, ardından yanındaki dolu kareye dokun. '
            'İlk sayı ikincisine eklenir. '
            '8 veya üstüne ulaşan kare patlar. '
            'Patlama yanındaki dolu karelere +2 enerji verir. '
            'Bu kareler de kritik seviyeye ulaşırsa '
            'zincirleme reaksiyon başlar. '
            'Hamle hakkın bitmeden hedef kadar patlama oluştur!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Oynayalım'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = levels[levelIndex];
    final rows = game.board.length;
    final cols = game.board.first.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          '⚡ SAYI REAKTÖRÜ',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Kurallar',
            icon: const Icon(Icons.help_outline),
            onPressed: showRules,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BÖLÜM ${levelIndex + 1} / ${levels.length}',
                              style: const TextStyle(
                                color: Color(0xFF67E8F9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              level.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Yeniden başlat',
                        icon: const Icon(Icons.refresh),
                        onPressed: () => openLevel(levelIndex),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      stat(
                        'PATLAMA',
                        '${game.explosions}/${level.target}',
                      ),
                      const SizedBox(width: 8),
                      stat('HAMLE', '${game.movesLeft}'),
                      const SizedBox(width: 8),
                      stat('PUAN', '${game.score}'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: GridView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: 9,
                            mainAxisSpacing: 9,
                          ),
                          itemCount: rows * cols,
                          itemBuilder: (context, i) {
                            final r = i ~/ cols;
                            final c = i % cols;

                            return buildTile(r, c);
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: game.won
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (game.won)
                    FilledButton.icon(
                      onPressed: () {
                        openLevel(
                          (levelIndex + 1) % levels.length,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        levelIndex == levels.length - 1
                            ? 'Başa dön'
                            : 'Sonraki bölüm',
                      ),
                    )
                  else if (game.lost)
                    FilledButton.icon(
                      onPressed: () => openLevel(levelIndex),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar dene'),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 54,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: levels.length,
                      separatorBuilder: (_, __) {
                        return const SizedBox(width: 8);
                      },
                      itemBuilder: (context, i) {
                        return ActionChip(
                          label: Text(
                            completed.contains(i)
                                ? '✓ ${i + 1}'
                                : '${i + 1}',
                          ),
                          backgroundColor: i == levelIndex
                              ? const Color(0xFF155E75)
                              : const Color(0xFF1E293B),
                          onPressed: () => openLevel(i),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
