import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/auth/login_page.dart';

import '../helper/helper_function.dart';
import '../service/auth_service.dart';
import '../service/database_service.dart';
import '../widgets/group_stat_tile.dart';
import '../widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email;
  final String groupId;
  final bool getGroupStats;
  final String userId;

  ProfilePage(
      {super.key,
      required this.userName,
      required this.email,
      required this.groupId,
      required this.getGroupStats,
      required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  bool isCurrentUser = false;
  int currentPageIndex = 0;
  int sectionSelected = 1;
  String searchedStat = "";

  List<Map<String, dynamic>> groupUserStats = [];
  List<Map<String, dynamic>> allUserStats = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Check if user name matches current user SF
    checkIfCurrentUser();
    if (widget.getGroupStats) {
      getGroupUserStats();
    }
    getAllUserStats();
  }

  getGroupUserStats() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupUserStats(widget.groupId, widget.userId)
        .then((val) {
      setState(() {
        groupUserStats = val;
      });
    });
  }

  getAllUserStats() {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getAllUserStats(widget.userId)
        .then((val) {
      setState(() {
        allUserStats = val;
      });
    });
  }

  checkIfCurrentUser() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      if (value == widget.userName) {
        setState(() {
          isCurrentUser = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            "Profile",
            style: TextStyle(
                color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
          ),
          actions: [
            isCurrentUser
                ? IconButton(
                    onPressed: () async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Logout"),
                              content: const Text(
                                  "Are you sure you want to log out?"),
                              actions: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await authService.signOut();
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage()),
                                        (route) => false);
                                  },
                                  icon: const Icon(
                                    Icons.done,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.exit_to_app),
                  )
                : const SizedBox(),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Icon(
                Icons.account_circle,
                size: 200,
                color: Colors.grey[700],
              ),
              const SizedBox(height: 10),
              Text(widget.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 10),
              Text("Email: ${widget.email}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.getGroupStats
                      ? GestureDetector(
                          onTap: () async {
                            setState(() {
                              sectionSelected = 0;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: sectionSelected == 0
                                  ? Border.all(
                                      color: Theme.of(context).primaryColor)
                                  : Border(),
                              color: sectionSelected == 0
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                            ),
                            child: Text("Group Stats",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: sectionSelected == 0
                                        ? Colors.white
                                        : Colors.grey)),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        sectionSelected = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: sectionSelected == 1
                            ? Border.all(color: Theme.of(context).primaryColor)
                            : Border(),
                        color: sectionSelected == 1
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                      ),
                      child: Text("All Stats",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: sectionSelected == 1
                                  ? Colors.white
                                  : Colors.grey)),
                    ),
                  ),
                  // const SizedBox(width: 10),
                  // GestureDetector(
                  //   onTap: () async {
                  //     setState(() {
                  //       sectionSelected = 2;
                  //     });
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(5),
                  //       border: sectionSelected == 2
                  //           ? Border.all(color: Theme.of(context).primaryColor)
                  //           : Border(),
                  //       color: sectionSelected == 2
                  //           ? Theme.of(context).primaryColor
                  //           : Colors.transparent,
                  //     ),
                  //     child: Text("Class Assignments",
                  //         style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 13,
                  //             color: sectionSelected == 2
                  //                 ? Colors.white
                  //                 : Colors.grey)),
                  //   ),
                  // ),
                ],
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              sectionSelected == 0 ? groupStats() : allStats(),
            ],
          ),
        ));
  }

  groupStats() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text("Group Stats",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            TextFormField(
              style: const TextStyle(color: Colors.black),
              decoration: textInputDecoration.copyWith(
                  labelText: "Search for Stat", prefixIcon: Icon(Icons.search)),
              onChanged: (val) {
                setState(() {
                  searchedStat = val;
                });
              },
            ),
            groupStatsList()
          ],
        ),
      ),
    );
  }

  groupStatsList() {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: groupUserStats.map((Map<String, dynamic> value) {
          print(
              "GROUP Stat Name: ${value['statName']} Stat Value: ${value['statValue']}");
          return GroupStatTile(
            statName: value['statName'].toString(),
            statValue: int.parse(value['statValue'].toString()),
            statFilter: searchedStat,
          );
        }).toList(),
      ),
    );
  }

  allStats() {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Text("All Stats",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextFormField(
            style: const TextStyle(color: Colors.black),
            decoration: textInputDecoration.copyWith(
                labelText: "Search for Stat", prefixIcon: Icon(Icons.search)),
            onChanged: (val) {
              setState(() {
                searchedStat = val;
              });
            },
          ),
          allStatsList()
        ],
      ),
    ));
  }

  allStatsList() {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: allUserStats.map((Map<String, dynamic> value) {
          print(
              "ALL Stat Name: ${value['statName']} Stat Value: ${value['statValue']}");
          return GroupStatTile(
            statName: value['statName'].toString(),
            statValue: int.parse(value['statValue'].toString()),
            statFilter: searchedStat,
          );
        }).toList(),
      ),
    );
  }
}
