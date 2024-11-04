import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_scorecard/pages/profile_page.dart';
import 'package:group_scorecard/pages/score_counter_simple_page.dart';
import 'package:group_scorecard/pages/scorepad_page.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/widgets.dart';

class ScorePage extends StatefulWidget {
  final String userName;
  final String email;

  const ScorePage({super.key, required this.userName, required this.email});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  int currentPageIndex = 1;
  final formKey = GlobalKey<FormState>();
  String scoreType = "";
  String gameType = "";
  int numberOfPlayers = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Score Counter",
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
          userName: widget.userName,
          email: widget.email,
        ),
        body: selectScoreType());
  }

  selectScoreType() {
    return Center(
      child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 250,
                child: DropdownButtonFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: "Select Game Type",
                    ),
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    items: const [
                      DropdownMenuItem(child: Text("1v1"), value: "2p"),
                      DropdownMenuItem(child: Text("1v1v1"), value: "3p"),
                      DropdownMenuItem(child: Text("1v1v1v1"), value: "4p"),
                      DropdownMenuItem(child: Text("Multiple"), value: "multi"),
                    ],
                    onChanged: (val) {
                      setState(() {
                        gameType = val!;
                        if (gameType != "multi")
                          numberOfPlayers = int.parse(gameType.split("p")[0]);
                      });
                    }),
              ),
              if (gameType == "multi") const SizedBox(height: 10),
              if (gameType == "multi")
                Container(
                  width: 250,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: textInputDecoration.copyWith(
                      hintText: "Number of Players",
                    ),
                    onChanged: (value) {
                      setState(() {
                        numberOfPlayers = value != "" ? int.parse(value) : 0;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                width: 250,
                child: DropdownButtonFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: "Select Score Type",
                    ),
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    items: [
                      if (gameType != "multi")
                        DropdownMenuItem(
                            child: Text("Simple"), value: "simple"),
                      DropdownMenuItem(child: Text("Scorepad"), value: "pad"),
                    ],
                    onChanged: (val) {
                      setState(() {
                        scoreType = val!;
                      });
                    }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        if (scoreType == "simple") {
                          nextScreen(
                              context,
                              ScoreCounterSimplePage(
                                  userName: widget.userName,
                                  email: widget.email,
                                  selectedGameType: gameType));
                        } else {
                          nextScreen(
                              context,
                              ScorepadPage(
                                  userName: widget.userName,
                                  email: widget.email,
                                  selectedGameType: gameType,
                                  numberOfPlayers: numberOfPlayers));
                        }
                      });
                    }
                  },
                  child: const Text("Start")),
            ],
          )),
    );
  }
}
