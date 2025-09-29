import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/features/home/views/home_page.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _StateSplashScreen();
}

class _StateSplashScreen extends State<SplashScreen>{
  int currentIndex = 0;
  late Timer timer;

  final List<Widget> frames = [
      Center(
          child: Image.asset(
              "assets/images/screen0.png"
          ),
      ),
      Center(
          child: Image.asset(
              "assets/images/screen1.png"
          ),
      ),
      Center(
          child: Image.asset(
              "assets/images/screen2.png"
          ),
      ),
      Center(
          child: Image.asset(
              "assets/images/screen3.png"
          ),
      ),
      Center(
          child: Image.asset(
              "assets/images/screen4.png"
          ),
      ),
      Center(
          child: Image.asset(
              "assets/images/screen5.png"
          ),
      ),
  ];

  @override
  void initState() {
      super.initState();
      timer = Timer.periodic(Duration(milliseconds: 150), (Timer t) {
          setState(() {
              currentIndex = (currentIndex + 1) % frames.length; 
          });
      });
      Timer(Duration(seconds: 2), () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
          );
      });
  }

  @override
  void dispose() {
      timer.cancel();
      super.dispose();
  }


  @override
  Widget build(BuildContext context) {
      return Scaffold(
          body: IndexedStack(
              index: currentIndex,
              children: frames,
          ),
      );
  }
}