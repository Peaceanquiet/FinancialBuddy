import 'package:flutter/material.dart';

class BuddyDrawer extends StatelessWidget {
  const BuddyDrawer({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // This creates that pretty little box, which I believe can house
            // some images later on.
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(title, textScaler: TextScaler.linear(1.4)),
          ),
          // Navigation can probably use some minor optimization for
          // checking if the screen its on now is open so it doesn't
          // unneccessarily reload screens, but idk how to do that yet
          // so I'll mark this for later.
          ListTile(
            title: const Text("Home Screen"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            title: const Text("Transactions"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/transactions');
            },
          ),
          // Can add more ListTiles here whenever a new navigational
          // point is needed.
        ],
      ),
    );
  }
}
