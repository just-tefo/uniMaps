import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:user_repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'simple_bloc_observer.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: "assets/.env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up Bloc observer
  Bloc.observer = SimpleBlocObserver();

  // Run the app
  runApp(MyApp(FirebaseUserRepo(firebaseAuth: FirebaseAuth.instance)));
}