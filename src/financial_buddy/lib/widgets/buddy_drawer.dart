import 'package:flutter/material.dart';
import 'package:financial_buddy/utils/user_preferences.dart';
import 'package:financial_buddy/main.dart';
import 'package:financial_buddy/theme/app_theme.dart';
import 'package:financial_buddy/widgets/gradient_button.dart';

class BuddyDrawer extends StatelessWidget {
  const BuddyDrawer({super.key, required this.title});
  final String title;

  Future<void> _signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundBlack,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Header ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: AppGradients.primaryGradient,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.textWhite,
                      size: 34,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Financial Destination",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Your future. Our destination.",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              _drawerItem(
                context,
                icon: Icons.home,
                label: "Home",
                route: "/home",
              ),
              _drawerItem(
                context,
                icon: Icons.receipt_long,
                label: "Transactions",
                route: "/transactions",
              ),
              _drawerItem(
                context,
                icon: Icons.flag,
                label: "Goals",
                route: "/finances",
              ),

              const Spacer(),

              GradientButton(
                text: "Log Out",
                onPressed: () {
                  setLoggedIn(false);
                  _signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(
          icon,
          color: AppColors.accentBlue,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}