import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
      ), // Matches other components' padding
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity, // Full width inside padding
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ), // Comfortable tap area
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          alignment: Alignment.center,
          child:  Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
