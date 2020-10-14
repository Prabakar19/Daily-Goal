import 'package:dailygoal/AddGoal.dart';
import 'package:dailygoal/DGAccountPage.dart';
import 'package:dailygoal/push_notifications.dart';
import 'package:dailygoal/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'edit_goal.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool loading = false;
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  final NotificationManager notificationManager = NotificationManager();
  List<Widget> goalList = [];
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    goalRefresher(context);
  }

  goalRefresher(BuildContext context) async {
    setState(() {
      goalList = [];
    });
    databaseReference
        .child(uid + "/goals")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> goals = snapshot.value;
      goals.forEach((key, value) {
        Map<dynamic, dynamic> eachgoals = value;
        String goalId = key.toString();
        setState(() {
          goalList.add(
            Container(
              margin: EdgeInsets.all(10),
              child: FlatButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditGoal(eachgoals: eachgoals, goalId: goalId)),
                  ).then((val) => val ? goalRefresher(context) : null);
                },
                onLongPress: () {
                  showDialogCard(context, eachgoals);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      eachgoals["title"].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      eachgoals["icon"].toString(),
                      style: TextStyle(
                        fontSize: 55,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      eachgoals["time"].toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                    ),
                    Text(
                      eachgoals["status"].toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          );
        });
      });
      isLoading = false;
    });
  }

  void removeAllGoals(BuildContext context) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: "Remove all the Goals?",
        desc: 'Do you really want to remove all the Goals?',
        buttons: [
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () => {
              notificationManager.removeAllReminder(),
              databaseReference.child(uid + "/goals").remove(),
              goalIdglob = 1,
              print("All the notifications are removed"),
              Navigator.pop(context)
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
              goalRefresher(context),
              Navigator.pop(context),
            },
            color: Colors.red,
            width: 120,
          )
        ]).show();
  }

  showDialogCard(BuildContext context, Map<dynamic, dynamic> each) {
    showGeneralDialog(
      barrierLabel: "card",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 400,
              child: SizedBox.expand(
                child: Center(
                  child: Material(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 50),
                        Text(
                          each["icon"].toString(),
                          style: TextStyle(
                            fontSize: 80,
                          ),
                        ),
                        Text(
                          each["title"].toString(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            each["description"].toString(),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                        Text(
                          each["time"].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          each["status"].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 200, left: 40, right: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
            ));
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                Row(
                  children: <Widget>[
                    FlatButton(
                      child: CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(
                          imageUrl,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DGAccountPage()),
                        );
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Welcome $name...",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.yellow[100],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      iconSize: 35,
                      icon: Icon(
                        Icons.clear_all,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        removeAllGoals(context);
                      },
                    ),
                    SizedBox(
                      width: 30,
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      padding: EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      children: [
                        if (goalList.isEmpty)
                          Container(
                            margin: EdgeInsets.all(10),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddGoal()));
                              },
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  size: 40,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100),
                                topRight: Radius.circular(100),
                                bottomLeft: Radius.circular(100),
                                bottomRight: Radius.circular(100),
                              ),
                            ),
                          )
                        else
                          for (Widget goal in goalList) goal
                      ],
                    ),
                  ),
                ),
              ],
            ),
      onWillPop: onWillPop,
    );
  }

  DateTime pressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (pressTime == null || now.difference(pressTime) > Duration(seconds: 2)) {
      pressTime = now;
      Fluttertoast.showToast(msg: "Press the ack utton aain to close the app");
      return Future.value(false);
    }
    return Future.value(true);
  }
}
