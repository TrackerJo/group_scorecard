import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/helper/helper_function.dart';
import 'package:group_scorecard/pages/admin_page.dart';
import 'package:group_scorecard/pages/profile_page.dart';
import 'package:group_scorecard/service/database_service.dart';
import 'package:group_scorecard/widgets/group_tile.dart';
import 'package:group_scorecard/widgets/navigation_bar.dart';
import 'package:group_scorecard/widgets/widgets.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String selection = "";
  bool _isLoading = false;
  String groupName = "";
  String groupCode = "";
  String userName = "";
  String email = "";
  Stream? groups;
  int currentPageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserSFData();
  }

  getUserSFData() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    //Getting list of snapshots in our stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups(FirebaseAuth.instance.currentUser!.uid)
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    List<String> name = res.split("_");
    return name[1];
  }

  getClassData(String groupId) async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupData(groupId)
        .then((val) {
      return val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Groups",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, AdminPage());
              },
              icon: Icon(
                Icons.admin_panel_settings_outlined,
                size: 35,
              )),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
                onPressed: () {
                  nextScreen(
                      context,
                      ProfilePage(
                        userName: userName,
                        email: email,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        getGroupStats: false,
                        groupId: "",
                      ));
                },
                icon: const Icon(
                  Icons.account_circle,
                  size: 35,
                )),
          )
        ],
      ),
      bottomNavigationBar: MainNavBar(
        currentPageIndex: currentPageIndex,
        email: email,
        userName: userName,
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
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

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return selection == ""
                ? AlertDialog(
                    title: Text(
                      "Create or Join Group",
                      textAlign: TextAlign.left,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoading == true
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selection = "create";
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: const Text("Create Group")),
                        SizedBox(
                          height: 10,
                        ),
                        _isLoading == true
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selection = "join";
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                                child: const Text("Join Group")),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(context);
                          setState(() {
                            selection = "";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text("Cancel"),
                      ),
                    ],
                  )
                : selection == "create"
                    ? AlertDialog(
                        title: Text(
                          "Create Group",
                          textAlign: TextAlign.left,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoading == true
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor),
                                  )
                                : TextFormField(
                                    autocorrect: false,
                                    onChanged: (value) {
                                      setState(() {
                                        groupName = value;
                                      });
                                    },
                                    style: const TextStyle(color: Colors.black),
                                    decoration: textInputDecoration.copyWith(
                                        labelText: "Group Name"),
                                  ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(context);
                              setState(() {
                                selection = "";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              //userType == "student" ? joinClass() : createClass();
                              createGroup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text("Create"),
                          ),
                        ],
                      )
                    : AlertDialog(
                        title: Text(
                          "Join Group",
                          textAlign: TextAlign.left,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isLoading == true
                                ? Center(
                                    child: CircularProgressIndicator(
                                        color: Theme.of(context).primaryColor),
                                  )
                                : TextFormField(
                                    autocorrect: false,
                                    onChanged: (value) {
                                      setState(() {
                                        groupCode = value;
                                      });
                                    },
                                    style: const TextStyle(color: Colors.black),
                                    decoration: textInputDecoration.copyWith(
                                        labelText: "Group Code"),
                                  ),
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(context);
                              setState(() {
                                selection = "";
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              //userType == "student" ? joinClass() : createClass();
                              joinGroup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text("Join"),
                          ),
                        ],
                      );
          });
        });
  }

  createGroup() {
    if (groupName != "") {
      setState(() {
        _isLoading = true;
      });

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .createGroup(
              userName, groupName, FirebaseAuth.instance.currentUser!.uid)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(context);
        showSnackBar(context, Colors.green, "Group created successfully!");
      });
    } else {
      showSnackBar(context, Colors.red, "Please enter a group name!");
    }
  }

  joinGroup() {
    if (groupCode != "") {
      setState(() {
        _isLoading = true;
      });

      DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .joinGroup(
              userName, groupCode, FirebaseAuth.instance.currentUser!.uid)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(context);
        showSnackBar(context, Colors.green, "Group joined successfully!");
      });
    } else {
      showSnackBar(context, Colors.red, "Please enter the group code!");
    }
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        //Make checks
        if (snapshot.hasData) {
          if (snapshot.data["groups"].length != null) {
            if (snapshot.data["groups"].length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data["groups"].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data["groups"].length - index - 1;
                    return GroupTile(
                      userName: snapshot.data["fullName"],
                      groupId: getId(snapshot.data["groups"][reverseIndex]),
                      groupName: getName(snapshot.data["groups"][reverseIndex]),
                    );
                  });
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
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

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
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
            "You've not joined or created any groups, tap on the add icon to join or create a group.",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
