import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/games_page.dart';
import 'package:group_scorecard/widgets/widgets.dart';

import '../service/database_service.dart';
import '../shared/constants.dart';

class GroupStatTile extends StatefulWidget {
  final String statName;
  final int statValue;
  final String statFilter;

  const GroupStatTile({
    super.key,
    required this.statName,
    required this.statValue,
    required this.statFilter,
  });

  @override
  State<GroupStatTile> createState() => _GroupStatTileState();
}

class _GroupStatTileState extends State<GroupStatTile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("statName: ${widget.statName}, statValue: ${widget.statValue}");
  }

  getEachFistLetterOfWords(String words) {
    String result = "";
    List<String> wordsList = words.split(" ");
    for (int i = 0; i < wordsList.length; i++) {
      result += wordsList[i].substring(0, 1).toUpperCase();
    }
    return result;
  }

  translateName(String name) {
    //Get the first letter that is capitalized
    int firstCapitalizedLetterIndex = findFirstCapitalizedLetter(name);

    //Split the name into two parts
    String firstPart = name.substring(0, firstCapitalizedLetterIndex);

    String secondPart = name.substring(firstCapitalizedLetterIndex);

    //Check if first part is in Constant.gameTypesMap
    if (Constants.gameTypesMap.containsKey(firstPart)) {
      return "${Constants.gameTypesMap[firstPart]} $secondPart";
    } else if (Constants.gameIdMap.containsKey(firstPart)) {
      return "${Constants.gameIdMap[firstPart]} $secondPart";
    } else {
      //Capitalize the first letter of first part
      firstPart = firstPart.substring(0, 1).toUpperCase() +
          firstPart.substring(1).toLowerCase();
      return "$firstPart $secondPart";
    }
  }

  int findFirstCapitalizedLetter(String str) {
    for (int i = 0; i < str.length; i++) {
      if (str[i] == str[i].toUpperCase()) {
        return i;
      }
    }
    return -1; // If no capitalized letter is found
  }

  @override
  Widget build(BuildContext context) {
    return translateName(widget.statName)
            .toLowerCase()
            .contains(widget.statFilter.toLowerCase())
        ? GestureDetector(
            onTap: () {
              // nextScreen(context,
              //     GamesPage(groupId: widget.groupId, groupName: widget.groupName));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: ListTile(
                  title: Text(translateName(widget.statName),
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
            ))
        : Container();
  }
}
