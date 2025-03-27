import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:unimaps/components/textfield.dart';
import 'package:unimaps/components/buttons.dart'; // Import MyButton
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool signInRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),  // Adjust padding
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Email Input Field
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(CupertinoIcons.mail),
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+.)+[\w-]{2,4}$').hasMatch(val)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),  // Increased height for better spacing

                // Password Input Field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: const Icon(CupertinoIcons.lock_fill),
                  errorMsg: _errorMsg,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please fill in this field';
                    } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`)\%\-(_+=;:,.<>/?"[{\]}\|^]).{8,}$').hasMatch(val)) {
                      return 'Please enter a valid password';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                        iconPassword = obscurePassword
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash_fill;
                      });
                    },
                    icon: Icon(iconPassword),
                  ),
                ),
                const SizedBox(height: 20),  // Increased height for better spacing

                // Sign In Button
                signInRequired
                    ? const Center(child: CircularProgressIndicator())
                    : MyButton(
                        text: 'Sign In',
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => signInRequired = true);
                            context.read<SignInBloc>().add(SignInRequired(
                                  emailController.text,
                                  passwordController.text,
                                ));
                          }
                        },
                      ),

                const SizedBox(height: 20),  // Increased height for consistency
              ],
            ),
          ),
        ),
      ),
    );
  }
}