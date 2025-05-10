import 'package:unimaps/app_view.dart';
import 'package:unimaps/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:unimaps/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(userRepository: userRepository),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SignUpBloc>(
            create: (context) => SignUpBloc(userRepository: userRepository),
          ),
        ],
        child: MyAppView(),
      ),
    );
  }
}
