import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/profile_page.dart';

import '../service/database_service.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/simple_score_counter.dart';
import '../widgets/widgets.dart';
import 'add_game_result.dart';

class ScoreCounterSimplePage extends StatefulWidget {
  final String userName;
  final String email;
  final String selectedGameType;

  const ScoreCounterSimplePage(
      {super.key,
      required this.userName,
      required this.email,
      required this.selectedGameType});

  @override
  State<ScoreCounterSimplePage> createState() => _ScoreCounterSimplePageState();
}

class _ScoreCounterSimplePageState extends State<ScoreCounterSimplePage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  int playerOneScore = 0;
  int playerTwoScore = 0;
  int playerThreeScore = 0;
  int playerFourScore = 0;
  int playerOneIncrement = 0;
  int playerTwoIncrement = 0;
  int playerThreeIncrement = 0;
  int playerFourIncrement = 0;
  bool _showPlayerOneIncrement = false;
  bool _showPlayerTwoIncrement = false;
  bool _showPlayerThreeIncrement = false;
  bool _showPlayerFourIncrement = false;
  Timer? _timer;
  bool _showMenu = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool saveGame = false;
  bool _isLoading = false;

  List<dynamic>? groups;
  List<Map<String, String>> groupsInfo = [];

  String selectedGroupName = "";
  String selectedGroupId = "";

  void _startTimer() {
    _timer = Timer(Duration(seconds: 1), () {
      setState(() {
        playerOneIncrement = 0;
        playerTwoIncrement = 0;
        _showPlayerOneIncrement = false;
        _showPlayerTwoIncrement = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    getGroupsFromDB();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
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

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;

      if (_showMenu) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.selectedGameType == "2p"
          ? TwoPersonScorePage()
          : widget.selectedGameType == "4p"
              ? FourPersonScorePage()
              : widget.selectedGameType == "3p"
                  ? ThreePersonScorePage()
                  : Container(),
    );
  }

  TwoPersonScorePage() {
    return Stack(
      children: [
        Column(
          children: [
            SimpleScoreCounter(
                increment: playerOneIncrement,
                showIncrement: _showPlayerOneIncrement,
                score: playerOneScore,
                color: Colors.red,
                playerIndex: "1",
                changeScore: (deltaScore) {
                  setState(() {
                    playerOneScore += deltaScore;
                    playerOneIncrement += deltaScore;
                    _showPlayerOneIncrement = true;
                    _showPlayerTwoIncrement = false;
                    _timer?.cancel();
                    _startTimer();
                  });
                }),
            SizeTransition(
              sizeFactor: _animation,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          playerOneScore = 0;
                          playerTwoScore = 0;
                          _showPlayerTwoIncrement = false;
                          _showPlayerOneIncrement = false;
                        });
                      },
                      icon: Icon(Icons.refresh),
                      color: Colors.black,
                    ),
                    IconButton(
                      onPressed: () {
                        //Go to previous page
                        askToSaveGave(context);
                      },
                      icon: Icon(Icons.home),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SimpleScoreCounter(
                score: playerTwoScore,
                playerIndex: "2",
                changeScore: (score) {
                  setState(() {
                    playerTwoScore += score;
                    playerTwoIncrement += score;
                    _showPlayerOneIncrement = false;
                    _showPlayerTwoIncrement = true;
                    _timer?.cancel();
                    _startTimer();
                  });
                },
                showIncrement: _showPlayerTwoIncrement,
                increment: playerTwoIncrement,
                color: Colors.blue),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 25,
          left: MediaQuery.of(context).size.width / 2 - 25,
          child: GestureDetector(
            onTap: _toggleMenu,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animationController,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ThreePersonScorePage() {
    return Stack(
      children: [
        Column(
          children: [
            SimpleScoreCounter(
                increment: playerOneIncrement,
                showIncrement: _showPlayerOneIncrement,
                score: playerOneScore,
                color: Colors.red,
                playerIndex: "1",
                changeScore: (deltaScore) {
                  setState(() {
                    playerOneScore += deltaScore;
                    playerOneIncrement += deltaScore;
                    _showPlayerOneIncrement = true;
                    _showPlayerTwoIncrement = false;
                    _showPlayerThreeIncrement = false;
                    _timer?.cancel();
                    _startTimer();
                  });
                }),
            SizeTransition(
              sizeFactor: _animation,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          playerOneScore = 0;
                          playerTwoScore = 0;
                          playerThreeScore = 0;
                          _showPlayerOneIncrement = false;
                          _showPlayerTwoIncrement = false;
                          _showPlayerThreeIncrement = false;
                        });
                      },
                      icon: Icon(Icons.refresh),
                      color: Colors.black,
                    ),
                    IconButton(
                      onPressed: () {
                        //Go to previous page
                        askToSaveGave(context);
                      },
                      icon: Icon(Icons.home),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            SimpleScoreCounter(
                score: playerTwoScore,
                playerIndex: "2",
                changeScore: (score) {
                  setState(() {
                    playerTwoScore += score;
                    playerTwoIncrement += score;
                    _showPlayerOneIncrement = false;
                    _showPlayerTwoIncrement = true;
                    _showPlayerThreeIncrement = false;
                    _timer?.cancel();
                    _startTimer();
                  });
                },
                showIncrement: _showPlayerTwoIncrement,
                increment: playerTwoIncrement,
                color: Colors.blue),
            SimpleScoreCounter(
                score: playerThreeScore,
                playerIndex: "3",
                changeScore: (score) {
                  setState(() {
                    playerThreeScore += score;
                    playerThreeIncrement += score;
                    _showPlayerOneIncrement = false;
                    _showPlayerTwoIncrement = false;
                    _showPlayerThreeIncrement = true;
                    _timer?.cancel();
                    _startTimer();
                  });
                },
                showIncrement: _showPlayerThreeIncrement,
                increment: playerThreeIncrement,
                color: Colors.green),
          ],
        ),
        // Positioned(
        //   top: MediaQuery.of(context).size.height / 2 - (_showMenu ? 157 : 165),
        //   left: MediaQuery.of(context).size.width / 2 - 25,
        //   child: GestureDetector(
        //     onTap: _toggleMenu,
        //     child: CircleAvatar(
        //       radius: 25,
        //       backgroundColor: Colors.white,
        //       child: AnimatedIcon(
        //         icon: AnimatedIcons.menu_close,
        //         progress: _animationController,
        //         color: Colors.black,
        //       ),
        //     ),
        //   ),
        // ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 145,
          left: MediaQuery.of(context).size.width / 2 - 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    playerOneScore = 0;
                    playerTwoScore = 0;
                    playerThreeScore = 0;
                    _showPlayerOneIncrement = false;
                    _showPlayerTwoIncrement = false;
                    _showPlayerThreeIncrement = false;
                  });
                },
                icon: Icon(Icons.refresh),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  //Go to previous page
                  askToSaveGave(context);
                },
                icon: Icon(Icons.home),
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  FourPersonScorePage() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SimpleScoreCounter(
                      increment: playerOneIncrement,
                      showIncrement: _showPlayerOneIncrement,
                      score: playerOneScore,
                      color: Colors.red,
                      playerIndex: "1",
                      changeScore: (deltaScore) {
                        setState(() {
                          playerOneScore += deltaScore;
                          playerOneIncrement += deltaScore;
                          _showPlayerOneIncrement = true;
                          _showPlayerTwoIncrement = false;
                          _showPlayerThreeIncrement = false;
                          _showPlayerFourIncrement = false;
                          _timer?.cancel();
                          _startTimer();
                        });
                      }),
                  SimpleScoreCounter(
                      score: playerTwoScore,
                      playerIndex: "2",
                      changeScore: (score) {
                        setState(() {
                          playerTwoScore += score;
                          playerTwoIncrement += score;
                          _showPlayerOneIncrement = false;
                          _showPlayerTwoIncrement = true;
                          _showPlayerThreeIncrement = false;
                          _showPlayerFourIncrement = false;
                          _timer?.cancel();
                          _startTimer();
                        });
                      },
                      showIncrement: _showPlayerTwoIncrement,
                      increment: playerTwoIncrement,
                      color: Colors.blue),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _animation,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          playerOneScore = 0;
                          playerTwoScore = 0;
                          playerThreeScore = 0;
                          playerFourScore = 0;
                          _showPlayerOneIncrement = false;
                          _showPlayerTwoIncrement = false;
                          _showPlayerThreeIncrement = false;
                          _showPlayerFourIncrement = false;
                        });
                      },
                      icon: Icon(Icons.refresh),
                      color: Colors.black,
                    ),
                    IconButton(
                      onPressed: () {
                        //Go to previous page
                        askToSaveGave(context);
                      },
                      icon: Icon(Icons.home),
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SimpleScoreCounter(
                      increment: playerThreeIncrement,
                      showIncrement: _showPlayerThreeIncrement,
                      score: playerThreeScore,
                      color: Colors.green,
                      playerIndex: "3",
                      changeScore: (deltaScore) {
                        setState(() {
                          playerThreeScore += deltaScore;
                          playerThreeIncrement += deltaScore;
                          _showPlayerOneIncrement = false;
                          _showPlayerTwoIncrement = false;
                          _showPlayerThreeIncrement = true;
                          _showPlayerFourIncrement = false;

                          _timer?.cancel();
                          _startTimer();
                        });
                      }),
                  SimpleScoreCounter(
                      score: playerFourScore,
                      playerIndex: "4",
                      changeScore: (score) {
                        setState(() {
                          playerFourScore += score;
                          playerFourIncrement += score;
                          _showPlayerOneIncrement = false;
                          _showPlayerTwoIncrement = false;
                          _showPlayerThreeIncrement = false;
                          _showPlayerFourIncrement = true;
                          _timer?.cancel();
                          _startTimer();
                        });
                      },
                      showIncrement: _showPlayerFourIncrement,
                      increment: playerFourIncrement,
                      color: Colors.yellow),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2 - 25,
          left: MediaQuery.of(context).size.width / 2 - 25,
          child: GestureDetector(
            onTap: _toggleMenu,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: AnimatedIcon(
                icon: AnimatedIcons.menu_close,
                progress: _animationController,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  askToSaveGave(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Do you want to save this game?",
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    selectGroup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Yes"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("No"),
                ),
              ],
            );
          });
        });
  }

  selectGroup(context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "What group do you want to save the game to?",
                textAlign: TextAlign.left,
              ),
              content: DropdownButtonFormField(
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
              actions: [
                ElevatedButton(
                  onPressed: () {
                    //Go to add game result page
                    Navigator.pop(context);
                    Map<int, int> opponentScores = {};
                    opponentScores[0] = playerTwoScore;
                    if (widget.selectedGameType == "4p") {
                      opponentScores[1] = playerFourScore;
                      opponentScores[2] = playerThreeScore;
                    }
                    if (widget.selectedGameType == "3p") {
                      opponentScores[1] = playerThreeScore;
                    }
                    nextScreen(
                        context,
                        AddGameResultPage(
                          userName: widget.userName,
                          groupId: selectedGroupId,
                          groupName: selectedGroupName,
                          myScore: playerOneScore,
                          opponentScores: opponentScores,
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Select Group"),
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
