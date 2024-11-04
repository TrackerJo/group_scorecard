import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_scorecard/helper/helper_function.dart';
import 'package:group_scorecard/pages/add_game_result.dart';
import 'package:group_scorecard/pages/profile_page.dart';
import 'package:group_scorecard/service/database_service.dart';
import 'package:group_scorecard/widgets/game_result_tile.dart';
import 'package:group_scorecard/widgets/navigation_bar.dart';
import 'package:group_scorecard/widgets/view_which_games_tile.dart';
import 'package:group_scorecard/widgets/widgets.dart';
import 'package:intl/intl.dart';

import '../widgets/limit_range.dart';

class GamesPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GamesPage({super.key, required this.groupId, required this.groupName});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String userName = "";
  String email = "";

  int currentPageIndex = 0;
  bool _isLoading = false;
  Stream? personalGameResults;
  QuerySnapshot? groupGameResults;
  List<Widget> groupGameResultsWidgets = [];

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
  bool viewGroupGames = false;

  //Game Result Variables
  int myScore = -1;
  String teammateName = "";
  Map<int, String> opponentNames = {};
  Map<int, int> opponentScores = {};
  String winner = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserSFData();
    getGamesFromDB();
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

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups(FirebaseAuth.instance.currentUser!.uid)
        .then((snapshot) {
      setState(() {
        personalGameResults = snapshot;
      });
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupGameResults(widget.groupId)
        .then((snapshot) {
      setState(() {
        groupGameResults = snapshot;
      });
      createGroupGameResultsWidgets();
    });
  }

  createGroupGameResultsWidgets() {
    List<Widget> gameResultsWidgets = [];
    for (int i = 0; i < groupGameResults!.docs.length; i++) {
      gameResultsWidgets.add(GameResultTile(
        isOwnGame: false,
        gameResultId: groupGameResults!.docs[i]["gameResultId"].toString(),
        gameName: groupGameResults!.docs[i]["gameName"].toString(),
        gameDate: groupGameResults!.docs[i]["gameDate"].toString(),
        groupId: widget.groupId,
        isWinner: false,
      ));
    }
    //Sort the list by date, format is MM/dd/yyyy hh:mm a (e.g. 01/01/2021 12:00 PM)
    // gameResultsWidgets.sort((a, b) {
    //   DateTime aDate = DateFormat("M/d/yyyy h:mm a")
    //       .parse((a as GameResultTile).gameDate.toString());
    //   DateTime bDate = DateFormat("M/d/yyyy h:mm a")
    //       .parse((b as GameResultTile).gameDate.toString());
    //   return bDate.compareTo(aDate);
    // });

    setState(() {
      groupGameResultsWidgets = gameResultsWidgets;
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

  getUserSFData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  String getId(String res) {
    List<String> id = res.split("_");
    return id[0];
  }

  String getName(String res) {
    List<String> name = res.split("_");
    return name[1];
  }

  String getGameDate(String res) {
    List<String> date = res.split("_");
    return date[2];
  }

  String getIsWinner(String res) {
    List<String> isWinner = res.split("_");
    return isWinner[3];
  }

  getGameResultData(String resultId) async {
    String resultData = "";
    await DatabaseService()
        .getGameResultData(resultId, widget.groupId)
        .then((val) {
      setState(() {
        resultData = val;
      });
    });
    return resultData;
  }

  switchViewGroupGames() {
    setState(() {
      viewGroupGames = !viewGroupGames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Games",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () {
                  nextScreen(
                      context,
                      ProfilePage(
                        userName: userName,
                        email: email,
                        groupId: widget.groupId,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        getGroupStats: true,
                      ));
                },
                icon: const Icon(
                  Icons.account_circle,
                  size: 35,
                )),
          )
        ],
      ),
      bottomNavigationBar: GroupNavBar(
          userName: userName,
          email: email,
          currentPageIndex: currentPageIndex,
          groupId: widget.groupId,
          groupName: widget.groupName),
      body: Column(mainAxisSize: MainAxisSize.max, children: [
        ViewWhichGamesTile(
          viewGroupGames: viewGroupGames,
          switchViewGroupGames: switchViewGroupGames,
        ),
        if (!viewGroupGames) personalGamesList(),
        if (viewGroupGames)
          Expanded(child: ListView(children: groupGameResultsWidgets))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // popUpDialog(context);
          nextScreen(
              context,
              AddGameResultPage(
                groupId: widget.groupId,
                groupName: widget.groupName,
                userName: userName,
              ));
        },
        child: const Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  personalGamesList() {
    return StreamBuilder(
      stream: personalGameResults,
      builder: (context, AsyncSnapshot snapshot) {
        //Make checks
        if (snapshot.hasData) {
          if (snapshot.data["games"].length != null) {
            if (snapshot.data["games"].length != 0) {
              return SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: ListView.builder(
                    clipBehavior: Clip.hardEdge,
                    itemCount: snapshot.data["games"].length,
                    itemBuilder: (context, index) {
                      int reverseIndex =
                          snapshot.data["games"].length - index - 1;

                      // bool isWinner = false;
                      // DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                      //     .getIsWinner(
                      //         getId(snapshot.data["games"][reverseIndex]),
                      //         widget.groupId,
                      //         userName)
                      //     .then((value) {
                      //   setState(() {
                      //     isWinner = value;
                      //   });
                      // });

                      return Dismissible(
                          dragStartBehavior: DragStartBehavior.down,
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const [
                                Icon(Icons.delete, color: Colors.white),
                              ],
                            ),
                          ),
                          onDismissed: (direction) async {
                            await DatabaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .removeResultFromUser(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    snapshot.data["games"][reverseIndex]);
                            await DatabaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .deleteGameResult(
                                    getId(snapshot.data["games"][reverseIndex]),
                                    widget.groupId,
                                    FirebaseAuth.instance.currentUser!.uid,
                                    snapshot.data["games"][reverseIndex]);

                            await DatabaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .getUserGroups(
                                    FirebaseAuth.instance.currentUser!.uid)
                                .then((snapshot) {
                              setState(() {
                                personalGameResults = snapshot;
                              });
                            });
                            setState(() {
                              snapshot.data["games"].removeAt(reverseIndex);
                            });
                          },
                          child: GameResultTile(
                            isOwnGame: true,
                            gameResultId:
                                getId(snapshot.data["games"][reverseIndex]),
                            gameName:
                                getName(snapshot.data["games"][reverseIndex]),
                            gameDate: getGameDate(
                                snapshot.data["games"][reverseIndex]),
                            groupId: widget.groupId,
                            isWinner: getIsWinner(
                                        snapshot.data["games"][reverseIndex]) ==
                                    "true"
                                ? true
                                : false,
                            //isWinner: isWinner
                          ));
                    }),
              );
            } else {
              return noGamesWidget();
            }
          } else {
            return noGamesWidget();
          }
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ));
        }
      },
    );
  }

  // joinClass() async {
  //   if (classCode != "") {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //         .joinClass(userName, classCode,
  //             FirebaseAuth.instance.currentUser!.uid, school, userType)
  //         .whenComplete(() {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop(context);
  //       showSnackBar(context, Colors.green, "Class joined successfully!");
  //     });
  //   } else {
  //     showSnackBar(context, Colors.red, "Please enter the class code!");
  //   }
  // }

  // createClass() {
  //   if (classCode != "") {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //         .createClass(userName, classCode,
  //             FirebaseAuth.instance.currentUser!.uid, school)
  //         .whenComplete(() {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop(context);
  //       showSnackBar(context, Colors.green, "Class created successfully!");
  //     });
  //   } else {
  //     showSnackBar(context, Colors.red, "Please enter a class name!");
  //   }
  // }

  // gamesList() {
  //   return StreamBuilder(
  //     stream: classes,
  //     builder: (context, AsyncSnapshot snapshot) {
  //       //Make checks
  //       if (snapshot.hasData) {
  //         if (snapshot.data["classes"].length != null) {
  //           if (snapshot.data["classes"].length != 0) {
  //             return ListView.builder(
  //                 itemCount: snapshot.data["classes"].length,
  //                 itemBuilder: (context, index) {
  //                   int reverseIndex =
  //                       snapshot.data["classes"].length - index - 1;
  //                   return ClassTile(
  //                       userName: snapshot.data["fullName"],
  //                       classId: getId(snapshot.data["classes"][reverseIndex]),
  //                       className:
  //                           getName(snapshot.data["classes"][reverseIndex]),
  //                       school: school);
  //                 });
  //           } else {
  //             return noGamesWidget();
  //           }
  //         } else {
  //           return noGamesWidget();
  //         }
  //       } else {
  //         return Center(
  //             child: CircularProgressIndicator(
  //           color: Theme.of(context).primaryColor,
  //         ));
  //       }
  //     },
  //   );
  // }

  noGamesWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              nextScreen(
                  context,
                  AddGameResultPage(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    userName: userName,
                  ));
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You've not add any game results, tap on the add icon to add a game result!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
