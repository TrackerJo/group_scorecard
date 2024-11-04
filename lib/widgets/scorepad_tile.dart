import 'package:flutter/material.dart';
import 'package:group_scorecard/widgets/score_add_tile.dart';
import 'package:group_scorecard/widgets/score_complete_tile.dart';
import 'package:group_scorecard/widgets/score_tile.dart';

class ScorepadTile extends StatefulWidget {
  final String playerName;
  final int playerId;
  final int height;
  final Function(int) addTile;
  final Function(int, int) changeScore;

  const ScorepadTile(
      {super.key,
      required this.playerName,
      required this.height,
      required this.addTile,
      required this.playerId,
      required this.changeScore});

  @override
  State<ScorepadTile> createState() => _ScorepadTileState();
}

class _ScorepadTileState extends State<ScorepadTile> {
  List<Map<String, dynamic>> scoreList = [];

  int scoreToAdd = 0;

  changeScoreToAdd(int score) {
    setState(() {
      scoreToAdd = score;
    });
  }

  addScore() {
    String operation = scoreToAdd >= 0 ? "+" : "-";
    setState(() {
      if (scoreList.length > 0) {
        if (scoreList.last['operation'] == operation) {
          scoreList.last['operation'] = "";
        }
      }
      scoreList.add({'score': scoreToAdd, 'operation': operation});
      widget.addTile(widget.playerId);
      scoreToAdd = 0;
    });
  }

  totalScore() {
    int total = 0;
    scoreList.forEach((score) {
      if (score['score'] != null && score['isTotal'] != true) {
        total += score['score'] as int;
      }
    });
    setState(() {
      scoreList.add({'isDivider': true});
      scoreList.add({'score': total, 'isTotal': true});
      widget.addTile(widget.playerId);
      widget.addTile(widget.playerId);
    });
    widget.changeScore(widget.playerId, total);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> scoreTiles = [];
    scoreList.forEach((score) {
      if (score['isDivider'] == true) {
        scoreTiles.add(Divider(
          thickness: 1,
          height: 1,
          color: Colors.black,
        ));
      } else {
        scoreTiles.add(ScoreTile(
            score: score['score'],
            operation: score['operation'] != null ? score['operation'] : ""));
      }
    });
    return SizedBox(
      width: 50,
      height: widget.height.toDouble(),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.playerName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Divider(
            thickness: 1,
            height: 1,
            color: Colors.black,
          ),
          ...scoreTiles,
          ScoreAddTile(
            scoreToAdd: scoreToAdd,
            changeScore: changeScoreToAdd,
          ),
          SizedBox(
            height: 10,
          ),
          ScoreCompleteTile(
            addScore: addScore,
            totalScore: totalScore,
          ),
          // ScoreTile(
          //   score: 5,
          // ),
          // ScoreTile(
          //   score: 5,
          // ),
          // ScoreTile(score: 10, operation: "+"),
          // Divider(
          //   thickness: 1,
          //   height: 1,
          //   color: Colors.black,
          // ),
          // ScoreTile(
          //   score: 20,
          // ),
        ],
      ),
    );
  }
}
