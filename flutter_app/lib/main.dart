import 'package:flutter/material.dart';
import 'package:flutter_app/screens/signin_screen.dart';
import 'package:get/get.dart';
import 'utils/home_controller.dart';


void main() {
  // Initialize HomeController
  Get.put(HomeController());

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Move ID",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primaryColor: Colors.blue,


      ),
      home:const SignInScreen(),
    );
  }
}