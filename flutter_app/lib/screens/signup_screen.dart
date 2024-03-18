import 'package:flutter/material.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_app/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height, // Set height of the container to the screen height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("#3b75d7"),
              hexStringToColor("#4f5eff"),
              hexStringToColor("#8b31b1"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100), // Adjust vertical padding here
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Align the column content to the bottom
              children: [
                buildSignUpField(
                  controller: _usernameController,
                  labelText: 'Username',
                ),
                buildSignUpField(
                  controller: _emailController,
                  labelText: 'Email',
                  obscureText: true,
                ),
                buildSignUpField(
                  controller: _fnameController,
                  labelText: 'First Name',
                  obscureText: true,
                ),
                buildSignUpField(
                  controller: _lnameController,
                  labelText: 'Last Name',
                  obscureText: true,
                ),
                buildSignUpField(
                  controller: _password1Controller,
                  labelText: 'Password',
                  obscureText: true,
                ),
                buildSignUpField(
                  controller: _password2Controller,
                  labelText: 'Verify Password',
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle sign up button press
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login here',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
