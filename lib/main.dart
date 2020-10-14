import 'package:dailygoal/AddGoal.dart';
import 'package:dailygoal/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'DGAccountPage.dart';
import 'MainPage.dart';
import 'sign_in.dart';

void main() {
  runApp(DailyGoal());
}

class DailyGoal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageInd = 1;
  final DGAccountPage _dgAccountPage = DGAccountPage();
  final MainPage _mainPage = MainPage();
  final AddGoal _addGoal = AddGoal();
  Widget _showPage = MainPage();

  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return _dgAccountPage;
      case 1:
        return _mainPage;
      case 2:
        return _addGoal;
      default:
        return Container(
          child: Center(
            child: Text("Page Not Found!"),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      bottomNavigationBar: CurvedNavigationBar(
        index: pageInd,
        backgroundColor: Colors.blueAccent,
        color: Colors.white70,
        buttonBackgroundColor: Colors.white,
        height: 60,
        items: <Widget>[
          Icon(
            Icons.account_circle,
            size: 30,
          ),
          Icon(
            Icons.home,
            size: 30,
          ),
          Icon(
            Icons.add,
            size: 30,
          ),
        ],
        onTap: (int tappedIndex) {
          setState(() {
            _showPage = _pageChooser(tappedIndex);
          });
        },
        animationDuration: Duration(
          milliseconds: 400,
        ),
      ),
      body: SafeArea(
        child: _showPage,
      ),
    );
  }
}
