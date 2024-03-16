import 'package:flutter/material.dart';
import 'package:flutter_app/screens/signin_screen.dart';


void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Move ID",
      theme: ThemeData(

        primaryColor: Colors.blue,


      ),
      home:const SignInScreen(),
    );
  }
}