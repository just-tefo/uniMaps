import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    
    _topAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>(
      [
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1,
        ),
        TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color.fromRGBO(27, 94, 32, 1),
                  Color.fromRGBO(102, 187, 106, 1),
                ],
                begin: _topAlignmentAnimation.value,
                end: _bottomAlignmentAnimation.value,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final width = constraints.maxWidth;

                return Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                      child: Container(),
                    ),
                    Column(
                      children: [
                        // Added logo and app name section
                        SizedBox(height: height * 0.15),
                        _buildLogoAndName(context),
                        const Spacer(),
                        // Existing content
                        SizedBox(
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
                                      .withOpacity(0.6),
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
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoAndName(BuildContext context) {
    return Column(
      children: [
        // Replace this with your actual logo widget
        // This is a placeholder using an icon - you should use Image.asset() or similar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/logo.png'),
        ),
        const SizedBox(height: 20),
        const Text(
          'UniMaps',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBlocProvider(Widget screen) {
    return BlocProvider<SignInBloc>(
      create: (context) => SignInBloc(
        userRepository: context.read<AuthenticationBloc>().userRepository,
      ),
      child: screen,
    );
  }
}