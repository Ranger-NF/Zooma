import 'package:flutter/material.dart';
import 'package:frontend/features/introduction/controllers/username_controller.dart';

class UsernamePage extends StatefulWidget{
  @override
  State<UsernamePage> createState() => _StateUsernamePage();
}

class _StateUsernamePage extends State<UsernamePage> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();

  void onPressedSubmitButton(){
    if(_formKey.currentState!.validate()){
      UsernameController.setUsername(_userController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _userController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder()
              ),
              validator: (value){
                if(value == null || value.trim().isEmpty){
                  return "Please enter a Username";
                }
                return null;
              },
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: onPressedSubmitButton, 
              child: Text("Submit") 
            )
          ],
        )
      ),
    );
  }
}