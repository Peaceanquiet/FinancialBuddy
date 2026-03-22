import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final user = supabase.auth.currentUser;
  final budgetName = TextEditingController();
  final budgetType = TextEditingController();
  final budgetAmnt = TextEditingController();
  List goalInfo = [];

  Future<void> loadGoals() async {
    final response = await supabase
        .from("Budget_Goals")
        .select("goal_name, goal_amount, acc_link")
        .eq("id", user!.id);

    setState(() {
      goalInfo = response;
    });
  }

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  @override
  void dispose() {
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color((Colors.deepPurple.shade200.toARGB32())),
      appBar: AppBar(
        title: const Text(
          'Financial Buddy',
          textScaler: TextScaler.linear(2),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color((Colors.white.toARGB32())),

        /*****************
        * Hamburger Menu *
        *****************/
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: BuddyDrawer(title: "Home Screen"),
      body: ListView(
        children: [
          Text(
            "Finances",
            textScaler: TextScaler.linear(1.55),
            style: TextStyle(fontSize: 16, decorationThickness: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
