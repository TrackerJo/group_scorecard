import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_scorecard/widgets/widgets.dart';

import '../pages/profile_page.dart';
import '../service/database_service.dart';

class MemberTile extends StatefulWidget {
  final String groupId;
  final String userName;
  final String userId;

  const MemberTile(
      {super.key,
      required this.groupId,
      required this.userName,
      required this.userId});

  @override
  State<MemberTile> createState() => _MemberTileState();
}

class _MemberTileState extends State<MemberTile> {
  String email = "";

  @override
  void initState() {
    super.initState();
    getMemberData(widget.userId).then((val) {
      setState(() {
        email = val['email'];
      });
    });
  }

  getMemberData(userId) async {
    var userData =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getUserData(userId);
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        nextScreen(
            context,
            ProfilePage(
              userName: widget.userName,
              email: email,
              userId: widget.userId,
              groupId: widget.groupId,
              getGroupStats: true,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(widget.userName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30)),
          ),
          title: Text(widget.userName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle:
              Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
