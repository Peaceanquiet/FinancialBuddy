import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
//import 'package:hive_flutter/hive_flutter.dart';

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
    double scr_width = MediaQuery.sizeOf(context).width;
    double scr_height = MediaQuery.sizeOf(context).height;

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

      body: Column(
        children: [
          SizedBox(
            width: scr_width,
            height: scr_height / 5,
            child: Card(
              elevation: 10,
              child: Column(
                children: [
                  Text(
                    "Savings Goals",
                    textAlign: TextAlign.center,
                    textScaler: TextScaler.linear(1.75),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Text("Goals: #", textScaler: TextScaler.linear(1.25)),
                      Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          size: 30,
                          color: Colors.deepPurple,
                          Icons.add_circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //ListView.builder
        ],
      ),
    );
  }
}
