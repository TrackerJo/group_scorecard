import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/profile_page.dart';

import '../service/database_service.dart';
import '../shared/constants.dart';
import '../widgets/leaderboard_tile.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/widgets.dart';

class LeaderboardPage extends StatefulWidget {
  final String userName;
  final String email;
  final String groupId;
  final String groupName;

  const LeaderboardPage(
      {super.key,
      required this.userName,
      required this.email,
      required this.groupId,
      required this.groupName});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int currentPageIndex = 1;

  Stream? members;
  String stat = "totalWins";

  QuerySnapshot? games;
  List<Map<String, String>> filterInfo = [
    {"shown": "Total Wins", "value": "totalWins"},
    {"shown": "Total Losses", "value": "totalLosses"}
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersStats();
    getGamesFromDB();
    getGameTypes();
  }

  getGameTypes() {
    //Loop through all the game types
    for (var game in Constants.gameTypes) {
      //Get the game id
      String gameId = game["id"].toString();
      //Get the game name
      String gameName = game["value"].toString();
      var gameTypeWin = {
        "shown": "${gameName} Wins",
        "value": "${gameId}Wins",
      };
      var gameTypeLoss = {
        "shown": "${gameName} Losses",
        "value": "${gameId}Losses",
      };

      //Add the game type to the list
      filterInfo.add(gameTypeWin);
      filterInfo.add(gameTypeLoss);
    }
  }

  getGamesFromDB() async {
    await DatabaseService().getGames().then((val) {
      setState(() {
        games = val;
      });
      getGames();
    });
  }

  getGames() {
    for (int i = 0; i < games!.docs.length; i++) {
      setState(() {
        var gameWin = {
          "shown": "${games!.docs[i]["Name"].toString()} Wins",
          "value": "${games!.docs[i]["id"].toString()}Wins",
        };

        var gameLoss = {
          "shown": "${games!.docs[i]["Name"].toString()} Losses",
          "value": "${games!.docs[i]["id"].toString()}Losses",
        };

        filterInfo.add(gameWin);
        filterInfo.add(gameLoss);
      });
    }
  }

  getMembersStats() async {
    //Getting list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getMembersSortedByStat(widget.groupId, widget.groupName, stat)
        .then((val) {
      setState(() {
        members = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Leaderboard",
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
                        userName: widget.userName,
                        email: widget.email,
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
          userName: widget.userName,
          email: widget.email,
          currentPageIndex: currentPageIndex,
          groupId: widget.groupId,
          groupName: widget.groupName),
      body: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("Sort by:"),
        DropdownButtonFormField(
            value: stat,
            decoration: textInputDecoration.copyWith(
              labelText: "Stat",
              prefixIcon: Icon(
                Icons.leaderboard,
                color: Theme.of(context).primaryColor,
              ),
            ),
            items: filterInfo.map((Map<String, String> value) {
              return DropdownMenuItem<String>(
                value:
                    "${value['value']}", //value is the id of the game in the database
                alignment: Alignment.center,
                child: Text(value['shown'].toString()),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                stat = val.toString();
                getMembersStats();
              });
            }),
        membersList(),
      ]),
    );
  }

  membersList() {
    return StreamBuilder(
      stream: members,
      builder: (context, AsyncSnapshot snapshot) {
        //Make checks
        if (snapshot.hasData) {
          if (snapshot.data.docs.length != null) {
            if (snapshot.data.docs.length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return LeaderboardTile(
                      userName: snapshot.data.docs[index]["userName"],
                      statName: stat,
                      statValue: snapshot.data.docs[index][stat],
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      userId: snapshot.data.docs[index]["uid"],
                    );
                  });
            } else {
              return const Center(
                child: Text(
                  "No members yet",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            }
          } else {
            return const Center(
              child: Text(
                "No members yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
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
}

class _JsonQueryDocumentSnapshot {
  final Map<String, dynamic> data;

  _JsonQueryDocumentSnapshot({required this.data});

  factory _JsonQueryDocumentSnapshot.fromJson(Map<String, dynamic> json) {
    return _JsonQueryDocumentSnapshot(data: json);
  }

  dynamic operator [](String key) => data[key];
}
