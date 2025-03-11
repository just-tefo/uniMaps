import 'package:flutter/material.dart';
import 'package:unimaps/screens/signin.dart';
import 'package:unimaps/screens/signup.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  //initially show login page
  bool showLoginPage = true;

  //toggle between signin and signup page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return Signin(onTap: togglePages);
    } else {
      return Signup(onTap: togglePages);
    }
  }
}
