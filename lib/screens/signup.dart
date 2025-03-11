import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unimaps/components/square_tile.dart';
import 'package:unimaps/components/textfield.dart';
import 'package:unimaps/components/buttons.dart';
import 'package:unimaps/services/auth_service.dart';
import 'package:unimaps/theme/app_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signup extends StatefulWidget {
  final Function()? onTap;
  const Signup({super.key, required this.onTap});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Sign user in method
  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Try creating the user
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        // Successfully signed up, so pop the dialog and navigate if needed
        Navigator.pop(context);
      } else {
        // Close the loading dialog
        Navigator.pop(context);

        // Show error Message
        Fluttertoast.showToast(msg: 'Passwords do not match');
      }
    } on FirebaseAuthException catch (e) {
      // Close the loading dialog first
      Navigator.pop(context);

      // Wrong Email
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User email incorrect or not found");
      }
      // Wrong Password
      else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "User password incorrect");
      }
      // Invalid Email
      else if (e.code == 'invalid-email') {
        Fluttertoast.showToast(msg: "User email incorrect");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Welcome text
                Center(
                  child: Text(
                    'Welcome to Unimaps!!',
                    style: AppFonts.anekDevanagariBold(
                      fontSize: 36,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Username field
                MyTextField(
                  controller: emailController,
                  hintText: 'Enter email',
                  obscureText: false,
                ),

                const SizedBox(height: 15),

                // Password field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Enter password',
                  obscureText: true,
                ),

                const SizedBox(height: 15),

                // Password field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // Sign up button
                MyButton(onTap: signUserUp, text: "Sign In"),

                const SizedBox(height: 50),

                // Or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: .5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: .5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Google sign-in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SquareTile(
                    onTap: () => AuthService().signInWithGoogle(),
                    imagePath: 'assets/images/google_logo.png',
                    text: 'Sign in with Google',
                  ),
                ),

                const SizedBox(height: 20), // Add spacing between tiles
                // Apple sign-in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SquareTile(
                    onTap: () {},
                    imagePath: 'assets/images/apple_logo.png',
                    text: 'Sign in with Apple',
                  ),
                ),

                const SizedBox(height: 50),

                // Don't have an account? Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
