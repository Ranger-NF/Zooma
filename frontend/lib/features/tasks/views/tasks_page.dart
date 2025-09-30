import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/tasks/views/task_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/elements/task/task_screen.svg',
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              Container(
                color: Colors.transparent,
                width: 360,
                height: 90,
                child: AppBar(
                  centerTitle: true,
                  title: Text(
                    "Join Room",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 25
                    ),
                  ),
                  leadingWidth: 80,
                  leading: Padding(
                    padding: EdgeInsets.only(left: 30,bottom: 5),
                    child: IconButton(
                      style: IconButton.styleFrom(
                        elevation: 20,
                        foregroundColor: AppTheme.backgroundColor,
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                        )
                      ),
                      onPressed: (){}, 
                      icon: Icon(Icons.arrow_back)
                    ),
                  )
                ),
              )
            ],
          ),
          
          PageView(
            controller: _controller,
            children: const <Widget>[
              TaskWidget(taskNumber: 1),
              TaskWidget(taskNumber: 2),
              TaskWidget(taskNumber: 3),
              TaskWidget(taskNumber: 4),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 165.0), 
              child: SmoothPageIndicator(
                controller: _controller,
                count: 4,
                effect: WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: AppTheme.backgroundColor,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

