import 'package:flutter/material.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/screens/signup_screen.dart';
import 'package:flutter_app/utils/utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Move ID")
        ),
      backgroundColor: Colors.blue,
      body: Column(
        children: <Widget>[
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.account_circle),
              labelText: "Username",
            ),
          ),
        ],
      ),
    );
  }
}
