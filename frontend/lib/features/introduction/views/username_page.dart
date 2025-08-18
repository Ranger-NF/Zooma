import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:frontend/core/theme/app_theme.dart';
// import 'package:frontend/features/introduction/controllers/username_controller.dart';

// class UsernamePage extends StatefulWidget{
//   @override
//   State<UsernamePage> createState() => _StateUsernamePage();
// }

// class _StateUsernamePage extends State<UsernamePage> {

//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _userController = TextEditingController();

//   void onPressedSubmitButton(){
//     if(_formKey.currentState!.validate()){
//       UsernameController.setUsername(_userController.text.trim());
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Username saved successfully!')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _userController,
//               decoration: InputDecoration(
//                 labelText: "Username",
//                 border: OutlineInputBorder()
//               ),
//               validator: (value){
//                 if(value == null || value.trim().isEmpty){
//                   return "Please enter a Username";
//                 }
//                 return null;
//               },
//             ),
//             SizedBox(height: 10,),
//             ElevatedButton(
//               onPressed: onPressedSubmitButton, 
//               child: Text("Submit") 
//             )
//           ],
//         )
//       ),
//     );
//   }
// }

class BackgroundAnimationScreen extends StatefulWidget {
  const BackgroundAnimationScreen({super.key});

  @override
  State<BackgroundAnimationScreen> createState() =>
      _BackgroundAnimationScreenState();
}

// A simple class to represent a single moving box.
class Box {
  // Current x and y coordinates of the box.
  double x, y;
  // Velocity in the y direction (downwards).
  double velocityY;
  // Rotation angle in radians.
  double rotation;
  // Rotation speed.
  double rotationSpeed;
  // A flag to check if the box has stopped.
  bool isStopped;

  Box({
    required this.x,
    required this.y,
    this.velocityY = 0.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.isStopped = false,
  });
}

// The state class for the BackgroundAnimationScreen.
class _BackgroundAnimationScreenState extends State<BackgroundAnimationScreen>
    with TickerProviderStateMixin {
  // Animation controller for the falling boxes.
  late AnimationController _controller;
  // List to hold all the Box objects.
  late List<Box> _boxes;
  // The gravity constant to apply to the velocity.
  final double _gravity = 0.5;
  // The factor by which velocity is reduced on a bounce. A lower value means a smaller bounce.
  final double _bouncingVelocity = 0.3;
  // Constants for the box size.
  final double _boxSize = 120.0;
  // A random number generator.
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Initialize the list of boxes with 20 instances.
    _boxes = [];

    // Initialize the animation controller.
    _controller = AnimationController(
      vsync: this,
      // The duration is now longer to simulate a continuous animation.
      duration: const Duration(seconds: 10),
    )..addListener(() {
      // Update the state on every tick of the animation.
      _updateBoxPositions();
    });

    // Start the animation.
    _controller.repeat();

    // Add a timer to add boxes at random intervals.
    _addBoxesPeriodically();
  }

  // Adds a new box to the list.
  void _addBox() {
    if (_boxes.length < 20) {
      _boxes.add(
        Box(
          x: _random.nextDouble(),
          y: 0.0,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
        ),
      );
    }
  }

  // Adds a random number of boxes (1 to 3) at a time.
  void _addBoxesPeriodically() {
    // Determine the number of boxes to add (1 to 3).
    final int boxesToAdd = _random.nextInt(3) + 1;
    for (int i = 0; i < boxesToAdd; i++) {
      _addBox();
    }
    // Schedule the next addition after a random delay.
    Future.delayed(Duration(milliseconds: _random.nextInt(1000) + 500), () {
      if (mounted) {
        _addBoxesPeriodically();
      }
    });
  }

  // Updates the position and velocity of each box.
  void _updateBoxPositions() {
    setState(() {
      // Get the screen size for bounds checking.
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      for (var box in _boxes) {
        // Only update boxes that haven't stopped.
        if (!box.isStopped) {
          // Apply gravity to the velocity.
          box.velocityY += _gravity;

          // Update the y position based on velocity.
          box.y += box.velocityY;

          // Update the rotation angle.
          box.rotation += box.rotationSpeed;

          // Check if the box has hit the bottom of the screen.
          if (box.y >= screenHeight - _boxSize) {
            // The position is set to the bottom to avoid sinking.
            box.y = screenHeight - _boxSize;
            // Reverse the velocity and apply the bouncing factor.
            box.velocityY = -box.velocityY * _bouncingVelocity;
            
            // Set the box to stopped if the bounce is very small.
            if (box.velocityY.abs() < 1.0) {
              box.isStopped = true;
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose the controller to free up resources.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            // Use a Stack to layer the background animation and foreground container.
            children: [
              // Background layer with the falling boxes.
              ..._boxes.map((box) {
                return Positioned(
                  // Use a fraction of the screen width for the x position.
                  left: box.x * (constraints.maxWidth - _boxSize),
                  // The y position is the animated value.
                  top: box.y,
                  child: Transform.rotate(
                    angle: box.rotation,
                    child: Container(
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        // Add rounded corners to the boxes.
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                );
              }).toList(),

              // Foreground container centered on the screen.
              Center(
                child: Container(
                  width: 96.82,
                  height: 111.47,
                  // Use a semi-transparent background to see the animation behind it.
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Text(
                      'Foreground Container',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}