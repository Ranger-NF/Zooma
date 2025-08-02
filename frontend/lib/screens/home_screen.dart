import 'package:flutter/material.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';
import 'leaderboard_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade300,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'Bingo',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Enter your name',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              _buildMenuButton(
                context,
                'LeaderBoard',
                Icons.leaderboard,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                ),
              ),
              SizedBox(height: 15),
              _buildMenuButton(
                context,
                'Create Room',
                Icons.add,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRoomScreen()),
                ),
              ),
              SizedBox(height: 15),
              _buildMenuButton(
                context,
                'Join Room',
                Icons.group_add,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinRoomScreen()),
                ),
              ),
              SizedBox(height: 15),
              _buildMenuButton(
                context,
                'Tasks',
                Icons.task,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TasksScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade400,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}