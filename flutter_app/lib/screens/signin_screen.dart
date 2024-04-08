import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/screens/signup_screen.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
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
          child:Column(
            children: <Widget>[
               const SizedBox(height: 100),
              Image.asset("assets/images/move_id_logo.png"),
              const SizedBox(height: 10),
              buildInputField(controller: _emailController, hintText: "Email", obscureText: false, icon: const Icon(Icons.account_circle)),
              const SizedBox(height: 20),
              buildInputField(controller: _passwordController, hintText: "Password", obscureText: true, icon: const Icon(Icons.lock)),
              const SizedBox(height:20),
              GestureDetector(
                onTap: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Click here!",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 12,
                    color: Colors.white,
                    fontFamily: 'RobotoMono',
                    ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
              onPressed: () {
                if(_emailController.text.isEmpty || _passwordController.text.isEmpty){
                  Fluttertoast.showToast(
                    msg: "Forgot to fill all the fields",
                    toastLength: Toast.LENGTH_SHORT,
                    backgroundColor: Colors.white,
                    textColor: Colors.black
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              },
              child: const Text(
                "Sign up",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'RobotoMono'
                ),
              ),
            ),

              const SizedBox(height: 100),
            ],
        ),
      ),
      ),
    );
  }
}
