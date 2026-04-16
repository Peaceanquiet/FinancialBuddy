import 'package:flutter/material.dart';
import 'package:financial_buddy/utils/user_preferences.dart';
import 'package:financial_buddy/main.dart';
import 'package:financial_buddy/theme/app_theme.dart';

class BuddyDrawer extends StatelessWidget {
  const BuddyDrawer({super.key, required this.title});
  final String title;

  Future<void> _signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final sHeight = MediaQuery.of(context).size.height;

    return Drawer(
      backgroundColor: AppColors.darkSurface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // This creates that pretty little box, which I believe can house
            // some images later on.
            decoration: BoxDecoration(color: AppColors.secondaryPurple),
            child: Text(
              style: const TextStyle(color: AppColors.textWhite),
              title,
              textScaler: TextScaler.linear(1.4),
              textAlign: TextAlign.center,
            ),
          ),
          // Navigation can probably use some minor optimization for
          // checking if the screen its on now is open so it doesn't
          // unneccessarily reload screens, but idk how to do that yet
          // so I'll mark this for later.
          ListTile(
            title: const Text("Home Screen"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
              //This will just pop the menu instead of loading (see above comment)
              //Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Transactions"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/transactions');
            },
          ),
          ListTile(
            title: const Text("Finances"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/finances');
            },
          ),

          Padding(padding: EdgeInsetsGeometry.all(sHeight / 4)),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                setLoggedIn(false);
                _signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Log Out"),
            ),
          ),
          // Can add more ListTiles here whenever a new navigational
          // point is needed.
        ],
      ),
    );
  }
}
