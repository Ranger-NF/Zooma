import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/introduction/providers/introduction_provider.dart';
import 'package:provider/provider.dart';
import 'package:typewritertext/typewritertext.dart';

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
  Timer? _navigationTimer;

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

    _navigationTimer = Timer(
      const Duration(seconds: 10),
      () {
        if (mounted) {
           Navigator.pushNamed(context, AppRoutes.register);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double boxWidth = 96.82;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer<BoxProvider>(
            builder: (context, boxProvider, _) {
              return Stack(
                children: [
                  ...boxProvider.boxes.map((box) {
                    return Positioned(
                      left: box.x * (constraints.maxWidth - boxWidth), // Using boxWidth makes it more accurate
                      top: box.y,
                      child: Transform.rotate(
                        angle: box.rotation,
                        child: Container(
                          width: boxWidth,
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
                  Center(
                    child: Container(
                      width: 250,
                      height: 500,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: TypeWriter.text(
                        'Foreground Container mmansdkjndakdnkasndkjnakdjn adsjnkdnasj saDNKASDMNADKSNKDNKNDJSKANFJDJmksajdfojaosfd sfdajkfdlsadfn dsfjdfndnsj',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        duration: const Duration(milliseconds: 30),
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