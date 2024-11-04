import 'package:flutter/material.dart';

class ScoreCompleteTile extends StatelessWidget {
  final Function() addScore;
  final Function() totalScore;

  const ScoreCompleteTile(
      {super.key, required this.addScore, required this.totalScore});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      // padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              addScore();
            },
            child: CircleAvatar(
                child: Text(
                  "+",
                  textAlign: TextAlign.center,
                ),
                radius: 10),
          ),
          SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: () {
              totalScore();
            },
            child: CircleAvatar(
                child: Text(
                  "=",
                  textAlign: TextAlign.center,
                ),
                radius: 10),
          ),
        ],
      ),
    );
  }
}
