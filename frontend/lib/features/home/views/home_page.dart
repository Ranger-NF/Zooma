import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/home/views/home_widget.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 35, right: 35, bottom: 60),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              border: BoxBorder.all(
                color: Colors.black,
                width: 4
              ),
              color: AppTheme.primaryColor,
            ),
            child: Column(
              spacing: 30,
              children: [
                SizedBox(height: 60,),
                HomeWidget.textButton(name: "Create Room", onPress: (){}),
                HomeWidget.textButton(name: "Join Room", onPress: (){}),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(1, 3),
                              spreadRadius: 1
                            )
                          ],
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(30)
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 60,),
                HomeWidget.textButton(name: "Leaderboard", onPress: (){})

              ],
            ),
          ),
        ), 
      ),
    );
  }
}