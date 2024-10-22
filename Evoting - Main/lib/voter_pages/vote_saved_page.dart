import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class VoteSavedPage extends StatefulWidget {
  @override
  _VoteSavedPageState createState() => _VoteSavedPageState();
}

class _VoteSavedPageState extends State<VoteSavedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Use SystemNavigator.pop() to exit the app
        return false; // Prevents the default back button behavior
      },
      child: Scaffold(
        backgroundColor: Colors.greenAccent[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Lottie.asset('assets/animations/vote_saved.json',
              //     width: 200, height: 200),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                  'Vote Saved Successfully!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => SystemNavigator.pop(), // Exit the app
                child: Text('Exit'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
