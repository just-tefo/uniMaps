import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        cursorColor: Colors.black, // Keeps cursor black
        style: const TextStyle(color: Colors.black), // Ensures text remains black
        decoration: InputDecoration(
          labelText: hintText, 
          labelStyle: const TextStyle(color: Colors.black), // Keeps label black
          floatingLabelBehavior: FloatingLabelBehavior.auto, 
          filled: true,
          fillColor: Colors.grey[200], // Matches SquareTile background
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black87),
            borderRadius: BorderRadius.circular(12), // Matches SquareTile
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black87, width: 2),
            borderRadius: BorderRadius.circular(12), 
          ),
        ),
      ),
    );
  }
}
