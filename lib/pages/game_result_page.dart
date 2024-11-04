import 'package:flutter/material.dart';

class GameResultPage extends StatefulWidget {
  final Map<String, dynamic> gameResult;
  final bool isOwnGame;
  const GameResultPage(
      {super.key, required this.gameResult, required this.isOwnGame});

  @override
  State<GameResultPage> createState() => _GameResultPageState();
}

class _GameResultPageState extends State<GameResultPage> {
  convertArrayToString(array) {
    String result = "";
    for (int i = 0; i < array.length; i++) {
      result += array[i];
      if (i != array.length - 1) {
        result += " and ";
      }
    }
    return result;
  }

  getWinners() {
    //Check if game is team game
    if (isTeamgame()) {
      return widget.gameResult['gameWinner'].split("_").length > 1
          ? widget.gameResult['gameWinner'].replaceAll(RegExp(r'_'), " and ")
          : widget.gameResult['gameWinner'];
    }

    return widget.gameResult['gameWinner'];
  }

  getLosers() {
    //Check if game is team game
    if (isTeamgame()) {
      //Check if submitter is winner
      if (widget.gameResult['gameWinner']
          .contains(widget.gameResult['gameSubmitterName'])) {
        return convertArrayToString(widget.gameResult['opponentNames']);
      } else {
        return widget.gameResult['gameSubmitterName'] +
            " and " +
            widget.gameResult['teammateName'];
      }
    }
    //Check if submitter is winner
    if (widget.gameResult['gameWinner']
        .contains(widget.gameResult['gameSubmitterName'])) {
      return convertArrayToString(widget.gameResult['opponentNames']);
    }
    //Submitter is loser
    //Remove the winner from the list of opponents
    List<dynamic> opponents = widget.gameResult['opponentNames'];
    opponents.remove(widget.gameResult['gameWinner']);
    return convertArrayToString(opponents) +
        " and " +
        widget.gameResult['gameSubmitterName'];
  }

  getPlayers() {
    List<Widget> players = [];

    //Combine opponents Names and Scores into a list and sort by score
    List<dynamic> opponents = widget.gameResult['opponentNames'];
    List<dynamic> opponentScores = widget.gameResult['opponentScores'];
    List<dynamic> namesAndScores = [];
    for (int i = 0; i < opponents.length; i++) {
      namesAndScores.add([opponents[i], opponentScores[i]]);
    }
    //add submitter to list
    namesAndScores.add([
      widget.gameResult['gameSubmitterName'],
      widget.gameResult['gameSubmitterScore']
    ]);

    namesAndScores.sort((a, b) => b[1].compareTo(a[1]));

    //Add each player to the list
    for (int i = 0; i < namesAndScores.length; i++) {
      players.add(
        Text(
          "${namesAndScores[i][0]}: ${namesAndScores[i][1]}",
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
      );
    }
    return players;
  }

  isTeamgame() {
    return widget.gameResult['teammateName'] != "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Result'),
      ),
      body: Center(
          child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.gameResult['gameName'],
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            widget.gameResult['gameDate'],
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Winner: ${getWinners()}",
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          if (isTeamgame())
            Text(
              "Loser: ${getLosers()}",
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          if (!isTeamgame())
            Text(
              "Players:",
              style: const TextStyle(fontSize: 20),
            ),
          if (!isTeamgame()) ...getPlayers(),
        ],
      )),
    );
  }
}
