import 'package:flutter/material.dart';
import 'package:financial_buddy/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_buddy/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            decoration: InputDecoration(label: Text("email")),
            textAlign: TextAlign.center,
            controller: email,
          ),

          TextFormField(
            decoration: InputDecoration(label: Text("password")),
            textAlign: TextAlign.center,
            controller: password,
            obscureText: true,
          ),

          TextFormField(
            decoration: InputDecoration(label: Text("Confirm Password")),
            textAlign: TextAlign.center,
            obscureText: true,
          ),

          ElevatedButton(
            onPressed: () async {
              setState(() => loading = true);
              try {
                final AuthResponse res = await supabase.auth.signUp(
                  email: email.text.trim(),
                  password: password.text.trim(),
                  //emailRedirectTo:
                  //    'io.supabase.flutterquickstart://login-callback/',
                );
                //final Session? session = res.session;
                final User? user = res.user;

                if (user != null) {
                  Navigator.of(context).pushReplacementNamed("/login");
                }
              } on AuthException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error occured, try again.")),
                );
              } finally {
                if (mounted) {
                  setState(() => loading = false);
                }
              }
            },
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Sign Up"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/login");
            },
            child: Text("Already a user?"),
          ),
        ],
      ),
    );
  }
}
