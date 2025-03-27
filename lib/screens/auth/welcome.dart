import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimaps/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:unimaps/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return Stack(
            children: [
              _buildBackgroundCircles(context, height, width),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: height / 1.8,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: TabBar(
                          controller: tabController,
                          unselectedLabelColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6), // Fixes the invalid method
                          labelColor: Theme.of(context).colorScheme.onSurface,
                          tabs: const [
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Sign In', style: TextStyle(fontSize: 18)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            _buildBlocProvider(const SignInScreen()),
                            _buildBlocProvider(const SignUpScreen()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// **Extracted function to remove code duplication**
  Widget _buildBlocProvider(Widget screen) {
    return BlocProvider<SignInBloc>(
      create: (context) => SignInBloc(
        userRepository: context.read<AuthenticationBloc>().userRepository,
      ),
      child: screen,
    );
  }

  /// **Extracted background circles for better readability**
  Widget _buildBackgroundCircles(BuildContext context, double height, double width) {
    return Stack(
      children: [
        Positioned(
          top: -height * 0.2,
          right: width * 0.1,
          child: _circle(context, height, width, Theme.of(context).colorScheme.tertiary),
        ),
        Positioned(
          top: -height * 0.1,
          left: -width * 0.2,
          child: _circle(context, height / 1.3, width / 1.3, Theme.of(context).colorScheme.secondary),
        ),
        Positioned(
          top: -height * 0.1,
          right: -width * 0.2,
          child: _circle(context, height / 1.3, width / 1.3, Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  /// **Helper method for creating background circles**
  Widget _circle(BuildContext context, double height, double width, Color color) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
