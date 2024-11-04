import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/pages/groups_page.dart';
import 'package:group_scorecard/pages/profile_page.dart';
import 'package:group_scorecard/widgets/group_stat_tile.dart';
import 'package:group_scorecard/widgets/member_tile.dart';

import '../service/auth_service.dart';
import '../service/database_service.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/widgets.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String email;

  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName,
      required this.email});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? groupData;
  AuthService authService = AuthService();
  String adminName = "";
  String groupCode = "";
  int sectionSelected = 0;
  int currentPageIndex = 2;
  String searchedStat = "";
  bool isAdmin = false;

  List<Map<String, dynamic>> groupStats = [];

  @override
  void initState() {
    getGroupData();
    // TODO: implement initState
    super.initState();
    getAdmin();
    getGroupCode();
    getGroupStats();
  }

  getGroupStats() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupStats(widget.groupId)
        .then((val) {
      setState(() {
        groupStats = val;
      });
    });
  }

  getAdmin() {
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        adminName = val;

        if (getName(adminName) == widget.userName) {
          isAdmin = true;
        }
      });
    });
  }

  getGroupData() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupData(widget.groupId)
        .then((val) {
      setState(() {
        //print(val.data);
        groupData = val;
      });
    });
  }

  getGroupCode() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupCode(widget.groupId)
        .then((val) {
      setState(() {
        groupCode = val;
      });
    });
  }

  getName(String r) {
    return r.substring(r.indexOf("_") + 1, r.length);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getMemberData(userId) async {
    var userData =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getUserData(userId);
    return userData;
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Group Info",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Leave Group"),
                        content: const Text(
                            "Are you sure you want to leave this group?"),
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
                              DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .leaveGroup(
                                      widget.groupId,
                                      getName(adminName),
                                      widget.groupName,
                                      FirebaseAuth.instance.currentUser!.uid)
                                  .whenComplete(() {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const GroupsPage()),
                                    (route) => false);
                              });
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
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      bottomNavigationBar: GroupNavBar(
          userName: widget.userName,
          email: widget.email,
          currentPageIndex: currentPageIndex,
          groupId: widget.groupId,
          groupName: widget.groupName),
      body: newDesign(),
    );
  }

  newDesign() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(getEachFistLetterOfWords(widget.groupName),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40)),
          ),
          const SizedBox(height: 10),
          Text(widget.groupName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          Text("Group Code: ${groupCode}",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    sectionSelected = 0;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: sectionSelected == 0
                        ? Border.all(color: Theme.of(context).primaryColor)
                        : Border(),
                    color: sectionSelected == 0
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                  ),
                  child: Text("Members",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: sectionSelected == 0
                              ? Colors.white
                              : Colors.grey)),
                ),
              ),
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
                  child: Text("Group Stats",
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
          sectionSelected == 0 ? groupMembers() : groupStatsList(),
        ],
      ),
    );
  }

  groupMembers() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Text("Members",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          memberList()
        ],
      ),
    );
  }

  groupStatsList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text("Stats",
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
            statsList()
          ],
        ),
      ),
    );
  }

  statsList() {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: groupStats.map((Map<String, dynamic> value) {
          return GroupStatTile(
            statName: value['statName'].toString(),
            statValue: int.parse(value['statValue'].toString()),
            statFilter: searchedStat,
          );
        }).toList(),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
      stream: groupData,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data['members'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return isAdmin &&
                            snapshot.data['members'][index] != adminName
                        ? Dismissible(
                            dragStartBehavior: DragStartBehavior.down,
                            direction: DismissDirection.endToStart,
                            background: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
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
                            key: Key(snapshot.data['members'][index]),
                            onDismissed: (direction) async {
                              await DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .leaveGroup(
                                      widget.groupId,
                                      getName(snapshot.data['members'][index]),
                                      widget.groupName,
                                      getId(snapshot.data['members'][index]));
                              setState(() {});
                            },
                            child: MemberTile(
                              userName:
                                  getName(snapshot.data['members'][index]),
                              userId: getId(snapshot.data['members'][index]),
                              groupId: widget.groupId,
                            ))
                        : MemberTile(
                            userName: getName(snapshot.data['members'][index]),
                            userId: getId(snapshot.data['members'][index]),
                            groupId: widget.groupId,
                          );
                  });
            } else {
              return const Center(child: Text("No members yet"));
            }
          } else {
            return const Center(child: Text("No members yet"));
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
