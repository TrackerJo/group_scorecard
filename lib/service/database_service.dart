import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../shared/constants.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //collection reference
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference gamesCollection =
      FirebaseFirestore.instance.collection("games");

  String generateRandomCode() {
    const String alphabet = 'abcdefghijklmnopqrstuvwxyz';
    final Random random = Random();
    String code = '';

    for (int i = 0; i < 4; i++) {
      final int randomIndex = random.nextInt(alphabet.length);
      code += alphabet[randomIndex];
    }

    return code;
  }

  //saving user data
  Future savingUserData(String fullName, String email) async {
    // Set user data in the database
    await userCollection.doc(uid).set({
      "fullName": fullName, // set the user's full name
      "email": email, // set the user's email
      "groups": [],
      "games": [],
      "totalWins": 0,
      "totalLosses": 0,

      "uid": uid, // set the user's uid
    });

    //Get all the different games
    QuerySnapshot games = await gamesCollection.get();

    //Loop through all the game types
    for (var game in Constants.gameTypes) {
      //Get the game id
      String gameId = game["id"].toString();

      //Set the game stats
      await userCollection
          .doc(uid)
          .update({"${gameId}Wins": 0, "${gameId}Losses": 0});
    }

    //Loop through all the games
    for (var game in games.docs) {
      //Get the game id
      String gameId = game["id"];

      //Set the game stats
      await userCollection
          .doc(uid)
          .update({"${gameId}Wins": 0, "${gameId}Losses": 0});
    }
  }

  //Getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //Get User Groups
  getUserGroups(String uid) async {
    return userCollection.doc(uid).snapshots();
  }

  //Create Group
  Future createGroup(String userName, String groupName, String id) async {
    //Create random 4 digit code
    String groupCode = generateRandomCode();

    DocumentReference groupDocRef = await groupCollection.add({
      "groupName": groupName,
      "admin": "${id}_${userName}",
      "members": [],
      "groupCode": groupCode,
      "groupId": "",
      "groupIcon": "",
      "gameStats": {},
    });

    //Updating groupId and teachers
    await groupDocRef.update({"groupId": groupDocRef.id});

    DocumentReference userDocRef = userCollection.doc(uid);

    await userDocRef.update({
      "groups": FieldValue.arrayUnion(["${groupDocRef.id}_$groupName"])
    });

    //Update members
    await groupDocRef.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"])
    });

    //Add doc to memberStats collection in group doc
    await groupDocRef.collection("membersStats").doc(uid).set({
      "userName": userName,
      "uid": uid,
      "totalWins": 0,
      "totalLosses": 0,
    });

    //Get all the different games
    QuerySnapshot games = await gamesCollection.get();

    //Loop through all the game types
    for (var game in Constants.gameTypes) {
      //Get the game id
      String gameId = game["id"].toString();

      //Set the game stats
      await groupDocRef
          .collection("membersStats")
          .doc(uid)
          .update({"${gameId}Wins": 0, "${gameId}Losses": 0});
    }

    //Loop through all the games
    for (var game in games.docs) {
      //Get the game id
      String gameId = game["id"];

      //Set the game stats
      await groupDocRef
          .collection("membersStats")
          .doc(uid)
          .update({"${gameId}Wins": 0, "${gameId}Losses": 0});
    }
  }

  Future joinGroup(String userName, String groupCode, String id) async {
    QuerySnapshot groupDoc =
        await groupCollection.where("groupCode", isEqualTo: groupCode).get();
    String groupId = groupDoc.docs[0]["groupId"];
    DocumentReference groupDocRef = groupCollection.doc(groupId);
    DocumentReference userDocRef = userCollection.doc(uid);

    //Get Class Data
    DocumentSnapshot groupData = await groupDocRef.get();
    String groupName = groupData["groupName"];

    //Updating class members and user data
    await groupDocRef.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"])
    });
    await userDocRef.update({
      "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
    });

    //Add doc to memberStats collection in group doc
    await groupDocRef.collection("membersStats").doc(uid).set({
      "userName": userName,
      "uid": uid,
      "totalWins": 0,
      "totalLosses": 0,
    });

    //Get all the different games
    QuerySnapshot games = await gamesCollection.get();

    //Loop through all the game types
    for (var game in Constants.gameTypes) {
      //Get the game id
      String gameId = game["id"].toString();

      //Set the game stats
      await groupDocRef
          .collection("membersStats")
          .doc(uid)
          .update({"${gameId}Wins": 0, "${gameId}Losses": 0});
    }

    //Loop through all the games
    for (var game in games.docs) {
      //Get the game id
      String gameId = game["id"];

      //Set the game stats
      await groupDocRef
          .collection("membersStats")
          .doc(uid)
          .update({"${gameId}Wins": 0, "${gameId}Losses": 0});
    }
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot groupDocSnapshot = await d.get();
    return groupDocSnapshot["admin"];
  }

  //Leave Group
  Future leaveGroup(
      String groupId, String userName, String groupName, String userId) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(userId);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentReference groupMemberStatsDocumentReference =
        groupCollection.doc(groupId).collection("membersStats").doc(userId);

    // delete member stats
    await groupMemberStatsDocumentReference.delete();

    // if user has our groups -> then remove then or also in other part re join

    await userDocumentReference.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayRemove(["${userId}_$userName"])
    });
  }

  //Get Group Members
  getGroupMembers(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //Get Admin Data
  getAdminData(String adminId) async {
    //Check if admin is a teacher or student
    DocumentSnapshot adminData = await userCollection.doc(adminId).get();
    return adminData;
  }

  //Get Group Code
  getGroupCode(String groupId) async {
    DocumentSnapshot groupData = await groupCollection.doc(groupId).get();
    return groupData["groupCode"];
  }

  getGroupData(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //Get Games
  Future<QuerySnapshot<Object?>> getGames() async {
    QuerySnapshot games = await gamesCollection.orderBy("Name").get();
    return games;
  }

  //Submit Game results
  Future addGameResult(
      String id, String groupId, Map<String, dynamic> gameResults) async {
    List<String> opponentNames = [];
    List<int> opponentScores = [];
    for (int i = 0; i < gameResults["opponentNames"].length; i++) {
      opponentNames.add(gameResults["opponentNames"][i]);
    }

    for (int i = 0; i < gameResults["opponentScores"].length; i++) {
      opponentScores.add(gameResults["opponentScores"][i]);
    }

    DocumentReference gameDocRef =
        await groupCollection.doc(groupId).collection("gameResults").add({
      "gameSubmitterName": gameResults["myName"],
      "gameSubmitterScore": gameResults["myScore"],
      "teammateName": gameResults["teammateName"],
      "opponentNames": opponentNames,
      "opponentScores": opponentScores,
      "gameWinner": gameResults["winner"],
      "gameType": gameResults["gameType"],
      "gameName": gameResults["gameName"],
      "gameDate": gameResults["gameDate"],
      "gameId": gameResults["gameId"],
    });

    bool isWinner = false;

    //Check if is winner
    if (gameResults["winner"].contains(gameResults["myName"])) isWinner = true;

    //Updating groupId and teachers
    await gameDocRef.update({"gameResultId": gameDocRef.id});

    DocumentReference userDocRef = userCollection.doc(id);

    DocumentSnapshot userStats = await userDocRef.get();
    DocumentReference groupMemberRef =
        groupCollection.doc(groupId).collection("membersStats").doc(id);
    DocumentSnapshot groupMembersStats = await groupMemberRef.get();

    int allTotalWins = userStats["totalWins"];
    int allTotalLosses = userStats["totalLosses"];
    int allTypeWins = userStats["${gameResults["gameType"]}Wins"];
    int allTypeLosses = userStats["${gameResults["gameType"]}Losses"];
    int allGameWins = userStats["${gameResults["gameId"]}Wins"];
    int allGameLosses = userStats["${gameResults["gameId"]}Losses"];

    int groupTotalWins = groupMembersStats["totalWins"];
    int groupTotalLosses = groupMembersStats["totalLosses"];
    int groupTypeWins = groupMembersStats["${gameResults["gameType"]}Wins"];
    int groupTypeLosses = groupMembersStats["${gameResults["gameType"]}Losses"];
    int groupGameWins = groupMembersStats["${gameResults["gameId"]}Wins"];
    int groupGameLosses = groupMembersStats["${gameResults["gameId"]}Losses"];

    //Check if has teammate
    if (gameResults["teammateName"] != "") {
      String filteredWinner = gameResults["winner"].split("_")[0];
      //Check if teammate is a user
      QuerySnapshot teammateData = await userCollection
          .where("fullName", isEqualTo: gameResults["teammateName"])
          .get();
      if (teammateData.docs.length > 0) {
        DocumentReference teammateDocRef =
            userCollection.doc(teammateData.docs[0].id);
        DocumentSnapshot teammateStats = await teammateDocRef.get();
        DocumentSnapshot groupTeammateStats = await groupCollection
            .doc(groupId)
            .collection("membersStats")
            .doc(teammateData.docs[0].id)
            .get();

        int teammateTotalWins = teammateStats["totalWins"];
        int teammateTotalLosses = teammateStats["totalLosses"];
        int teammateTypeWins = teammateStats["${gameResults["gameType"]}Wins"];
        int teammateTypeLosses =
            teammateStats["${gameResults["gameType"]}Losses"];
        int teammateGameWins = teammateStats["${gameResults["gameId"]}Wins"];
        int teammateGameLosses =
            teammateStats["${gameResults["gameId"]}Losses"];

        int groupTeammateTotalWins = groupTeammateStats["totalWins"];
        int groupTeammateTotalLosses = groupTeammateStats["totalLosses"];
        int groupTeammateTypeWins =
            groupTeammateStats["${gameResults["gameType"]}Wins"];
        int groupTeammateTypeLosses =
            groupTeammateStats["${gameResults["gameType"]}Losses"];
        int groupTeammateGameWins =
            groupTeammateStats["${gameResults["gameId"]}Wins"];
        int groupTeammateGameLosses =
            groupTeammateStats["${gameResults["gameId"]}Losses"];

        if (filteredWinner == gameResults["myName"]) {
          teammateTotalWins = teammateTotalWins + 1;
          teammateTypeWins = teammateTypeWins + 1;
          teammateGameWins = teammateGameWins + 1;

          groupTeammateTotalWins = groupTeammateTotalWins + 1;
          groupTeammateTypeWins = groupTeammateTypeWins + 1;
          groupTeammateGameWins = groupTeammateGameWins + 1;
        } else {
          teammateTotalLosses = teammateTotalLosses + 1;
          teammateTypeLosses = teammateTypeLosses + 1;
          teammateGameLosses = teammateGameLosses + 1;

          groupTeammateTotalLosses = groupTeammateTotalLosses + 1;
          groupTeammateTypeLosses = groupTeammateTypeLosses + 1;
          groupTeammateGameLosses = groupTeammateGameLosses + 1;
        }
        await teammateDocRef.update({
          "totalWins": teammateTotalWins,
          "totalLosses": teammateTotalLosses,
          "${gameResults["gameType"]}Wins": teammateTypeWins,
          "${gameResults["gameType"]}Losses": teammateTypeLosses,
          "${gameResults["gameId"]}Wins": teammateGameWins,
          "${gameResults["gameId"]}Losses": teammateGameLosses,
        });

        await groupCollection
            .doc(groupId)
            .collection("membersStats")
            .doc(teammateData.docs[0].id)
            .update({
          "totalWins": groupTeammateTotalWins,
          "totalLosses": groupTeammateTotalLosses,
          "${gameResults["gameType"]}Wins": groupTeammateTypeWins,
          "${gameResults["gameType"]}Losses": groupTeammateTypeLosses,
          "${gameResults["gameId"]}Wins": groupTeammateGameWins,
          "${gameResults["gameId"]}Losses": groupTeammateGameLosses,
        });
      }

      //Check if user won or lost
      if (filteredWinner == gameResults["myName"]) {
        allTotalWins = allTotalWins + 1;
        allTypeWins = allTypeWins + 1;
        allGameWins = allGameWins + 1;

        groupTotalWins = groupTotalWins + 1;
        groupTypeWins = groupTypeWins + 1;
        groupGameWins = groupGameWins + 1;
      } else {
        allTotalLosses = allTotalLosses + 1;
        allTypeLosses = allTypeLosses + 1;
        allGameLosses = allGameLosses + 1;

        groupTotalLosses = groupTotalLosses + 1;
        groupTypeLosses = groupTypeLosses + 1;
        groupGameLosses = groupGameLosses + 1;
      }

      await userDocRef.update({
        "totalWins": allTotalWins,
        "totalLosses": allTotalLosses,
        "${gameResults["gameType"]}Wins": allTypeWins,
        "${gameResults["gameType"]}Losses": allTypeLosses,
        "${gameResults["gameId"]}Wins": allGameWins,
        "${gameResults["gameId"]}Losses": allGameLosses,
      });

      await groupMemberRef.update({
        "totalWins": groupTotalWins,
        "totalLosses": groupTotalLosses,
        "${gameResults["gameType"]}Wins": groupTypeWins,
        "${gameResults["gameType"]}Losses": groupTypeLosses,
        "${gameResults["gameId"]}Wins": groupGameWins,
        "${gameResults["gameId"]}Losses": groupGameLosses,
      });
    } else {
      //Check if user won or lost
      if (gameResults["winner"] == gameResults["myName"]) {
        //Check is user win stats has total wins and the game type

        allTotalWins = allTotalWins + 1;
        allTypeWins = allTypeWins + 1;
        allGameWins = allGameWins + 1;

        groupTotalWins = groupTotalWins + 1;
        groupTypeWins = groupTypeWins + 1;
        groupGameWins = groupGameWins + 1;
      } else {
        //Check is user win stats has total wins and the game type

        allTotalLosses = allTotalLosses + 1;
        allTypeLosses = allTypeLosses + 1;
        allGameLosses = allGameLosses + 1;

        groupTotalLosses = groupTotalLosses + 1;
        groupTypeLosses = groupTypeLosses + 1;
        groupGameLosses = groupGameLosses + 1;
      }

      await userDocRef.update({
        "totalWins": allTotalWins,
        "totalLosses": allTotalLosses,
        "${gameResults["gameType"]}Wins": allTypeWins,
        "${gameResults["gameType"]}Losses": allTypeLosses,
        "${gameResults["gameId"]}Wins": allGameWins,
        "${gameResults["gameId"]}Losses": allGameLosses,
      });
      await groupMemberRef.update({
        "totalWins": groupTotalWins,
        "totalLosses": groupTotalLosses,
        "${gameResults["gameType"]}Wins": groupTypeWins,
        "${gameResults["gameType"]}Losses": groupTypeLosses,
        "${gameResults["gameId"]}Wins": groupGameWins,
        "${gameResults["gameId"]}Losses": groupGameLosses,
      });
    }

    //Run for each of the opponents
    for (int i = 0; i < gameResults["opponentNames"].length; i++) {
      //Check if opponent is a user
      QuerySnapshot opponentData = await userCollection
          .where("fullName", isEqualTo: gameResults["opponentNames"][i])
          .get();
      if (opponentData.docs.length > 0) {
        DocumentReference opponentDocRef =
            userCollection.doc(opponentData.docs[0].id);
        DocumentSnapshot oppStats = await opponentDocRef.get();

        DocumentReference groupOpponentRef = groupCollection
            .doc(groupId)
            .collection("membersStats")
            .doc(opponentData.docs[0].id);

        DocumentSnapshot groupOpponentStats = await groupOpponentRef.get();

        int oppTotalWins = oppStats["totalWins"];
        int oppTotalLosses = oppStats["totalLosses"];
        int oppTypeWins = oppStats["${gameResults["gameType"]}Wins"];
        int oppTypeLosses = oppStats["${gameResults["gameType"]}Losses"];
        int oppGameWins = oppStats["${gameResults["gameId"]}Wins"];
        int oppGameLosses = oppStats["${gameResults["gameId"]}Losses"];

        int groupOpponentTotalWins = groupOpponentStats["totalWins"];
        int groupOpponentTotalLosses = groupOpponentStats["totalLosses"];
        int groupOpponentTypeWins =
            groupOpponentStats["${gameResults["gameType"]}Wins"];
        int groupOpponentTypeLosses =
            groupOpponentStats["${gameResults["gameType"]}Losses"];

        int groupOpponentGameWins =
            groupOpponentStats["${gameResults["gameId"]}Wins"];
        int groupOpponentGameLosses =
            groupOpponentStats["${gameResults["gameId"]}Losses"];

        if (gameResults["winner"] == gameResults["opponentNames"][i]) {
          oppTotalWins = oppTotalWins + 1;
          oppTypeWins = oppTypeWins + 1;
          oppGameWins = oppGameWins + 1;

          groupOpponentTotalWins = groupOpponentTotalWins + 1;
          groupOpponentTypeWins = groupOpponentTypeWins + 1;
          groupOpponentGameWins = groupOpponentGameWins + 1;
        } else {
          oppTotalLosses = oppTotalLosses + 1;
          oppTypeLosses = oppTypeLosses + 1;
          oppGameLosses = oppGameLosses + 1;

          groupOpponentTotalLosses = groupOpponentTotalLosses + 1;
          groupOpponentTypeLosses = groupOpponentTypeLosses + 1;
          groupOpponentGameLosses = groupOpponentGameLosses + 1;
        }
        await opponentDocRef.update({
          "totalWins": oppTotalWins,
          "totalLosses": oppTotalLosses,
          "${gameResults["gameType"]}Wins": oppTypeWins,
          "${gameResults["gameType"]}Losses": oppTypeLosses,
          "${gameResults["gameId"]}Wins": oppGameWins,
          "${gameResults["gameId"]}Losses": oppGameLosses,
        });

        await groupOpponentRef.update({
          "totalWins": groupOpponentTotalWins,
          "totalLosses": groupOpponentTotalLosses,
          "${gameResults["gameType"]}Wins": groupOpponentTypeWins,
          "${gameResults["gameType"]}Losses": groupOpponentTypeLosses,
          "${gameResults["gameId"]}Wins": groupOpponentGameWins,
          "${gameResults["gameId"]}Losses": groupOpponentGameLosses,
        });
      }
    }

    //Update Group Games Stats
    DocumentReference groupDocRef = groupCollection.doc(groupId);

    Map<String, dynamic> groupGameStats =
        (await groupDocRef.get())["gameStats"];

    if (groupGameStats["totalGames"] == null) {
      groupGameStats["totalGames"] = 0;
    }

    if (groupGameStats["${gameResults["gameType"]}Games"] == null) {
      groupGameStats["${gameResults["gameType"]}Games"] = 0;
    }

    if (groupGameStats["${gameResults["gameId"]}Games"] == null) {
      groupGameStats["${gameResults["gameId"]}Games"] = 0;
    }

    groupGameStats["totalGames"] = groupGameStats["totalGames"] + 1;
    groupGameStats["${gameResults["gameType"]}Games"] =
        groupGameStats["${gameResults["gameType"]}Games"] + 1;
    groupGameStats["${gameResults["gameId"]}Games"] =
        groupGameStats["${gameResults["gameId"]}Games"] + 1;

    await groupDocRef.update({"gameStats": groupGameStats});

    await userDocRef.update({
      "games": FieldValue.arrayUnion([
        "${gameDocRef.id}_${gameResults["gameName"]}_ ${gameResults["gameDate"]}_${isWinner}"
      ])
    });
  }

  //Getting user game results
  Future getUserGameResults(String userName) async {
    QuerySnapshot snapshot = await userCollection
        .where("gameSubmitterName", isEqualTo: userName)
        .get();
    return snapshot;
  }

  //Get User Data
  getUserData(String userId) async {
    return await userCollection.doc(userId).get();
  }

  //Delete Game Result
  deleteGameResult(String gameResultId, String groupId, String userId,
      String gameResultFullId) async {
    DocumentReference gameResultRef = groupCollection
        .doc(groupId)
        .collection("gameResults")
        .doc(gameResultId);

    Map<String, dynamic> gameResults = await getGameResultsData(gameResultRef);

    //Delete Game from User
    DocumentReference userDocRef = userCollection.doc(userId);

    await userDocRef.update({
      "games": FieldValue.arrayRemove([gameResultFullId])
    });

    DocumentSnapshot userStats = await userDocRef.get();
    DocumentReference groupMemberRef =
        groupCollection.doc(groupId).collection("membersStats").doc(userId);
    DocumentSnapshot groupMembersStats = await groupMemberRef.get();

    int allTotalWins = userStats["totalWins"];
    int allTotalLosses = userStats["totalLosses"];
    int allTypeWins = userStats["${gameResults["gameType"]}Wins"];
    int allTypeLosses = userStats["${gameResults["gameType"]}Losses"];
    int allGameWins = userStats["${gameResults["gameId"]}Wins"];
    int allGameLosses = userStats["${gameResults["gameId"]}Losses"];

    int groupTotalWins = groupMembersStats["totalWins"];
    int groupTotalLosses = groupMembersStats["totalLosses"];
    int groupTypeWins = groupMembersStats["${gameResults["gameType"]}Wins"];
    int groupTypeLosses = groupMembersStats["${gameResults["gameType"]}Losses"];
    int groupGameWins = groupMembersStats["${gameResults["gameId"]}Wins"];
    int groupGameLosses = groupMembersStats["${gameResults["gameId"]}Losses"];

    //Check if has teammate
    if (gameResults["teammateName"] != "") {
      String filteredWinner = gameResults["winner"].split("_")[0];
      //Check if teammate is a user
      QuerySnapshot teammateData = await userCollection
          .where("fullName", isEqualTo: gameResults["teammateName"])
          .get();
      if (teammateData.docs.length > 0) {
        DocumentReference teammateDocRef =
            userCollection.doc(teammateData.docs[0].id);
        DocumentSnapshot teammateStats = await teammateDocRef.get();
        DocumentSnapshot groupTeammateStats = await groupCollection
            .doc(groupId)
            .collection("membersStats")
            .doc(teammateData.docs[0].id)
            .get();

        int teammateTotalWins = teammateStats["totalWins"];
        int teammateTotalLosses = teammateStats["totalLosses"];
        int teammateTypeWins = teammateStats["${gameResults["gameType"]}Wins"];
        int teammateTypeLosses =
            teammateStats["${gameResults["gameType"]}Losses"];
        int teammateGameWins = teammateStats["${gameResults["gameId"]}Wins"];
        int teammateGameLosses =
            teammateStats["${gameResults["gameId"]}Losses"];

        int groupTeammateTotalWins = groupTeammateStats["totalWins"];
        int groupTeammateTotalLosses = groupTeammateStats["totalLosses"];
        int groupTeammateTypeWins =
            groupTeammateStats["${gameResults["gameType"]}Wins"];
        int groupTeammateTypeLosses =
            groupTeammateStats["${gameResults["gameType"]}Losses"];
        int groupTeammateGameWins =
            groupTeammateStats["${gameResults["gameId"]}Wins"];
        int groupTeammateGameLosses =
            groupTeammateStats["${gameResults["gameId"]}Losses"];

        if (filteredWinner == gameResults["myName"]) {
          teammateTotalWins = teammateTotalWins - 1;
          teammateTypeWins = teammateTypeWins - 1;
          teammateGameWins = teammateGameWins - 1;

          groupTeammateTotalWins = groupTeammateTotalWins - 1;
          groupTeammateTypeWins = groupTeammateTypeWins - 1;
          groupTeammateGameWins = groupTeammateGameWins - 1;
        } else {
          teammateTotalLosses = teammateTotalLosses - 1;
          teammateTypeLosses = teammateTypeLosses - 1;
          teammateGameLosses = teammateGameLosses - 1;

          groupTeammateTotalLosses = groupTeammateTotalLosses - 1;
          groupTeammateTypeLosses = groupTeammateTypeLosses - 1;
          groupTeammateGameLosses = groupTeammateGameLosses - 1;
        }
        await teammateDocRef.update({
          "totalWins": teammateTotalWins,
          "totalLosses": teammateTotalLosses,
          "${gameResults["gameType"]}Wins": teammateTypeWins,
          "${gameResults["gameType"]}Losses": teammateTypeLosses,
          "${gameResults["gameId"]}Wins": teammateGameWins,
          "${gameResults["gameId"]}Losses": teammateGameLosses,
        });

        await groupCollection
            .doc(groupId)
            .collection("membersStats")
            .doc(teammateData.docs[0].id)
            .update({
          "totalWins": groupTeammateTotalWins,
          "totalLosses": groupTeammateTotalLosses,
          "${gameResults["gameType"]}Wins": groupTeammateTypeWins,
          "${gameResults["gameType"]}Losses": groupTeammateTypeLosses,
          "${gameResults["gameId"]}Wins": groupTeammateGameWins,
          "${gameResults["gameId"]}Losses": groupTeammateGameLosses,
        });
      }

      //Check if user won or lost
      if (filteredWinner == gameResults["myName"]) {
        allTotalWins = allTotalWins - 1;
        allTypeWins = allTypeWins - 1;
        allGameWins = allGameWins - 1;

        groupTotalWins = groupTotalWins - 1;
        groupTypeWins = groupTypeWins - 1;
        groupGameWins = groupGameWins - 1;
      } else {
        allTotalLosses = allTotalLosses - 1;
        allTypeLosses = allTypeLosses - 1;
        allGameLosses = allGameLosses - 1;

        groupTotalLosses = groupTotalLosses - 1;
        groupTypeLosses = groupTypeLosses - 1;
        groupGameLosses = groupGameLosses - 1;
      }

      await userDocRef.update({
        "totalWins": allTotalWins,
        "totalLosses": allTotalLosses,
        "${gameResults["gameType"]}Wins": allTypeWins,
        "${gameResults["gameType"]}Losses": allTypeLosses,
        "${gameResults["gameId"]}Wins": allGameWins,
        "${gameResults["gameId"]}Losses": allGameLosses,
      });

      await groupMemberRef.update({
        "totalWins": groupTotalWins,
        "totalLosses": groupTotalLosses,
        "${gameResults["gameType"]}Wins": groupTypeWins,
        "${gameResults["gameType"]}Losses": groupTypeLosses,
        "${gameResults["gameId"]}Wins": groupGameWins,
        "${gameResults["gameId"]}Losses": groupGameLosses,
      });
    } else {
      //Check if user won or lost
      if (gameResults["winner"] == gameResults["myName"]) {
        //Check is user win stats has total wins and the game type

        allTotalWins = allTotalWins - 1;
        allTypeWins = allTypeWins - 1;
        allGameWins = allGameWins - 1;

        groupTotalWins = groupTotalWins - 1;
        groupTypeWins = groupTypeWins - 1;
        groupGameWins = groupGameWins - 1;
      } else {
        //Check is user win stats has total wins and the game type

        allTotalLosses = allTotalLosses - 1;
        allTypeLosses = allTypeLosses - 1;
        allGameLosses = allGameLosses - 1;

        groupTotalLosses = groupTotalLosses - 1;
        groupTypeLosses = groupTypeLosses - 1;
        groupGameLosses = groupGameLosses - 1;
      }

      await userDocRef.update({
        "totalWins": allTotalWins,
        "totalLosses": allTotalLosses,
        "${gameResults["gameType"]}Wins": allTypeWins,
        "${gameResults["gameType"]}Losses": allTypeLosses,
        "${gameResults["gameId"]}Wins": allGameWins,
        "${gameResults["gameId"]}Losses": allGameLosses,
      });
      await groupMemberRef.update({
        "totalWins": groupTotalWins,
        "totalLosses": groupTotalLosses,
        "${gameResults["gameType"]}Wins": groupTypeWins,
        "${gameResults["gameType"]}Losses": groupTypeLosses,
        "${gameResults["gameId"]}Wins": groupGameWins,
        "${gameResults["gameId"]}Losses": groupGameLosses,
      });
    }

    //Run for each of the opponents
    for (int i = 0; i < gameResults["opponentNames"].length; i++) {
      //Check if opponent is a user
      QuerySnapshot opponentData = await userCollection
          .where("fullName", isEqualTo: gameResults["opponentNames"][i])
          .get();
      if (opponentData.docs.length > 0) {
        DocumentReference opponentDocRef =
            userCollection.doc(opponentData.docs[0].id);
        DocumentSnapshot oppStats = await opponentDocRef.get();

        DocumentReference groupOpponentRef = groupCollection
            .doc(groupId)
            .collection("membersStats")
            .doc(opponentData.docs[0].id);

        DocumentSnapshot groupOpponentStats = await groupOpponentRef.get();

        int oppTotalWins = oppStats["totalWins"];
        int oppTotalLosses = oppStats["totalLosses"];
        int oppTypeWins = oppStats["${gameResults["gameType"]}Wins"];
        int oppTypeLosses = oppStats["${gameResults["gameType"]}Losses"];
        int oppGameWins = oppStats["${gameResults["gameId"]}Wins"];
        int oppGameLosses = oppStats["${gameResults["gameId"]}Losses"];

        int groupOpponentTotalWins = groupOpponentStats["totalWins"];
        int groupOpponentTotalLosses = groupOpponentStats["totalLosses"];
        int groupOpponentTypeWins =
            groupOpponentStats["${gameResults["gameType"]}Wins"];
        int groupOpponentTypeLosses =
            groupOpponentStats["${gameResults["gameType"]}Losses"];
        int groupOpponentGameWins =
            groupOpponentStats["${gameResults["gameId"]}Wins"];
        int groupOpponentGameLosses =
            groupOpponentStats["${gameResults["gameId"]}Losses"];

        if (gameResults["winner"] == gameResults["opponentNames"][i]) {
          oppTotalWins = oppTotalWins - 1;
          oppTypeWins = oppTypeWins - 1;
          oppGameWins = oppGameWins - 1;

          groupOpponentTotalWins = groupOpponentTotalWins - 1;
          groupOpponentTypeWins = groupOpponentTypeWins - 1;
          groupOpponentGameWins = groupOpponentGameWins - 1;
        } else {
          oppTotalLosses = oppTotalLosses - 1;
          oppTypeLosses = oppTypeLosses - 1;
          oppGameLosses = oppGameLosses - 1;

          groupOpponentTotalLosses = groupOpponentTotalLosses - 1;
          groupOpponentTypeLosses = groupOpponentTypeLosses - 1;
          groupOpponentGameLosses = groupOpponentGameLosses - 1;
        }
        await opponentDocRef.update({
          "totalWins": oppTotalWins,
          "totalLosses": oppTotalLosses,
          "${gameResults["gameType"]}Wins": oppTypeWins,
          "${gameResults["gameType"]}Losses": oppTypeLosses,
          "${gameResults["gameId"]}Wins": oppGameWins,
          "${gameResults["gameId"]}Losses": oppGameLosses,
        });

        await groupOpponentRef.update({
          "totalWins": groupOpponentTotalWins,
          "totalLosses": groupOpponentTotalLosses,
          "${gameResults["gameType"]}Wins": groupOpponentTypeWins,
          "${gameResults["gameType"]}Losses": groupOpponentTypeLosses,
          "${gameResults["gameId"]}Wins": groupOpponentGameWins,
          "${gameResults["gameId"]}Losses": groupOpponentGameLosses,
        });
      }
    }
    //Update Group Games Stats
    DocumentReference groupDocRef = groupCollection.doc(groupId);
    Map<String, dynamic> groupGameStats =
        (await groupDocRef.get())["gameStats"];

    if (groupGameStats["totalGames"] == null) {
      groupGameStats["totalGames"] = 0;
    }

    if (groupGameStats["${gameResults["gameType"]}Games"] == null) {
      groupGameStats["${gameResults["gameType"]}Games"] = 0;
    }

    if (groupGameStats["${gameResults["gameId"]}Games"] == null) {
      groupGameStats["${gameResults["gameId"]}Games"] = 1;
    }

    groupGameStats["totalGames"] = groupGameStats["totalGames"] - 1;
    groupGameStats["${gameResults["gameType"]}Games"] =
        groupGameStats["${gameResults["gameType"]}Games"] - 1;
    groupGameStats["${gameResults["gameId"]}Games"] =
        groupGameStats["${gameResults["gameId"]}Games"] - 1;

    await groupDocRef.update({"gameStats": groupGameStats});
    //Delete Game Result
    await gameResultRef.delete();
  }

  removeResultFromUser(String userId, String gameResultId) async {
    DocumentReference userDocRef = userCollection.doc(userId);
    await userDocRef.update({
      "games": FieldValue.arrayRemove([gameResultId])
    });
  }

  removeRestOfGameResults(gameResults, DocumentReference gameResultRef,
      String userId, String gameResultId, String groupId) async {}

  //Write a function that gets the game results doc and returns all the data to a Map<String, dynamic>
  Future<Map<String, dynamic>> getGameResultsData(
      DocumentReference gameResultRef) async {
    Map<String, dynamic> gameResults = {};
    DocumentSnapshot gameResultsDoc = await gameResultRef.get();
    gameResults["gameSubmitterName"] = gameResultsDoc["gameSubmitterName"];
    gameResults["gameSubmitterScore"] = gameResultsDoc["gameSubmitterScore"];

    gameResults["teammateName"] = gameResultsDoc["teammateName"];
    gameResults["opponentNames"] = gameResultsDoc["opponentNames"];
    gameResults["opponentScores"] = gameResultsDoc["opponentScores"];
    gameResults["winner"] = gameResultsDoc["gameWinner"];
    gameResults["gameType"] = gameResultsDoc["gameType"];
    gameResults["gameName"] = gameResultsDoc["gameName"];
    gameResults["gameDate"] = gameResultsDoc["gameDate"];
    gameResults["gameId"] = gameResultsDoc["gameId"];

    return gameResults;
  }

  getGameResultData(String gameResultId, String groupId) async {
    DocumentReference gameResultRef = groupCollection
        .doc(groupId)
        .collection("gameResults")
        .doc(gameResultId);
    DocumentSnapshot gameResultDoc = await gameResultRef.get();
    return gameResultDoc.data();
  }

  getIsWinner(String gameResultId, String groupId, String userName) async {
    DocumentReference gameResultRef = groupCollection
        .doc(groupId)
        .collection("gameResults")
        .doc(gameResultId);
    DocumentSnapshot gameResultDoc = await gameResultRef.get();
    if (gameResultDoc["gameWinner"].contains(userName)) {
      return true;
    } else {
      return false;
    }
  }

  //Get All members in group and sort by given stat in gameStats
  getMembersSortedByStat(
      String groupId, String groupName, String statToSort) async {
    //Get all user from group in userCollection where groups array contains groupId
    print("${groupId}_$groupName");

    return groupCollection
        .doc(groupId)
        .collection("membersStats")
        .orderBy(statToSort, descending: true)
        .snapshots();
  }

  checkIfMember(String groupId, String groupName, String userId) async {
    //Get User doc
    //Check if groups array contains groupId
    //If so return true
    //If not return false
    print("${groupId}_$groupName");
    DocumentSnapshot userDoc = await userCollection.doc(userId).get();
    if (userDoc["groups"].contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  getGroupStats(String groupId) async {
    print(groupId);
    DocumentSnapshot groupDoc = await groupCollection.doc(groupId).get();
    Object groupStats = groupDoc["gameStats"];
    Map<String, dynamic> groupStatsMap = objectToMap(groupStats);
    //Turn groupStats to a List<Map<String, dynamic>>
    List<Map<String, dynamic>> groupStatsList = [];
    groupStatsMap.forEach((key, value) {
      groupStatsList.add({"statName": key, "statValue": value});
    });

    return groupStatsList;
  }

  Map<String, dynamic> objectToMap(dynamic object) {
    if (object is Map<String, dynamic>) {
      return object;
    } else {
      return object.toJson();
    }
  }

  getUserInfo(String userId) async {
    DocumentSnapshot userDoc = await userCollection.doc(userId).get();
    Object? userObj = userDoc.data();
    Map<String, dynamic> userMap = objectToMap(userObj);
    return userMap;
  }

  getGroupUserStats(String groupId, String userId) async {
    DocumentSnapshot groupUserDoc = await groupCollection
        .doc(groupId)
        .collection("membersStats")
        .doc(userId)
        .get();
    Object? memberStats = groupUserDoc.data();
    Map<String, dynamic> memberStatsMap = objectToMap(memberStats);
    print(memberStatsMap);
    //Remove uid and userName from memberStatsMap
    memberStatsMap.remove("uid");
    memberStatsMap.remove("userName");
    //Turn groupStats to a List<Map<String, dynamic>>
    List<Map<String, dynamic>> memberStatsList = [];
    memberStatsMap.forEach((key, value) {
      memberStatsList.add({"statName": key, "statValue": value});
    });

    print(memberStatsList);

    return memberStatsList;
  }

  getAllUserStats(String userId) async {
    DocumentSnapshot userDoc = await userCollection.doc(userId).get();
    Object? userStats = userDoc.data();
    Map<String, dynamic> userStatsMap = objectToMap(userStats);
    //Remove uid and userName from memberStatsMap
    userStatsMap.remove("uid");
    userStatsMap.remove("fullName");
    userStatsMap.remove("games");
    userStatsMap.remove("groups");
    userStatsMap.remove("email");
    //Turn groupStats to a List<Map<String, dynamic>>
    List<Map<String, dynamic>> userStatsList = [];
    userStatsMap.forEach((key, value) {
      userStatsList.add({"statName": key, "statValue": value});
    });

    return userStatsList;
  }

  addNewGame(String gameName, String gameId, String gameType,
      String NumOfPlayers) async {
    //Add new game to games collection
    await gamesCollection.add({
      "Name": gameName,
      "id": gameId,
      "Type": gameType,
      "NumOfPlayers": NumOfPlayers
    });

    //Loop through all of the users
    //Add new game to each user's doc
    QuerySnapshot users = await userCollection.get();
    users.docs.forEach((user) async {
      print(user.id);
      await userCollection.doc(user.id).set(
          {"${gameId}Wins": 0, "${gameId}Losses": 0}, SetOptions(merge: true));
    });

    //Loop through all of the groups members stats
    //Add new game to each group member's doc
    QuerySnapshot groups = await groupCollection.get();
    groups.docs.forEach((group) async {
      QuerySnapshot members =
          await groupCollection.doc(group.id).collection("membersStats").get();
      members.docs.forEach((member) async {
        await groupCollection
            .doc(group.id)
            .collection("membersStats")
            .doc(member.id)
            .set({"${gameId}Wins": 0, "${gameId}Losses": 0},
                SetOptions(merge: true));
      });
    });
  }

  addNewGameType(String gameTypeName) async {
    //Loop through all of the users
    //Add new game to each user's doc
    QuerySnapshot users = await userCollection.get();
    users.docs.forEach((user) async {
      print(user.id);
      await userCollection.doc(user.id).set(
          {"${gameTypeName}Wins": 0, "${gameTypeName}Losses": 0},
          SetOptions(merge: true));
    });

    //Loop through all of the groups members stats
    //Add new game to each group member's doc
    QuerySnapshot groups = await groupCollection.get();
    groups.docs.forEach((group) async {
      QuerySnapshot members =
          await groupCollection.doc(group.id).collection("membersStats").get();
      members.docs.forEach((member) async {
        await groupCollection
            .doc(group.id)
            .collection("membersStats")
            .doc(member.id)
            .set({"${gameTypeName}Wins": 0, "${gameTypeName}Losses": 0},
                SetOptions(merge: true));
      });
    });
  }

  Future<void> addFieldToUserDoc(String userId, String fieldName) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    await userDoc.set({fieldName: 0}, SetOptions(merge: true));
  }

  //Get the groups array from user doc
  getUserGroupsList(String userId) async {
    DocumentSnapshot userDoc = await userCollection.doc(userId).get();
    List<dynamic> userGroups = userDoc["groups"];
    print(userGroups);
    return userGroups;
  }

  Future<QuerySnapshot<Object?>> getGroupGameResults(String groupId) async {
    QuerySnapshot<Object?> gameResults = await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupId)
        .collection("gameResults")
        .orderBy("gameDate", descending: true)
        .get();
    return gameResults;
  }
}
