import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimaps/screens/signin.dart';
import 'package:unimaps/screens/homepage.dart';
import 'package:unimaps/screens/entry.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // User is logged in
          if (snapshot.hasData) {
            return Homepage();
          }
          // User not logged in
          else {
            return Entry();
          }
        },
      ),
    );
  }
}
