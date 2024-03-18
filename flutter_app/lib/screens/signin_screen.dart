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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("#3b75d7"),
              hexStringToColor("#4f5eff"),
              hexStringToColor("#8b31b1")
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSignUpField(
              controller: _usernameController,
              labelText: 'Username',
            ),
            buildSignUpField(
              controller: _passwordController,
              labelText: 'Email',
              obscureText: true,
            ),           
            ElevatedButton(
              onPressed: () {
                // Handle sign in button press
              },
              child: const Text('Sign In'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text(
                'Don\'t have an account? Register here',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
