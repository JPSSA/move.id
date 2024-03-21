import 'package:flutter/material.dart';
import 'package:flutter_app/screens/signin_screen.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/utils/utils.dart';
import 'package:flutter_app/screens/signup_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Sign Up',
        style: TextStyle(fontFamily: 'RobotoMono')
        ),
        backgroundColor: hexStringToColor("#3b75d7"),
        ),
      body: SingleChildScrollView(
        child: Container(
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
               const SizedBox(height: 30),
               buildInputField(controller: _fnameController, hintText: "First Name", obscureText: false, icon: const Icon(Icons.text_fields)),
               const SizedBox(height: 20),
               buildInputField(controller: _lnameController, hintText: "Last Name", obscureText: false, icon: const Icon(Icons.text_fields)),
               const SizedBox(height: 20),
               buildInputField(controller: _usernameController, hintText: "Username", obscureText: false, icon: const Icon(Icons.account_circle)),
               const SizedBox(height: 20),
               buildInputField(controller: _emailController, hintText: "Email", obscureText: false, icon: const Icon(Icons.email)),
               const SizedBox(height: 20),
               buildInputField(controller: _password1Controller, hintText: "Password", obscureText: true, icon: const Icon(Icons.lock)),
               const SizedBox(height: 20),
               buildInputField(controller: _password2Controller, hintText: "Verify Password", obscureText: true, icon: const Icon(Icons.lock)),
               const SizedBox(height: 20),
               GestureDetector(
                onTap: () {
                  // Navigate to the new page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: const Text(
                  "Already have and account? Sign up here!",
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
                  if(_fnameController.text.isEmpty || _lnameController.text.isEmpty
                  || _emailController.text.isEmpty || _usernameController.text.isEmpty
                  || _password1Controller.text.isEmpty || _password2Controller.text.isEmpty){
                    Fluttertoast.showToast(
                      msg: "Forgot to fill all the fields",
                      toastLength: Toast.LENGTH_SHORT,
                      backgroundColor: Colors.white,
                      textColor: Colors.black
                    );
                  }else{

                  }

                },
                child: const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'RobotoMono'
                  ),
                ),
              ),
               const SizedBox(height: 40),
            ],
          )
        ),
       
      ),
    );
  }
}
