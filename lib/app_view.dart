import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        textTheme: GoogleFonts.outfitTextTheme(),
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
          onSurface: Colors.black,
          primary: Colors.black,
          onPrimary: Colors.black,
          secondary: Color(0xFF1B5E20),
          onSecondary: Colors.white, 
          tertiary: Colors.white,
          error: Colors.red,
          outline: Colors.black
        ),
        iconTheme: IconThemeData(
          color: Colors.black
        )
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return Homepage();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
