import 'package:dailygoal/push_notifications.dart';
import 'package:dailygoal/sign_in.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

int goalIdglob = 1;

class AddGoal extends StatefulWidget {
  @override
  _AddGoalState createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoal> {
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference();
  final NotificationManager notificationManager = NotificationManager();
  TextEditingController txtTitle = TextEditingController();
  TextEditingController txtDesc = TextEditingController();
  TextEditingController txtTime = TextEditingController();
  final format = DateFormat('hh:mm a');
  String icon;
  bool isButtonEnable;
  bool isShowPicker;

  @override
  void initState() {
    super.initState();
    setState(() {
      isShowPicker = false;
      isButtonEnable = false;
      icon = "+";
    });
  }

  void addGoalInDb() async {
    String title = txtTitle.text;
    String desc = txtDesc.text;
    String time = txtTime.text;
    int hour = int.parse(time.substring(0, 2));
    int min = int.parse(time.substring(3, 5));
    String format = time.substring(6, 8);

    if (format == "PM" && hour != 12) hour += 12;
    if (title != "" && desc != "" && time != "" && icon != "+") {
      try {
        databaseReference
            .child(uid + "/goals/" + "goal" + goalIdglob.toString())
            .child("title")
            .set(title);
        databaseReference
            .child(uid + "/goals/" + "goal" + goalIdglob.toString())
            .child("description")
            .set(desc);
        databaseReference
            .child(uid + "/goals/" + "goal" + goalIdglob.toString())
            .child("time")
            .set(time);
        databaseReference
            .child(uid + "/goals/" + "goal" + goalIdglob.toString())
            .child("icon")
            .set(icon);
        databaseReference
            .child(uid + "/goals/" + "goal" + goalIdglob.toString())
            .child("status")
            .set("current");
      } catch (error) {
        print(error);
      }

      String body = "Don't forget your goal";
      notificationManager.showNotificationDaily(
          goalIdglob, title, body, hour, min);
      goalIdglob++;

      Alert(
          context: context,
          type: AlertType.success,
          title: "Goal Added",
          desc: 'I will remind you on $time to $title',
          buttons: [
            DialogButton(
              child: Text(
                "Okay",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              onPressed: () => {
                print(context),
                Navigator.pop(context, true),
              },
              width: 120,
            )
          ]).show();

      setState(() {
        icon = "+";
        txtTitle.clear();
        txtDesc.clear();
        txtTime.clear();
      });
    }
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

  bool isEmpty() {
    setState(() {
      if (txtTitle.text != "" &&
          txtDesc.text != "" &&
          txtTime.text != "" &&
          icon != "+") {
        isButtonEnable = true;
      } else {
        isButtonEnable = false;
      }
    });
    return isButtonEnable;
  }

  Future<bool> onBackPress() {
    if (isShowPicker) {
      setState(() {
        isShowPicker = false;
      });
    } else
      Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text(
          'Add your goal',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: WillPopScope(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
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
                  onChanged: (val) {
                    isEmpty();
                  },
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
                  color: Colors.white70,
                  thickness: 3,
                ),
              ),
              (isShowPicker ? buildSticker() : Container()),
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
                  onChanged: (val) {
                    isEmpty();
                  },
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
                  onChanged: (val) {
                    isEmpty();
                  },
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
                color: isButtonEnable ? Colors.white70 : Colors.blueAccent,
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(
                    color: Colors.white70,
                  ),
                ),
                child: Text(
                  "ADD",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: isButtonEnable ? Colors.black : Colors.white70,
                  ),
                ),
                onPressed: () {
                  addGoalInDb();
                },
              ),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
        onWillPop: onBackPress,
      ),
    );
  }
}
