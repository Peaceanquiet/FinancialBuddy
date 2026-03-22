import 'package:financial_buddy/pages/finances.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Loads environment variables from a .env file
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase client for auth and database
import 'pages/home_screen.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/transactions_page.dart';

void main() async {
  // Load environment variables from the .env file (Supabase URL and anon key)
  await dotenv.load(fileName: ".env");

  // Initialize the Supabase client using credentials stored in the .env file.
  // The '!' asserts the values are non-null — the app will throw if they're missing.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Launch the Flutter app
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

// MyApp is the root widget of the application.
// It's stateless because the top-level app configuration doesn't change at runtime.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Buddy',

      // Define the app's color scheme using deep purple as the seed color.
      // Flutter generates a full Material 3 palette from this single color.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // The app always opens on the login page, even if the user has used it before.
      initialRoute: '/login',

      // Named routes map URL-style strings to their corresponding page widgets,
      // making navigation calls like Navigator.pushNamed(context, '/home') possible.
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomeScreen(),
        '/signup': (context) => const SignUpPage(),
        '/transactions': (context) => TransactionsPage(),
        '/finances': (context) => FinancesPage(),
      },
    );
  }
}
