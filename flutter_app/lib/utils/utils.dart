import 'package:flutter/material.dart';

//Constum widget used to make input fields for login and register
Widget buildInputField({
  required TextEditingController controller,
  required String hintText,
  required bool obscureText,
  required Icon icon,
}){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon,
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'RobotoMono'
      )
    ),
    obscureText: obscureText,
  );
}

