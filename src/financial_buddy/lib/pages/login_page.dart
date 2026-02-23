import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// LoginPage is stateful because it owns text controllers and handles async authorization logic
// that may trigger UI updates (e.g. showing a snackbar on error).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers capture the live text input from the email and password fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      // Attempt to sign in via Supabase's email/password auth.
      // .trim() strips accidental leading/trailing whitespace from user input.
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // `mounted` checks that the widget is still in the tree before touching
      // the context — important because the auth call is async and the user
      // could have navigated away in the meantime.
      // pushReplacementNamed removes the login page from the navigation stack
      // so the user can't press Back to return to it after logging in.
      if (mounted) Navigator.pushReplacementNamed(context, '/home');

    } on AuthException catch (e) {
      // AuthException covers Supabase-specific errors (wrong password, unverified
      // email, etc.). Show the error message directly from Supabase as a snackbar.
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the form
          children: [
            // Email input — no obscuring needed for email addresses
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),

            // Password input — obscureText hides characters as the user types
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            // Primary action: triggers the async login flow above
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),

            // Secondary action: takes new users to the sign-up page.
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}