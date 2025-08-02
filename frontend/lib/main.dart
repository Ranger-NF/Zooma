import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/game_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameService(),
      child: MaterialApp(
        title: 'Bingo Game',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Color(0xFF90EE90),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
