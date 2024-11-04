import 'package:flutter/material.dart';
import 'package:group_scorecard/helper/helper_function.dart';
import 'package:group_scorecard/pages/games_page.dart';
import 'package:group_scorecard/pages/group_info_page.dart';
import 'package:group_scorecard/pages/groups_page.dart';
import 'package:group_scorecard/pages/leaderboard_page.dart';
import 'package:group_scorecard/pages/score_page.dart';

import 'custom_page_route.dart';

class GroupNavBar extends StatefulWidget {
  final String userName;
  final String email;
  final int currentPageIndex;
  final String groupName;
  final String groupId;

  const GroupNavBar(
      {super.key,
      required this.userName,
      required this.email,
      required this.currentPageIndex,
      required this.groupId,
      required this.groupName});

  @override
  State<GroupNavBar> createState() => _GroupNavBarState();
}

class _GroupNavBarState extends State<GroupNavBar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        if (index == 0 && widget.currentPageIndex != 0) {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(
              builder: (BuildContext context) {
                return GamesPage(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                );
              },
            ),
          );
          //nextScreen(context, const HomePage());
        } else if (index == 1 && widget.currentPageIndex != 1) {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(
              builder: (BuildContext context) {
                return LeaderboardPage(
                    groupId: widget.groupId,
                    userName: widget.userName,
                    email: widget.email,
                    groupName: widget.groupName);
              },
            ),
          );
        } else if (index == 2 && widget.currentPageIndex != 2) {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(
              builder: (BuildContext context) {
                return GroupInfo(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    userName: widget.userName,
                    email: widget.email);
              },
            ),
          );
        }
      },
      selectedIndex: widget.currentPageIndex,
      destinations: <Widget>[
        NavigationDestination(
          icon: widget.currentPageIndex != 0
              ? const Icon(Icons.scoreboard_outlined)
              : const Icon(Icons.scoreboard),
          label: 'Games',
          tooltip: "Games",
        ),
        NavigationDestination(
          icon: widget.currentPageIndex != 1
              ? const Icon(Icons.leaderboard_outlined)
              : const Icon(Icons.leaderboard),
          label: 'Leaderboard',
          tooltip: "Leaderboard",
        ),
        NavigationDestination(
          icon: widget.currentPageIndex != 2
              ? const Icon(Icons.info_outline)
              : const Icon(Icons.info),
          label: 'Group Info',
          tooltip: "Group Info",
        ),
      ],
    );
  }
}

class MainNavBar extends StatefulWidget {
  final int currentPageIndex;
  final String userName;
  final String email;

  const MainNavBar({
    super.key,
    required this.currentPageIndex,
    required this.userName,
    required this.email,
  });

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        if (index == 0 && widget.currentPageIndex != 0) {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(
              builder: (BuildContext context) {
                return const GroupsPage();
              },
            ),
          );
          //nextScreen(context, const HomePage());
        } else if (index == 1 && widget.currentPageIndex != 1) {
          Navigator.of(context).pushReplacement(
            CustomPageRoute(
              builder: (BuildContext context) {
                return ScorePage(
                  userName: widget.userName,
                  email: widget.email,
                );
              },
            ),
          );
        }
      },
      selectedIndex: widget.currentPageIndex,
      destinations: <Widget>[
        NavigationDestination(
          icon: widget.currentPageIndex != 0
              ? const Icon(Icons.group_outlined)
              : const Icon(Icons.group),
          label: 'Groups',
          tooltip: "Groups",
        ),
        NavigationDestination(
          icon: widget.currentPageIndex != 1
              ? Icon(Icons.scoreboard_outlined)
              : Icon(Icons.scoreboard),
          label: 'Score Counter',
          tooltip: "Score Counter",
        )
      ],
    );
  }
}
