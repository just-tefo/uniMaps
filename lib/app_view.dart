import 'package:flutter/material.dart';
import 'package:unimaps/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:unimaps/screens/home/homepage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimaps/screens/auth/welcome.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
        surface: Color(0xFFE0E0E0),
        onSurface: Color(0xFF2D2D2D),
        primary: Color(0xFF4A4A4A),
        onPrimary: Colors.black,
        secondary: Color(0xFF707070),
        onSecondary: Colors.white,
        tertiary: Color(0xFFB0B0B0),
        error: Colors.red,
        outline: Color(0xFF424242)
      ),
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return const Homepage();
          } else {
            return const Homepage();
          }
        },
      ),
    );
  }
}
