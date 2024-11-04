import 'package:flutter/material.dart';

class SimpleScoreCounter extends StatelessWidget {
  final int score;
  final void Function(int scoreDelta) changeScore;
  final bool showIncrement;
  final int increment;
  final Color color;
  final String playerIndex;

  const SimpleScoreCounter(
      {super.key,
      required this.score,
      required this.changeScore,
      required this.showIncrement,
      required this.increment,
      required this.color,
      required this.playerIndex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          changeScore(1);
        },
        onVerticalDragUpdate: (details) {
          // int sensitivity = 8;
          // if (details.delta.dy.abs() >= sensitivity) {
          //   int direction = details.delta.dy > 0 ? -1 : 1;
          //   changeScore(direction);
          // }

          if (details.delta.dy < 0) {
            print(details.delta.dy);
            changeScore(1);
          } else if (details.delta.dy > 0) {
            changeScore(-1);
          }
        },
        onLongPress: () {
          changeScore(-1);
        },
        child: Container(
          color: color,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "P$playerIndex",
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showIncrement)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: showIncrement ? 1.0 : 0.0,
                    child: Text(
                      '${increment >= 0 ? '+' : ''}$increment',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
