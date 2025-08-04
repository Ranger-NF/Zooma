import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/room_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();
  final _playerNameController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Team'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Enter the Team Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _roomCodeController,
                decoration: const InputDecoration(
                  hintText: '203045',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter room code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _playerNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Consumer<RoomController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : _joinRoom,
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Join Room'),
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<RoomController>(
                builder: (context, controller, child) {
                  if (controller.error != null) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        controller.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _joinRoom() async {
    if (_formKey.currentState!.validate()) {
      final controller = context.read<RoomController>();
      await controller.joinRoom(
        _roomCodeController.text.trim(),
        _playerNameController.text.trim(),
      );

      if (controller.error == null && controller.currentRoom != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.tasks,
          (route) => false,
          arguments: {
            'roomCode': controller.currentRoom!.roomCode,
            'playerId': 'current_player_id', // This should come from the join response
          },
        );
      }
    }
  }
}