import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const SpaceExplorerMatch());
}

class SpaceExplorerMatch extends StatelessWidget {
  const SpaceExplorerMatch({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Space Explorer Match',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const SpaceGameScreen(),
    );
  }
}

class SpaceGameScreen extends StatefulWidget {
  const SpaceGameScreen({super.key});

  @override
  State<SpaceGameScreen> createState() =>
      _SpaceGameScreenState();
}

class _SpaceGameScreenState
    extends State<SpaceGameScreen> {

  final List<String> _spaceItems = [

    '🚀',
    '🪐',
    '🌍',
    '🌙',
    '☄️',
    '🛰️',
    '👨‍🚀',
    '⭐',
  ];

  late List<String> _cards;

  List<bool> _flipped = [];
  List<bool> _matched = [];

  int? _firstIndex;
  int? _secondIndex;

  bool _checking = false;

  int _moves = 0;
  int _matches = 0;

  int _seconds = 0;

  int _bestScore = 999;

  bool _gameStarted = false;

  Timer? _timer;

  @override
  void initState() {

    super.initState();

    _startGame();
  }

  void _startTimer() {

    if (_gameStarted) return;

    _gameStarted = true;

    _timer = Timer.periodic(

      const Duration(seconds: 1),

          (_) {

        setState(() {
          _seconds++;
        });
      },
    );
  }

  void _startGame() {

    _cards = [..._spaceItems, ..._spaceItems];

    _cards.shuffle(Random());

    _flipped =
        List.generate(_cards.length, (_) => false);

    _matched =
        List.generate(_cards.length, (_) => false);

    _firstIndex = null;
    _secondIndex = null;

    _checking = false;

    _moves = 0;
    _matches = 0;

    _seconds = 0;

    _gameStarted = false;

    _timer?.cancel();

    setState(() {});
  }

  void _onCardTap(int index) {

    if (_checking) return;

    if (_flipped[index]) return;

    if (_matched[index]) return;

    _startTimer();

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {

      _firstIndex = index;

    } else {

      _secondIndex = index;

      _checking = true;

      _moves++;

      _checkMatch();
    }
  }

  void _checkMatch() {

    int first = _firstIndex!;
    int second = _secondIndex!;

    if (_cards[first] == _cards[second]) {

      Future.delayed(

        const Duration(milliseconds: 450),

            () {

          setState(() {

            _matched[first] = true;
            _matched[second] = true;

            _matches++;

            _firstIndex = null;
            _secondIndex = null;

            _checking = false;
          });

          if (_matches == _spaceItems.length) {

            _timer?.cancel();

            if (_moves < _bestScore) {
              _bestScore = _moves;
            }

            _showWinDialog();
          }
        },
      );

    } else {

      Future.delayed(

        const Duration(milliseconds: 800),

            () {

          setState(() {

            _flipped[first] = false;
            _flipped[second] = false;

            _firstIndex = null;
            _secondIndex = null;

            _checking = false;
          });
        },
      );
    }
  }

  void _showWinDialog() {

    double accuracy =
    ((_matches / _moves) * 100);

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (_) {

        return AlertDialog(

          backgroundColor:
          const Color(0xFF18233A),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          title: const Text(

            'Mission Completed 🚀',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          content: Text(

            'You matched all space cards!\n\n'
                'Moves: $_moves\n'
                'Best Score: $_bestScore\n'
                'Time: $_seconds seconds\n'
                'Accuracy: ${accuracy.toStringAsFixed(0)}%',

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          actions: [

            Center(

              child: ElevatedButton(

                onPressed: () {

                  Navigator.pop(context);

                  _startGame();
                },

                style: ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.cyanAccent,

                  foregroundColor:
                  Colors.black,
                ),

                child: const Text(
                  'Play Again',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {

    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth =
        MediaQuery.of(context).size.width;

    return Scaffold(

      backgroundColor:
      const Color(0xFF0B1020),

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF0B1020),

        centerTitle: true,

        elevation: 0,

        title: Text(

          'Space Explorer Match',

          style: TextStyle(

            color: Colors.cyanAccent,

            fontWeight: FontWeight.bold,

            fontSize:
            screenWidth > 900
                ? 30
                : 24,
          ),
        ),
      ),

      body: Column(

        children: [

          const SizedBox(height: 8),

          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            child: Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

              children: [

                _buildInfoCard(

                  Icons.touch_app,

                  'Moves',

                  '$_moves',

                  Colors.orangeAccent,
                ),

                _buildInfoCard(

                  Icons.timer,

                  'Time',

                  '$_seconds s',

                  Colors.cyanAccent,
                ),

                _buildInfoCard(

                  Icons.star,

                  'Best',

                  _bestScore == 999
                      ? '--'
                      : '$_bestScore',

                  Colors.purpleAccent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(

            child: Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),

              // ─── ONLY CHANGE: wrap grid in LayoutBuilder
              // so we can compute a dynamic childAspectRatio
              // that guarantees all 16 cards fit the window.
              child: LayoutBuilder(

                builder: (context, constraints) {

                  int crossAxisCount = 4;

                  // How many rows will the grid have?
                  final int rowCount =
                  (_cards.length / crossAxisCount).ceil();

                  // Spacing values (match gridDelegate below)
                  const double spacing = 5.0;

                  // Total vertical space taken by gaps
                  final double totalVGap =
                      spacing * (rowCount - 1);

                  // Height available for all cells combined
                  final double totalCellH =
                      constraints.maxHeight - totalVGap;

                  // Height of one cell
                  final double cellH =
                      totalCellH / rowCount;

                  // Total horizontal space taken by gaps
                  final double totalHGap =
                      spacing * (crossAxisCount - 1);

                  // Width of one cell
                  final double cellW =
                      (constraints.maxWidth - totalHGap) /
                          crossAxisCount;

                  // Dynamic aspect ratio — replaces the old
                  // hard-coded 0.82 / 1.45 / 1.65 values
                  final double aspectRatio =
                  (cellW / cellH).clamp(0.4, 3.0);

                  // Emoji / star font sizes scale with cell
                  final double emojiFontSize =
                  (cellH * 0.38).clamp(18.0, 56.0);
                  final double starFontSize =
                  (cellH * 0.28).clamp(14.0, 34.0);

                  return GridView.builder(

                    physics:
                    const NeverScrollableScrollPhysics(),

                    padding: EdgeInsets.zero,

                    itemCount: _cards.length,

                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount:
                      crossAxisCount,

                      crossAxisSpacing: spacing,

                      mainAxisSpacing: spacing,

                      // ← dynamic instead of hard-coded
                      childAspectRatio: aspectRatio,
                    ),

                    itemBuilder: (_, index) {

                      bool showFront =
                          _flipped[index] ||
                              _matched[index];

                      return MouseRegion(

                        cursor:
                        SystemMouseCursors.click,

                        child: GestureDetector(

                          onTap: () =>
                              _onCardTap(index),

                          child: AnimatedContainer(

                            duration:
                            const Duration(
                              milliseconds: 250,
                            ),

                            decoration: BoxDecoration(

                              gradient: showFront

                                  ? const LinearGradient(

                                colors: [

                                  Color(0xFF5B42F3),
                                  Color(0xFF8F94FB),
                                ],
                              )

                                  : const LinearGradient(

                                colors: [

                                  Color(0xFF16213E),
                                  Color(0xFF1B2A49),
                                ],
                              ),

                              borderRadius:
                              BorderRadius.circular(18),

                              border: Border.all(

                                color: showFront
                                    ? Colors.cyanAccent
                                    : Colors.white12,

                                width: 2,
                              ),

                              boxShadow: [

                                BoxShadow(

                                  color: Colors.black
                                      .withOpacity(0.18),

                                  blurRadius: 8,

                                  offset:
                                  const Offset(2, 4),
                                ),
                              ],
                            ),

                            child: Center(

                              child: AnimatedSwitcher(

                                duration:
                                const Duration(
                                  milliseconds: 250,
                                ),

                                // ← font sizes now dynamic
                                child: Text(

                                  showFront
                                      ? _cards[index]
                                      : '✦',

                                  key: ValueKey(showFront),

                                  style: TextStyle(

                                    fontSize: showFront
                                        ? emojiFontSize
                                        : starFontSize,

                                    fontWeight:
                                    FontWeight.bold,

                                    color: showFront
                                        ? Colors.white
                                        : Colors.cyanAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          Padding(

            padding:
            const EdgeInsets.only(
              bottom: 12,
              top: 4,
            ),

            child: ElevatedButton.icon(

              onPressed: _startGame,

              style: ElevatedButton.styleFrom(

                backgroundColor:
                Colors.cyanAccent,

                foregroundColor:
                Colors.black,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
              ),

              icon: const Icon(Icons.refresh),

              label: const Text(

                'Restart Mission',

                style: TextStyle(

                  fontSize: 16,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(

      IconData icon,
      String title,
      String value,
      Color color,
      ) {

    return Container(

      width: 100,

      padding:
      const EdgeInsets.symmetric(
        vertical: 10,
      ),

      decoration: BoxDecoration(

        color:
        const Color(0xFF16213E),

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: Colors.white12,
        ),
      ),

      child: Column(

        children: [

          Icon(

            icon,

            color: color,

            size: 24,
          ),

          const SizedBox(height: 4),

          Text(

            title,

            style: const TextStyle(

              color: Colors.white70,

              fontSize: 12,
            ),
          ),

          const SizedBox(height: 3),

          Text(

            value,

            style: const TextStyle(

              fontWeight:
              FontWeight.bold,

              fontSize: 18,

              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}