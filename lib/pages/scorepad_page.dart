import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_scorecard/pages/profile_page.dart';
import 'package:group_scorecard/widgets/scorepad_tile.dart';

import '../service/database_service.dart';
import '../widgets/widgets.dart';
import 'add_game_result.dart';

class ScorepadPage extends StatefulWidget {
  final String userName;
  final String email;
  final String selectedGameType;
  final int numberOfPlayers;

  const ScorepadPage(
      {super.key,
      required this.userName,
      required this.email,
      required this.selectedGameType,
      required this.numberOfPlayers});

  @override
  State<ScorepadPage> createState() => _ScorepadPageState();
}

class _ScorepadPageState extends State<ScorepadPage> {
  List<int> tileCount = [5, 5];

  List<Map<String, dynamic>> scoreList = [];
  List<Widget> scoreTiles = [];

  List<DropdownMenuItem<Object>> playerTiles = [];

  TextEditingController numPlayersController = TextEditingController();

  int maxHeight = 200;

  List<dynamic>? groups;
  List<Map<String, String>> groupsInfo = [];
  String selectedGroupName = "";
  String selectedGroupId = "";
  int playerOneIndex = 0;
  int playerOneScore = 0;

  changeScore(int player, int score) {
    setState(() {
      scoreList[player]["score"] = score;
    });
  }

  addTile(int player) {
    setState(() {
      tileCount[player]++;
    });
    //Get the largest tile count
    int max = tileCount.reduce((curr, next) => curr > next ? curr : next);
    //Set the max height
    setState(() {
      maxHeight = max * 40;
    });
  }

  buildScoreTiles() {
    List<Widget> buildScoreTiles = [];
    for (var i = 0; i < scoreList.length; i++) {
      buildScoreTiles.add(
        SizedBox(
          width: 25,
        ),
      );
      buildScoreTiles.add(
        ScorepadTile(
          playerName: scoreList[i]["player"],
          playerId: i,
          addTile: addTile,
          height: maxHeight,
          changeScore: changeScore,
        ),
      );
    }
    setState(() {
      scoreTiles = List.from(buildScoreTiles);
    });
  }

  buildPlayerTiles() {
    List<Widget> buildPlayerTiles = [];
    for (var i = 0; i < scoreList.length; i++) {
      buildPlayerTiles.add(
          DropdownMenuItem(child: Text(scoreList[i]["playerName"]), value: i));
    }
    setState(() {
      playerTiles = List.from(buildPlayerTiles);
    });
  }

  getGroupsFromDB() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroupsList(FirebaseAuth.instance.currentUser!.uid)
        .then((val) {
      setState(() {
        groups = val;
      });
      getGroups();
    });
  }

  getGroups() {
    for (int i = 0; i < groups!.length; i++) {
      setState(() {
        List<String> groupData = groups![i].toString().split('_');
        var group = {
          "groupName": groupData[1],
          "groupId": groupData[0],
        };
        groupsInfo.add(group);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    createPlayerTiles(widget.numberOfPlayers);
    getGroupsFromDB();
    buildScoreTiles();
  }

  createPlayerTiles(numPlayers) {
    //Create the player tiles
    for (var i = 0; i < numPlayers; i++) {
      scoreList.add({
        "player": "P${i + 1}",
        "playerName": "Player ${i + 1}",
        "score": 0,
        "index": i,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scorepad",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                editScorepad(context, []);
              },
              icon: const Icon(
                Icons.edit,
                size: 25,
              ),
              splashRadius: 25),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
                onPressed: () {
                  selectGroup(context);
                },
                icon: const Icon(
                  Icons.save_as,
                  size: 25,
                ),
                splashRadius: 25),
          )
        ],
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          SizedBox(
            height: maxHeight.toDouble(),
            child: ListView(
              //Display at top of screen
              //mainAxisAlignment: MainAxisAlignment.center,
              scrollDirection: Axis.horizontal,
              children: [...scoreTiles],
            ),
          ),
        ],
      ),
    );
    //);
  }

  copyList(listToCopy) {
    List<Map<String, dynamic>> copyList = [];
    for (var i = 0; i < listToCopy.length; i++) {
      copyList.add({
        "player": listToCopy[i]["player"],
        "playerName": listToCopy[i]["playerName"],
        "score": listToCopy[i]["score"],
        "index": listToCopy[i]["index"],
      });
    }
    return copyList;
  }

  editScorepad(context, editScoreList) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    //Copy the scoreList to editScoreList
    if (editScoreList.length == 0) {
      //editScoreList = List.from(scoreList);
      editScoreList = copyList(scoreList);
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Edit Scorepad Players",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 500,
                    //Check if the would be height is greater than the screen height
                    //If it is, set the height to the screen height - 100
                    height: (editScoreList.length) > 8
                        ? 400
                        : (editScoreList.length * 50).toDouble(),
                    child: ReorderableListView(
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      children: <Widget>[
                        for (int index = 0;
                            index < editScoreList.length;
                            index += 1)
                          SizedBox(
                            height: 50,
                            key: Key('$index'),
                            child: ColoredBox(
                              color: index.isOdd ? oddItemColor : evenItemColor,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                      width: 100,
                                      height: 20,
                                      child: Text(
                                          '${editScoreList[index]["playerName"]}',
                                          overflow: TextOverflow.ellipsis)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          editPlayer(
                                              context,
                                              editScoreList.indexOf(
                                                  editScoreList[index]),
                                              editScoreList);
                                        },
                                        icon: Icon(Icons.edit),
                                        splashRadius: 25,
                                      ),
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: const Icon(Icons.drag_handle),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final Map<String, dynamic> item =
                              editScoreList.removeAt(oldIndex);
                          item["index"] = newIndex;
                          editScoreList.insert(newIndex, item);
                          // print(newIndex);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editScoreList.add({
                            "player": "P${editScoreList.length + 1}",
                            "playerName": "Player ${editScoreList.length + 1}",
                            "score": 0,
                            "index": editScoreList.length,
                          });
                        });
                      },
                      child: Text("Add Player")),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          editScoreList.add({
                            "player": "P${editScoreList.length + 1}",
                            "playerName": "Player ${editScoreList.length + 1}",
                            "score": 0,
                            "index": editScoreList.length,
                          });
                        });
                      },
                      child: Text("Add Custom Column")),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    print(editScoreList);
                    print(scoreList);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      scoreList = copyList(editScoreList);
                    });
                    buildScoreTiles();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Save Changes"),
                ),
              ],
            );
          });
        });
  }

  editPlayer(context, playerId, editScoreList) {
    // print(playerId);
    String playerName = editScoreList[playerId]["playerName"];
    String playerNick = editScoreList[playerId]["player"];

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Edit Player",
                textAlign: TextAlign.left,
              ),
              content: SizedBox(
                width: 400,
                height: 300,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: playerName,
                      decoration: InputDecoration(
                        labelText: "Player Name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          playerName = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      initialValue: playerNick,
                      decoration: InputDecoration(
                        labelText: "Player Nickname",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          playerNick = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            editScoreList.removeAt(playerId);
                          });
                          Navigator.pop(context);
                          editScorepad(context, editScoreList);
                        },
                        child: Text("Remove Player"))
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    editScorepad(context, editScoreList);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      editScoreList[playerId]["playerName"] = playerName;
                      editScoreList[playerId]["player"] = playerNick;
                    });
                    Navigator.pop(context);
                    editScorepad(context, editScoreList);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Save Changes"),
                ),
              ],
            );
          });
        });
  }

  selectGroup(context) {
    buildPlayerTiles();
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Game Info",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                      decoration: textInputDecoration.copyWith(
                        labelText: "Group Name",
                        prefixIcon: Icon(
                          Icons.sports_esports,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      items: groupsInfo.map((Map<String, String> value) {
                        return DropdownMenuItem<String>(
                          value:
                              "${value['groupId'].toString()}_${value['groupName'].toString()}",
                          alignment: Alignment.center,
                          child: Text(value['groupName'].toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        String groupId = value.toString().split('_')[0];
                        String groupName = value.toString().split('_')[1];
                        setState(() {
                          selectedGroupId = groupId;
                          selectedGroupName = groupName;
                        });
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  DropdownButtonFormField(
                      decoration: textInputDecoration.copyWith(
                        labelText: "Who are you?",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      items: [...playerTiles],
                      onChanged: (value) {
                        setState(() {
                          playerOneIndex = value as int;
                          playerOneScore = scoreList[playerOneIndex]["score"];
                        });
                      }),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    //Go to add game result page
                    Navigator.pop(context);
                    Map<int, int> opponentScores = {};
                    for (int i = 0; i < scoreList.length; i++) {
                      if (i != playerOneIndex) {
                        int index = i;
                        if (i > playerOneIndex) {
                          index = i - 1;
                        }
                        opponentScores[index] = scoreList[i]["score"];
                      }
                    }

                    Map<int, String> opponentNames = {};
                    for (int i = 0; i < scoreList.length; i++) {
                      if (i != playerOneIndex) {
                        int index = i;
                        if (i > playerOneIndex) {
                          index = i - 1;
                        }
                        opponentNames[index] = scoreList[i]["playerName"];
                      }
                    }
                    print(opponentScores);
                    print(opponentNames);

                    nextScreen(
                        context,
                        AddGameResultPage(
                          userName: widget.userName,
                          groupId: selectedGroupId,
                          groupName: selectedGroupName,
                          myScore: playerOneScore,
                          opponentScores: opponentScores,
                          opponentNames: opponentNames,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Save Game"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Cancel"),
                ),
              ],
            );
          });
        });
  }
}
