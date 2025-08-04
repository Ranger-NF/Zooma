import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class TasksPage extends StatefulWidget {
  final String roomCode;
  final String playerId;

  const TasksPage({
    super.key,
    required this.roomCode,
    required this.playerId,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadPlayerTasks(widget.roomCode, widget.playerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.leaderboard,
              arguments: {'roomCode': widget.roomCode},
            ),
            icon: const Icon(Icons.leaderboard),
          ),
        ],
      ),
      body: Consumer<TaskController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${controller.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.loadPlayerTasks(widget.roomCode, widget.playerId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks available'),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    const Text(
                      'Task 1',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.submit,
                        arguments: {
                          'roomCode': widget.roomCode,
                          'playerId': widget.playerId,
                          'taskId': controller.tasks.first.id,
                        },
                      ),
                      child: const Text('Click Photo'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.tasks.first.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.tasks.first.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    const Spacer(),
                    const Text('1 of 5'),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}