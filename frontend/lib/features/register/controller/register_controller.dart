
import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/util/token_storage.dart';
import 'package:frontend/features/register/service/register_service.dart';

class RegisterController {
  final RegisterService registerService;
  RegisterController(this.registerService);


  Future<void> submitRegister(BuildContext context, String value) async{
    if(value.isEmpty){
      _showSnackBar(context, 'Username cannot be empty', isError: true);
      return;
    }

    final res = await registerService.submitRegister(value);
    if(res.isNotEmpty){
      await TokenStorage.saveToken(tokenKey: 'id', tokenValue: res);
      Navigator.pushNamed(context,AppRoutes.initial);
    } else{
      _showSnackBar(context, 'User Registration Failed');
    }

  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}