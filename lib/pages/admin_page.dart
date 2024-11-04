import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_scorecard/widgets/widgets.dart';

import '../service/database_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isLoading = false;
  String gameName = "";
  String gameType = "";
  String gameId = "";
  String numberOfPlayers = "";
  String gameTypeName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    createGameDialog(context);
                    // await DatabaseService(
                    //         uid: FirebaseAuth.instance.currentUser!.uid)
                    //     .addFieldToUserDoc(
                    //   "1x7S1OWhP9SDrjuX3zTQKvYr3wj2",
                    //   "admin",
                    // );
                  },
                  child: const Text("Add Game")),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    createGameTypeDialog(context);
                  },
                  child: const Text("Add Game Type")),
            ],
          ),
        ],
      ),
    );
  }

  createGameDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Create Game",
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
                              gameName = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputDecoration.copyWith(
                              labelText: "Game Name"),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextFormField(
                          autocorrect: false,
                          onChanged: (value) {
                            setState(() {
                              gameType = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputDecoration.copyWith(
                              labelText: "Game Type"),
                        ),
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextFormField(
                          autocorrect: false,
                          onChanged: (value) {
                            setState(() {
                              numberOfPlayers = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputDecoration.copyWith(
                              labelText: "Number of Players"),
                        ),
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextFormField(
                          autocorrect: false,
                          onChanged: (value) {
                            setState(() {
                              gameId = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputDecoration.copyWith(
                              labelText: "Game Id"),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                    setState(() {
                      numberOfPlayers = "";
                      gameName = "";
                      gameType = "";
                      gameId = "";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await DatabaseService(
                            uid: FirebaseAuth.instance.currentUser!.uid)
                        .addNewGame(
                            gameName, gameId, gameType, numberOfPlayers);

                    Navigator.of(context).pop(context);
                    setState(() {
                      numberOfPlayers = "";
                      gameName = "";
                      gameType = "";
                      gameId = "";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Add Game"),
                ),
              ],
            );
          });
        });
  }

  createGameTypeDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Create Game Type",
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
                              gameTypeName = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: textInputDecoration.copyWith(
                              labelText: "Game Type Name"),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(context);
                    setState(() {
                      gameTypeName = "";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await DatabaseService(
                            uid: FirebaseAuth.instance.currentUser!.uid)
                        .addNewGameType(gameTypeName);

                    Navigator.of(context).pop(context);
                    setState(() {
                      gameTypeName = "";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: const Text("Add Game Type"),
                ),
              ],
            );
          });
        });
  }
}
