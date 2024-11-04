import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/game_result_page.dart';
import 'package:group_scorecard/pages/games_page.dart';
import 'package:group_scorecard/widgets/widgets.dart';

import '../service/database_service.dart';

class GameResultTile extends StatefulWidget {
  final String gameResultId;
  final String gameName;
  final String gameDate;
  final String groupId;
  final bool isWinner;
  final bool isOwnGame;

  const GameResultTile({
    super.key,
    required this.gameResultId,
    required this.gameName,
    required this.gameDate,
    required this.groupId,
    required this.isWinner,
    required this.isOwnGame,
  });

  @override
  State<GameResultTile> createState() => _GameResultTileState();
}

class _GameResultTileState extends State<GameResultTile> {
  bool isDismissing = false;
  bool _isDismissed = false;
  Map<String, dynamic> gameResult = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGameResultFromDB();
  }

  void getGameResultFromDB() async {
    Map<String, dynamic> val =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getGameResultData(
      widget.gameResultId,
      widget.groupId,
    );
    setState(() {
      gameResult = val;
    });
  }

  getEachFistLetterOfWords(String words) {
    String result = "";
    List<String> wordsList = words.split(" ");
    for (int i = 0; i < wordsList.length; i++) {
      result += wordsList[i].substring(0, 1).toUpperCase();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          nextScreen(
              context,
              GameResultPage(
                gameResult: gameResult,
                isOwnGame: widget.isOwnGame,
              ));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: ListTile(
            title: Text(widget.gameName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.gameDate),
            trailing: widget.isOwnGame
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: widget.isWinner
                        ? Color.fromARGB(255, 4, 220, 11)
                        : Colors.red,
                    child: Text(widget.isWinner ? "You Won" : "You Lost",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  )
                : null,
          ),
        ));
  }
}
