import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart' show Ticker;
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/introduction/providers/introduction_provider.dart';
import 'package:provider/provider.dart';

class BackgroundAnimationScreen extends StatefulWidget {
  const BackgroundAnimationScreen({super.key});

  @override
  State<BackgroundAnimationScreen> createState() =>
      _BackgroundAnimationScreenState();
}

class _BackgroundAnimationScreenState extends State<BackgroundAnimationScreen>
    with TickerProviderStateMixin {


  List images = [
    "assets/elements/element1.png",
    "assets/elements/element2.png",
    "assets/elements/element3.png",
    "assets/elements/element5.png",
    "assets/elements/element6.png"
  ];
  
  late AnimationController _controller;


  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BoxProvider>(context, listen: false);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        final size = MediaQuery.of(context).size;
        provider.updateBoxPositions(size);
      });

    _controller.repeat();
    provider.addBoxesPeriodically();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer<BoxProvider>(
            builder: (context, boxProvider, _) {
              return Stack(
                children: [
                  // Background falling boxes
                  ...boxProvider.boxes.map((box) {
                    return Positioned(
                      left: box.x * (constraints.maxWidth - 120.0),
                      top: box.y,
                      child: Transform.rotate(
                        angle: box.rotation,
                        child: Container(
                          width: 96.82,
                          height: 111.47,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Image.asset(
                            images[box.imageIndex],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Foreground container
                  Center(
                    child: Container(
                      width: 250,
                      height: 500,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(20)
                      ),
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
          );
        },
      ),
    );
  }
}