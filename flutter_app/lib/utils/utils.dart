import 'package:flutter/material.dart';

Widget buildSignUpField({
  required TextEditingController controller,
  required String labelText,
  bool obscureText = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}