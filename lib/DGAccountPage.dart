import 'package:dailygoal/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'LoginPage.dart';

class DGAccountPage extends StatefulWidget {
  @override
  _DGAccountPageState createState() => _DGAccountPageState();
}

class _DGAccountPageState extends State<DGAccountPage> {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  int currentCount = 0;
  int completeCount = 0;
  @override
  void initState() {
    databaseReference
        .child(uid + "/goals/")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> goals = snapshot.value;
      goals.forEach((key, value) {
        Map<dynamic, dynamic> eachgoals = value;

        eachgoals.forEach((key, value) {
          if (key.toString() == "status" && value.toString() == "current") {
            setState(() {
              currentCount++;
            });
          }
          if (key.toString() == "status" && value.toString() == "completed") {
            setState(() {
              completeCount++;
            });
          }
        });
      });
    });
    super.initState();
  }

  void signOut() {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Sign out?",
        desc: 'Are you sure want to Sign Out?',
        buttons: [
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () => {
              signOutGoogle(),
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              )
            },
            color: Colors.green,
            width: 120,
          ),
          DialogButton(
            child: Text(
              "No",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () => {
              Navigator.pop(context),
            },
            color: Colors.red,
            width: 120,
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Profile",
          style: TextStyle(fontSize: 25),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.power_settings_new,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      signOut();
                    },
                  ),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          imageUrl,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton.icon(
                          color: Colors.blueAccent,
                          icon: Icon(
                            Icons.schedule,
                            size: 25,
                            color: Colors.white70,
                          ),
                          label: Text(
                            "Current Goals",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FlatButton.icon(
                          color: Colors.blueAccent,
                          icon: Icon(
                            Icons.done_outline,
                            size: 25,
                            color: Colors.white70,
                          ),
                          label: Text(
                            "Completed Goals",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Text(
                            currentCount.toString(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            completeCount.toString(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
