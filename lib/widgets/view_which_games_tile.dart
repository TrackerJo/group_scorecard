import 'package:flutter/material.dart';

class ViewWhichGamesTile extends StatelessWidget {
  final bool viewGroupGames;
  final Function() switchViewGroupGames;

  const ViewWhichGamesTile(
      {super.key,
      required this.viewGroupGames,
      required this.switchViewGroupGames});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                switchViewGroupGames();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: viewGroupGames ? 0 : 5,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Personal",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                switchViewGroupGames();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: viewGroupGames ? 5 : 0,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Group",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
