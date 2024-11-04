import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../service/database_service.dart';
import '../widgets/limit_range.dart';
import '../widgets/widgets.dart';

class AddGameResultPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final int myScore;
  final Map<int, int> opponentScores;
  final Map<int, String> opponentNames;

  const AddGameResultPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      this.myScore = -99999,
      this.opponentScores = const {},
      this.opponentNames = const {}});

  @override
  State<AddGameResultPage> createState() => _AddGameResultPageState();
}

class _AddGameResultPageState extends State<AddGameResultPage> {
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  //Game Selection Variables
  String gameId = "";
  String gameType = "";
  String numberOfPlayers = "";
  String gameName = "";
  bool variedPlayers = false;
  int minPlayers = 0;
  int maxPlayers = 0;
  Map<String, String> selectedGame = {};

  QuerySnapshot? games;
  List<Map<String, String>> gamesInfo = [];

  //Game Result Variables
  int myScore = -99999;
  String teammateName = "";
  Map<int, String> opponentNames = {};
  Map<int, int> opponentScores = {};
  String winner = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGamesFromDB();
    if (widget.myScore != -99999) {
      setState(() {
        myScore = widget.myScore;
      });
    }
    if (widget.opponentScores.isNotEmpty) {
      setState(() {
        opponentScores = widget.opponentScores;
      });
    }
    if (widget.opponentNames.isNotEmpty) {
      setState(() {
        opponentNames = widget.opponentNames;
      });
    }
  }

  getGamesFromDB() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGames()
        .then((val) {
      setState(() {
        games = val;
      });
      getGames();
    });
  }

  getGames() {
    for (int i = 0; i < games!.docs.length; i++) {
      setState(() {
        var school = {
          "gameName": games!.docs[i]["Name"].toString(),
          "gameType": games!.docs[i]["Type"].toString(),
          "numberOfPlayers": games!.docs[i]["NumOfPlayers"].toString(),
          "gameId": games!.docs[i]["id"].toString(),
        };
        gamesInfo.add(school);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Game Result"),
      ),
      body: Container(
        child: SingleChildScrollView(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80),
                child: Form(
                    key: formKey,
                    child: selectedGame.isEmpty
                        ? selectGame()
                        : gameType == "outdoor"
                            ? gameId == "spp" || gameId == "dpp"
                                ? pingPongGame()
                                : gameId == "cornhole"
                                    ? cornholeGame()
                                    : Container()
                            : gameType == "cards"
                                ? cardsGame()
                                : Container()))),
      ),
    );
  }

  selectGame() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField(
              decoration: textInputDecoration.copyWith(
                labelText: "Game",
                prefixIcon: Icon(
                  Icons.sports_esports,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              items: gamesInfo.map((Map<String, String> value) {
                return DropdownMenuItem<String>(
                  value:
                      "${value['gameId'].toString()},${value['gameType'].toString()},${value['numberOfPlayers'].toString()},${value['gameName'].toString()}",
                  alignment: Alignment.center,
                  child: Text(value['gameName'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  List<String> gameInfo = value!.split(",");

                  gameId = gameInfo[0];
                  gameType = gameInfo[1];
                  numberOfPlayers = gameInfo[2];
                  gameName = gameInfo[3];
                  if (numberOfPlayers.contains("v")) {
                    variedPlayers = true;
                    //Remove the v from the string
                    numberOfPlayers = numberOfPlayers.substring(1);
                    List<String> players = numberOfPlayers.split("-");
                    minPlayers = int.parse(players[0]);
                    maxPlayers = int.parse(players[1]);
                  } else {
                    variedPlayers = false;
                  }
                });
              }),
          const SizedBox(height: 20),
          variedPlayers
              ? TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LimitRangeTextInputFormatter(minPlayers, maxPlayers),
                  ],
                  style: const TextStyle(color: Colors.black),
                  decoration: textInputDecoration.copyWith(
                      labelText:
                          "Number of Players (min: $minPlayers, max: $maxPlayers)"),
                  onChanged: (val) {
                    setState(() {
                      numberOfPlayers = val;
                    });
                  },
                )
              : Container(),
          const SizedBox(height: 20),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30))),
                child: const Text(
                  "Select Game",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () {
                  if (numberOfPlayers.contains("-")) {
                    showSnackBar(
                        context, Colors.red, "Please fill out all the fields!");
                  } else {
                    setState(() {
                      selectedGame = {
                        "gameId": gameId,
                        "gameType": gameType,
                        "numberOfPlayers": numberOfPlayers,
                        "gameName": gameName,
                      };
                    });
                  }
                },
              )),
        ]);
  }

  cornholeGame() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Cornhole Game Results",
          textAlign: TextAlign.left,
        ),
        fourPlayerTeamGame(),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              submitGameResults();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text("Submit Game Results"),
        ),
      ],
    );
  }

  pingPongGame() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Ping Pong Game Results",
          textAlign: TextAlign.left,
        ),
        gameId.contains("s") ? twoPlayerGame() : fourPlayerTeamGame(),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              submitGameResults();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text("Submit Game Results"),
        ),
      ],
    );
  }

  twoPlayerGame() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: myScore == -99999 ? "" : myScore.toString(),
              decoration: textInputDecoration.copyWith(labelText: "Your Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  if (val == "")
                    myScore = 0;
                  else
                    myScore = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 0 ? "" : opponentNames[0],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponents Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[0] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.length < 1 ? "" : opponentScores[0].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponents Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  if (val.isEmpty) {
                    opponentScores[0] = 0;
                  } else {
                    opponentScores[0] = int.parse(val);
                  }
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : DropdownButtonFormField(
              decoration: textInputDecoration.copyWith(
                labelText: "Who won?",
                prefixIcon: Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              items: const [
                DropdownMenuItem(child: Text("Me"), value: "me"),
                DropdownMenuItem(child: Text("Opponent"), value: "opp"),
              ],
              onChanged: (val) {
                setState(() {
                  winner = (val == "me" ? widget.userName : opponentNames[0])!;
                });
              },
            )
    ]);
  }

  fourPlayerTeamGame() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration:
                  textInputDecoration.copyWith(labelText: "Teamate's Name"),
              onChanged: (val) {
                setState(() {
                  teammateName = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              initialValue: myScore == -99999 ? "" : myScore.toString(),
              style: const TextStyle(color: Colors.black),
              decoration: textInputDecoration.copyWith(labelText: "Your Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  if (val == "")
                    myScore = 0;
                  else
                    myScore = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[0] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 2 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[1] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.isEmpty ? "" : opponentScores[0].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponents Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  opponentScores[0] = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : DropdownButtonFormField(
              decoration: textInputDecoration.copyWith(
                labelText: "Who won?",
                prefixIcon: Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              items: const [
                DropdownMenuItem(child: Text("Us"), value: "us"),
                DropdownMenuItem(child: Text("Them"), value: "them"),
              ],
              onChanged: (val) {
                setState(() {
                  winner = (val == "us"
                      ? "${widget.userName}_${teammateName}"
                      : "${opponentNames[0]}_${opponentNames[1]}");
                });
              },
            )
    ]);
  }

  cardsGame() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "$gameName Game Results",
          textAlign: TextAlign.left,
        ),
        gameId == "euchre"
            ? fourPlayerTeamGame()
            : gameId == "cribbage" && numberOfPlayers == "2"
                ? cribbageTwoPlayer()
                : gameId == "cribbage" && numberOfPlayers == "2"
                    ? cribbageThreePlayer()
                    : multiPlayerGame(),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              submitGameResults();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text("Submit Game Results"),
        ),
      ],
    );
  }

  fourPlayerSoloGame() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              initialValue: myScore == -99999 ? "" : myScore.toString(),
              style: const TextStyle(color: Colors.black),
              decoration: textInputDecoration.copyWith(labelText: "Your Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  myScore = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 0 ? "" : opponentNames[0],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[0] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.length < 1 ? "" : opponentScores[0].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  opponentScores[0] = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 1 ? "" : opponentNames[1],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 2 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[1] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.length < 2 ? "" : opponentScores[1].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 2 Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  opponentScores[1] = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 2 ? "" : opponentNames[2],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 3 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[2] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.length < 3 ? "" : opponentScores[2].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 3 Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  opponentScores[2] = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : DropdownButtonFormField(
              decoration: textInputDecoration.copyWith(
                labelText: "Who won?",
                prefixIcon: Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              items: const [
                DropdownMenuItem(child: Text("Me"), value: "me"),
                DropdownMenuItem(child: Text("Opponent 1"), value: "opp_1"),
                DropdownMenuItem(child: Text("Opponent 2"), value: "opp_2"),
                DropdownMenuItem(child: Text("Opponent 3"), value: "opp_3"),
              ],
              onChanged: (val) {
                setState(() {
                  winner = (val == "me"
                      ? widget.userName
                      : opponentNames[int.parse(val!.split("_")[1]) + 1])!;
                });
              },
            )
    ]);
  }

  threePlayerGame() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: myScore == -99999 ? "" : myScore.toString(),
              decoration: textInputDecoration.copyWith(labelText: "Your Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  myScore = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 0 ? "" : opponentNames[0],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[0] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.length < 1 ? "" : opponentScores[0].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  opponentScores[0] = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 1 ? "" : opponentNames[1],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 2 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[1] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue:
                  opponentScores.length < 2 ? "" : opponentScores[1].toString(),
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 2 Score"),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LimitRangeTextInputFormatter(0, 100),
              ],
              onChanged: (val) {
                setState(() {
                  opponentScores[1] = int.parse(val);
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : DropdownButtonFormField(
              decoration: textInputDecoration.copyWith(
                labelText: "Who won?",
                prefixIcon: Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              items: const [
                DropdownMenuItem(child: Text("Me"), value: "me"),
                DropdownMenuItem(
                    child: Text("Opponent 1"), value: "opponent_1"),
                DropdownMenuItem(
                    child: Text("Opponent 2"), value: "opponent_2"),
              ],
              onChanged: (val) {
                setState(() {
                  winner = (val == "me"
                      ? widget.userName
                      : opponentNames[int.parse(val!.split("_")[1]) + 1])!;
                });
              },
            )
    ]);
  }

  multiPlayerGame() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // your code here
          _isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : TextFormField(
                  style: const TextStyle(color: Colors.black),
                  initialValue: myScore == -99999 ? "" : myScore.toString(),
                  decoration:
                      textInputDecoration.copyWith(labelText: "Your Score"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LimitRangeTextInputFormatter(0, 100),
                  ],
                  onChanged: (val) {
                    setState(() {
                      myScore = int.parse(val);
                    });
                  },
                ),
          SizedBox(
            height: 10,
          ),
          for (int i = 0; i < int.parse(numberOfPlayers) - 1; i++) ...[
            SizedBox(
              height: 10,
            ),
            _isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor),
                  )
                : TextFormField(
                    style: const TextStyle(color: Colors.black),
                    initialValue:
                        opponentNames.length < i + 1 ? "" : opponentNames[i],
                    decoration: textInputDecoration.copyWith(
                        labelText: "Opponent ${i + 1} Name"),
                    onChanged: (val) {
                      setState(() {
                        opponentNames[i] = val;
                      });
                    },
                  ),
            SizedBox(
              height: 10,
            ),
            _isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor),
                  )
                : TextFormField(
                    initialValue: opponentScores.length < i + 1
                        ? ""
                        : opponentScores[i].toString(),
                    style: const TextStyle(color: Colors.black),
                    decoration: textInputDecoration.copyWith(
                        labelText: "Opponent ${i + 1} Score"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LimitRangeTextInputFormatter(-9999, 9999),
                    ],
                    onChanged: (val) {
                      setState(() {
                        opponentScores[i] = val != "" ? int.parse(val) : 0;
                      });
                    },
                  ),
          ],
          SizedBox(
            height: 10,
          ),

          _isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor),
                )
              : DropdownButtonFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: "Who won?",
                    prefixIcon: Icon(
                      Icons.leaderboard,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(child: Text("Me"), value: "me"),
                    //Use for Loop for each opponent
                    for (int i = 0;
                        i < int.parse(numberOfPlayers) - 1;
                        i++) ...[
                      DropdownMenuItem(
                          child: Text("Opponent ${i + 1}"),
                          value: "opponent_$i"),
                    ]
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (val == "me") {
                        winner = widget.userName;
                      } else {
                        winner = opponentNames[int.parse(val!.split("_")[1])]!;
                      }
                    });
                  },
                )
        ],
      ),
    );
  }

  cribbageThreePlayer() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 0 ? "" : opponentNames[0],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[0] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 1 ? "" : opponentNames[1],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 2 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[1] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : DropdownButtonFormField(
              decoration: textInputDecoration.copyWith(
                labelText: "Who won?",
                prefixIcon: Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              items: const [
                DropdownMenuItem(child: Text("Me"), value: "me"),
                DropdownMenuItem(child: Text("Opponent 1"), value: "oppo_1"),
                DropdownMenuItem(child: Text("Opponent 2"), value: "opp_2"),
              ],
              onChanged: (val) {
                setState(() {
                  winner = (val == "me"
                      ? widget.userName
                      : opponentNames[int.parse(val!.split("_")[1]) + 1])!;
                });
              },
            )
    ]);
  }

  cribbageTwoPlayer() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : TextFormField(
              style: const TextStyle(color: Colors.black),
              initialValue: opponentNames.length < 0 ? "" : opponentNames[0],
              decoration:
                  textInputDecoration.copyWith(labelText: "Opponent 1 Name"),
              onChanged: (val) {
                setState(() {
                  opponentNames[0] = val;
                });
              },
            ),
      SizedBox(
        height: 10,
      ),
      _isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : DropdownButtonFormField(
              items: const [
                DropdownMenuItem(child: Text("Me"), value: "me"),
                DropdownMenuItem(child: Text("Opponent"), value: "opponentOne"),
              ],
              decoration: textInputDecoration.copyWith(
                labelText: "Who won?",
                prefixIcon: Icon(
                  Icons.leaderboard,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  winner = (val == "me" ? widget.userName : opponentNames[0])!;
                });
              },
            )
    ]);
  }

  submitGameResults() async {
    if ((myScore != -99999 || gameId == "cribbage") &&
        opponentNames.isNotEmpty &&
        (opponentScores.isNotEmpty || gameId == "cribbage")) {
      setState(() {
        _isLoading = true;
      });

      DateTime now = DateTime.now();
      String formattedDate = DateFormat.yMd().add_jm().format(now);

      Map<String, dynamic> gameResults = {
        "myName": widget.userName,
        "myScore": myScore,
        "teammateName": teammateName,
        "opponentNames": opponentNames,
        "opponentScores": opponentScores,
        "winner": winner,
        "gameType": gameType,
        "gameName": gameName,
        "gameDate": formattedDate,
        "gameId": gameId,
      };

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .addGameResult(FirebaseAuth.instance.currentUser!.uid, widget.groupId,
              gameResults)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
          selectedGame = {};
        });
        Navigator.of(context).pop(context);
        showSnackBar(
            context, Colors.green, "Game result submitted successfully!");
      });
    } else {
      showSnackBar(context, Colors.red, "Please fill out all the fields!");
    }
  }
}
