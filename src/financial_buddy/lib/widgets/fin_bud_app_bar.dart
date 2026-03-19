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
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(title, textScaler: TextScaler.linear(1.4)),
          ),

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
        ],
      ),
    );
  }
}
