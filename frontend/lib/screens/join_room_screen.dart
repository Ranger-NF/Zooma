import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'tasks_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Team'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Consumer<GameService>(
        builder: (context, gameService, child) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter the team code',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Team Code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: gameService.isLoading ? null : () async {
                      if (_codeController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                        final success = await gameService.joinRoom(
                          _codeController.text.toUpperCase(),
                          _nameController.text,
                        );
                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => TasksScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to join room')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: gameService.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Join Room',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
