import 'package:flutter/material.dart';

class ScoreTile extends StatelessWidget {
  final int score;
  final String operation;

  const ScoreTile({super.key, required this.score, this.operation = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            operation,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          Text(
            score.abs().toString(),
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
