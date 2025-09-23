import 'dart:async'; 
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/features/introduction/models/introduction_model.dart';

class BoxProvider with ChangeNotifier {
  final double _gravity = 0.5;
  final double _bouncingVelocity = 0.3;
  final double _boxSize = 120.0;
  final Random _random = Random();

 
  List<Box> _boxes = [];
  List<Box> get boxes => _boxes;

  Timer? _timer;

  BoxProvider() {
    addBoxesPeriodically();
  }

  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void addBox() {
    if (_boxes.length < 10) {
      _boxes.add(Box(
        imageIndex: _random.nextInt(5),
        x: _random.nextDouble(),
        y: 0.0,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
      ));
      notifyListeners();
    }
  }

  void addBoxesPeriodically() {
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_boxes.length >= 10) {
        timer.cancel();
        return;
      }
      final int boxesToAdd = _random.nextInt(3) + 1;
      for (int i = 0; i < boxesToAdd; i++) {
        addBox();
      }
    });
  }


  void updateBoxPositions(Size screenSize) {
    for (int i = 0; i < _boxes.length; i++) {
      var box = _boxes[i];

      if (!box.isStopped) {
        box.velocityY += _gravity;
        box.y += box.velocityY;
        box.rotation += box.rotationSpeed;
        double groundLevel;
        if (i < 5) {
          groundLevel = screenSize.height - _boxSize;
        } else {
          groundLevel = screenSize.height - (2 * _boxSize);
        }

        if (box.y >= groundLevel) {
          box.y = groundLevel;
          box.velocityY = -box.velocityY * _bouncingVelocity;

          if (box.velocityY.abs() < 1.0) {
            box.isStopped = true;
          }
        }
      }
    }
    notifyListeners();
  }
}