import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

class HomeWidget {

  static TextButton textButton({
    required String name,
    required void Function() onPress
  }){
    return TextButton(
      style: TextButton.styleFrom(
        shadowColor: Colors.black,
        elevation: 25,
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 30
        ),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
        )
      ),
      onPressed: onPress, 
      child: Text(
        name,
        style: TextStyle(
          fontSize: 20
        ),
      )
    );
  }
}