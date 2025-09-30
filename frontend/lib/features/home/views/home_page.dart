import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/home/views/home_widget.dart';

class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(top: 60, left: 35, right: 35, bottom: 60),
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
                  HomeWidget.textButton(
                    name: "Create Room", 
                    onPress: (){
                      Navigator.pushNamed(context, AppRoutes.createRoom);
                    }
                  ),
                  HomeWidget.textButton(
                    name: "Join Room", 
                    onPress: (){
                      Navigator.pushNamed(context, AppRoutes.joinRoom);
                    }
                  ),
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
                  SizedBox(height: 120,),
                  HomeWidget.textButton(
                    name: "Leaderboard", 
                    onPress: (){
                      Navigator.pushNamed(context, AppRoutes.leaderboard);
                    }
                  ),
                  SizedBox(height: 60,)
                ],
              ),
            ),
          ), 
        ),
      )
    );
  }
}