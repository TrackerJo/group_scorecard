import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/games_page.dart';
import 'package:group_scorecard/pages/profile_page.dart';
import 'package:group_scorecard/widgets/widgets.dart';

import '../service/database_service.dart';

class LeaderboardTile extends StatefulWidget {
  final String userName;
  final String statName;
  final int statValue;
  final String groupId;
  final String groupName;
  final String userId;

  const LeaderboardTile({
    super.key,
    required this.userName,
    required this.statName,
    required this.statValue,
    required this.groupId,
    required this.groupName,
    required this.userId,
  });

  @override
  State<LeaderboardTile> createState() => _LeaderboardTileState();
}

class _LeaderboardTileState extends State<LeaderboardTile> {
  bool isMember = false;

  Map<String, dynamic>? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfMember();
    getUserInfo();
  }

  checkIfMember() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .checkIfMember(widget.groupId, widget.groupName, widget.userId)
        .then((val) {
      setState(() {
        isMember = val;
      });
    });
  }

  getUserInfo() async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserInfo(widget.userId)
        .then((val) {
      setState(() {
        user = val;
      });
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
              ProfilePage(
                  userName: widget.userName,
                  email: user!['email'],
                  groupId: widget.groupId,
                  getGroupStats: true,
                  userId: widget.userId));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: ListTile(
              title: Text(widget.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(widget.statValue.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              )),
        ));
  }
}
