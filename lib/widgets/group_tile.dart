import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/games_page.dart';
import 'package:group_scorecard/widgets/widgets.dart';

import '../service/database_service.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  const GroupTile({
    super.key,
    required this.userName,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getClassData();
  }

  getClassData() async {}

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
        nextScreen(context,
            GamesPage(groupId: widget.groupId, groupName: widget.groupName));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(getEachFistLetterOfWords(widget.groupName),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 25)),
          ),
          title: Text(widget.groupName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
