import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class RegisterWidget {
  static Widget registerWidget({
    required TextEditingController controller,
  }){
    return LayoutBuilder(
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
                    fontSize: 25
                  ),
                ),
                Text(
                  "To Start the Game..",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
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
                      controller: controller,
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
    );
  }
}