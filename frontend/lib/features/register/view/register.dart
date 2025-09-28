import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget{
  @override
  State<RegisterScreen> createState() => _StateRegisterPage();
}

class _StateRegisterPage extends State<RegisterScreen>{

  final TextEditingController _controller = TextEditingController();

  @override 
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDD259),
      body: LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints view){
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: view.maxHeight
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter Your Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35
                    ),
                  ),
                  Text(
                    "To Start the Game..",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                      ),
                      elevation: 50,
                      child: TextFormField(
                        controller: _controller,
                        style: TextStyle(
                          color: AppTheme.backgroundColor,
                          fontSize: 25
                        ),
                        cursorColor: AppTheme.backgroundColor,
                        cursorWidth: 3,
                        cursorHeight: 35,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(36),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    )
                  )
                ],
              ),
            ),
          );
        } 
      ),
    );
  }
}