import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unimaps/components/textfield.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../blocs/sign_up_bloc/sign_up_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();

  bool obscurePassword = true;
  bool signUpRequired = false;
  IconData iconPassword = CupertinoIcons.eye_fill;

  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  String? _validatePassword(String? val) {
    setState(() {
      containsUpperCase = RegExp(r'[A-Z]').hasMatch(val ?? '');
      containsLowerCase = RegExp(r'[a-z]').hasMatch(val ?? '');
      containsNumber = RegExp(r'[0-9]').hasMatch(val ?? '');
      containsSpecialChar = RegExp(
        r'[!@#\$&*~`%\-_+=;:,.<>\/\?"\[\]{}\|^]',
      ).hasMatch(val ?? '');
      contains8Length = (val?.length ?? 0) >= 8;
    });

    return null; // This can return a message or null if validation passes
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          setState(() => signUpRequired = false);
        } else if (state is SignUpProcess) {
          setState(() => signUpRequired = true);
        }
      },
      child: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildTextField(
                  nameController,
                  'Name',
                  CupertinoIcons.person,
                  TextInputType.name,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  emailController,
                  'Email',
                  CupertinoIcons.mail,
                  TextInputType.emailAddress,
                  isEmail: true,
                ),
                const SizedBox(height: 10),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildPasswordCriteria(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                signUpRequired
                    ? const CircularProgressIndicator()
                    : _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    TextInputType inputType, {
    bool isEmail = false,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: MyTextField(
        controller: controller,
        hintText: hint,
        obscureText: false,
        keyboardType: inputType,
        prefixIcon: Icon(icon),
        validator: (val) {
          if (val!.isEmpty) return 'Please fill in this field';
          if (isEmail &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(val)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: MyTextField(
        controller: passwordController,
        hintText: 'Password',
        obscureText: obscurePassword,
        keyboardType: TextInputType.visiblePassword,
        prefixIcon: const Icon(CupertinoIcons.lock),
        onChanged: _validatePassword,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
              iconPassword =
                  obscurePassword
                      ? CupertinoIcons.eye_fill
                      : CupertinoIcons.eye_slash_fill;
            });
          },
          icon: Icon(iconPassword),
        ),
        validator: (val) {
          if (val!.isEmpty) return 'Please fill in this field';
          if (!RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~`%\-_+=;:,.<>\/\?"\[\]{}\|^]).{8,}\$',
          ).hasMatch(val)) {
            return 'Please enter a valid password';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordCriteria() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCriteriaColumn([
          {'text': '1 uppercase', 'valid': containsUpperCase},
          {'text': '1 lowercase', 'valid': containsLowerCase},
          {'text': '1 number', 'valid': containsNumber},
        ]),
        _buildCriteriaColumn([
          {'text': '1 special character', 'valid': containsSpecialChar},
          {'text': '8 minimum characters', 'valid': contains8Length},
        ]),
      ],
    );
  }

  Widget _buildCriteriaColumn(List<Map<String, dynamic>> criteria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          criteria
              .map(
                (criterion) => Text(
                  '⚈  ${criterion['text']}',
                  style: TextStyle(
                    color:
                        criterion['valid']
                            ? Colors.green
                            : Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: TextButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            MyUser myUser = MyUser.empty.copyWith(
              email: emailController.text,
              name: nameController.text,
            );
            context.read<SignUpBloc>().add(
              SignUpRequired(myUser, passwordController.text),
            );
          }
        },
        style: TextButton.styleFrom(
          elevation: 3.0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Text(
            'Sign Up',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
