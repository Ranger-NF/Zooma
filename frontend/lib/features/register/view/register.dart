import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/core/di/dependency_injection.dart';
import 'package:frontend/features/register/controller/register_controller.dart';
import 'package:frontend/features/register/view/register_widget.dart';

class RegisterScreen extends StatefulWidget{
  @override
  State<RegisterScreen> createState() => _StateRegisterPage();
}

class _StateRegisterPage extends State<RegisterScreen> with SingleTickerProviderStateMixin{

  late AnimationController _animationController;
  final TextEditingController _controller = TextEditingController();

  late final RegisterController rController;



  final List<Map<String, dynamic>> _stickerData = [
    {
      'path': 'assets/elements/register/Sticker5.svg',
      'size': 75.0,
      'bottom': 30.0,
      'left': 0.0
    },
    {
      'path': 'assets/elements/register/Sticker6.svg',
      'size': 75.0,
      'top': 150.0,
      'right':0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this
    );
    _animationController.forward();
    rController = getIt<RegisterController>();
  }

  @override 
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDD259),
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/elements/register/register_screen.svg',
              fit: BoxFit.cover,
            ),
          ),
          ..._stickerData.asMap().entries.map((entry){
            int index = entry.key;
            Map<String, dynamic> data = entry.value;

            final interval = Interval(
              (index*0.1),
              (index*0.1)+0.5,
              curve: Curves.elasticOut
            );

            final animation = CurvedAnimation(parent: _animationController, curve: interval);

            return Positioned(
              top: data["top"],
              left: data["left"],
              right: data['right'],
              bottom: data['bottom'],
              child: ScaleTransition(
                scale: animation,
                child: SvgPicture.asset(
                  data['path'],
                  width: data['size'],
                ),
              ),
            );

          }),

          RegisterWidget.registerWidget(
            controller: _controller,
            rController: rController,
            context: context
          )

        ],
      ),
    );
  }
}