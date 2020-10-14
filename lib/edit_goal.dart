import 'package:dailygoal/push_notifications.dart';
import 'package:dailygoal/sign_in.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class EditGoal extends StatefulWidget {
  Map<dynamic, dynamic> eachgoals;
  String goalId;
  EditGoal({@required this.eachgoals, this.goalId});
  @override
  _EditGoalState createState() =>
      _EditGoalState(eachgoals: this.eachgoals, goalId: this.goalId);
}

class _EditGoalState extends State<EditGoal> {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  final format = DateFormat('hh:mm a');
  final NotificationManager notificationManager = NotificationManager();
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtDesc = TextEditingController();
  TextEditingController txtTime = TextEditingController();
  Map<dynamic, dynamic> eachgoals;
  String goalId;
  String icon;
  int id;
  bool complete;
  bool isShowPicker;

  _EditGoalState({@required this.eachgoals, this.goalId});

  @override
  void initState() {
    super.initState();
    if (eachgoals["status"] == "completed")
      complete = true;
    else
      complete = false;
    id = int.parse(goalId.substring(4, goalId.length));
    txtTitle.text = eachgoals["title"];
    txtDesc.text = eachgoals["description"];
    icon = eachgoals["icon"];
    isShowPicker = false;
  }

  void updateGoalInDb(BuildContext context) {
    String title = txtTitle.text;
    String desc = txtDesc.text;
    String time = txtTime.text;
    int hour;
    int min;
    if (time == "") {
      time = eachgoals["time"];
    }
    databaseReference.child(uid + "/goals/" + goalId).update(
        {'title': title, 'time': time, 'description': desc, 'icon': icon});

    notificationManager.removeReminder(id);
    hour = int.parse(time.substring(0, 2));
    min = int.parse(time.substring(3, 5));
    if (time.substring(6, 8) == "PM" && hour != 12) hour += 12;
    Alert(
        context: context,
        type: AlertType.success,
        title: "Goal Updated",
        desc: 'I will remind you on $time to $title',
        buttons: [
          DialogButton(
            child: Text(
              "Okay",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () => {
              notificationManager.showNotificationDaily(
                  id, title, desc, hour, min),
              Navigator.pop(context, true),
              Navigator.pop(context, true),
            },
            width: 120,
          )
        ]).show();
  }

  void deleteGoal(context) {
    Alert(
        context: context,
        type: AlertType.warning,
        title: complete ? "Remove Goal?" : "Goal isn't completed?",
        desc: 'Are you sure want to remove your goal?',
        buttons: [
          DialogButton(
            child: Text(
              "Yes",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () => {
              id = int.parse(goalId.substring(4, goalId.length)),
              notificationManager.removeReminder(id),
              databaseReference.child(uid + "/goals/" + goalId).remove(),
              print("removed"),
              Navigator.pop(context, true),
              Navigator.pop(context, true)
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
              Navigator.pop(context, true),
            },
            color: Colors.red,
            width: 120,
          )
        ]).show();
  }

  void changeGoalComplete(context, String status) {
    id = int.parse(goalId.substring(4, goalId.length));
    String time = eachgoals["time"];
    int hour = int.parse(time.substring(0, 2));
    int min = int.parse(time.substring(3, 5));
    if (time.substring(6, 8) == "PM" && hour != 12) hour += 12;

    if (status == "Completed") {
      databaseReference
          .child(uid + "/goals/" + goalId)
          .update({'status': 'completed'});

      notificationManager.removeReminder(id);
      Alert(
          context: context,
          type: AlertType.success,
          title: "Hurray!!",
          desc: 'You have succesfully completed the Goal',
          buttons: [
            DialogButton(
              child: Text(
                "Okay",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onPressed: () => {
                Navigator.pop(context),
              },
              width: 120,
            )
          ]).show();
    } else if (status == "Incompleted") {
      databaseReference
          .child(uid + "/goals/" + goalId)
          .update({'status': 'current'});
      notificationManager.showNotificationDaily(
          id, eachgoals["title"], eachgoals["description"], hour, min);
    }
    setState(() {
      complete = !complete;
    });
  }

  Widget completeButton(context) {
    Color colors = Colors.green;
    String txt = "Completed";
    if (complete) {
      colors = Colors.red;
      txt = "Incompleted";
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: colors,
      ),
      child: FlatButton(
        child: Text(
          "Mark as $txt",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          changeGoalComplete(context, txt);
        },
      ),
    );
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        String emo = emoji.toString();
        emo = emo.substring(emo.lastIndexOf(":") + 1, emo.length);
        print(emo);
        print(emoji.toString());
        setState(() {
          icon = emo;
          onBackPress();
        });
      },
    );
  }

  Future<bool> onBackPress() {
    if (isShowPicker) {
      setState(() {
        isShowPicker = false;
      });
    } else
      Navigator.pop(context, true);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Goal"),
        centerTitle: true,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  deleteGoal(context);
                },
                child: Icon(
                  Icons.delete,
                  size: 30,
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  completeButton(context),
                ],
              ),
              FlatButton(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 60,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isShowPicker = !isShowPicker;
                  });
                },
              ),
              (isShowPicker ? buildSticker() : Container()),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(27, 161, 226, 0.6),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: TextField(
                  controller: txtTitle,
                  cursorColor: Colors.blueGrey,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Title",
                    hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 20),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
                width: 180,
                child: Divider(
                  color: Colors.blueGrey,
                  thickness: 3,
                ),
              ),
              Container(
                height: 150,
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(27, 161, 226, 0.6),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: TextField(
                  controller: txtDesc,
                  maxLines: 8,
                  cursorColor: Colors.blueGrey,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Description",
                    hintStyle: TextStyle(color: Colors.blueGrey, fontSize: 20),
                  ),
                ),
              ),
              Container(
                height: 50,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(27, 161, 226, 0.6),
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: DateTimeField(
                  controller: txtTime,
                  format: format,
                  initialValue: DateTime.parse("2000-01-01 00:00:00Z"),
                  style: TextStyle(color: Colors.blueGrey, fontSize: 20),
                  onShowPicker: (context, currentValue) async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          currentValue ?? DateTime.now()),
                    );
                    return DateTimeField.convert(time);
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              FlatButton(
                color: Colors.lightBlueAccent,
                padding: EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(
                    color: Colors.white70,
                  ),
                ),
                child: Text(
                  "Update",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  updateGoalInDb(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
