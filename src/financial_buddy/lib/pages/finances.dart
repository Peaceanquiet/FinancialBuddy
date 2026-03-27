import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
//import 'package:hive_flutter/hive_flutter.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

//Budget Goal
class BudgetGoal {
  String? goalName;
  String? goalCategory;
  int? goalAmount;
  int? goalProgress;

  BudgetGoal({
    required this.goalName,
    required this.goalAmount,
    required this.goalCategory,
    this.goalProgress = 0,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'goal_name': goalName,
      'goal_category': goalCategory,
      'goal_amount': goalAmount,
      'goal_progress': goalProgress,
      'user_id': userId,
    };
  }
}

class BudgetGoalsSupa {
  Future<void> addGoal(BudgetGoal goal, String userId) async {
    await supabase.from("Budget_Goals").insert(goal.toMap(userId));
  }

  Future<void> deleteGoal(BudgetGoal goalName, String userId) async {
    await supabase
        .from("Budget_Goals")
        .delete()
        .eq('goal_name', goalName)
        .eq('user_id', userId);
  }

  Future<void> addProgress(String goalName, String userId, int progress) async {
    await supabase
        .from("Budget_Goals")
        .update({'goal_progress': progress})
        .eq("user_id", userId);
  }
}

final List<String> categories = [
  'Food',
  'Transport',
  'Housing',
  'Entertainment',
  'Health',
  'Shopping',
  'Salary',
  'Other',
];

class _FinancesPageState extends State<FinancesPage> {
  final user = supabase.auth.currentUser;
  final goalName = TextEditingController();
  final goalCat = TextEditingController();
  final goalAmnt = TextEditingController();
  List<Map<String, dynamic>> goals = [];

  Future<void> loadGoals() async {
    final response = await supabase
        .from("Budget_Goals")
        .select(
          "goal_name, goal_amount, goal_category, acc_link, goal_progress",
        )
        .eq("user_id", user!.id);

    setState(() {
      goals = response;
    });
  }

  List<Map<String, dynamic>> transactions = [];
  Future<void> loadTxns() async {
    final response = await supabase
        .from("transactions")
        .select("title, category, amount")
        .eq("user_id", user!.id);

    setState(() {
      transactions = response;
    });
  }

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  @override
  void dispose() {
    goalName.dispose();
    goalAmnt.dispose();
    goalCat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.sizeOf(context).width;
    double scrHeight = MediaQuery.sizeOf(context).height;

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
      drawer: BuddyDrawer(title: "Finances"),
      body: Column(
        children: [
          SizedBox(
            width: scrWidth,
            height: scrHeight / 5,
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
                      Text(
                        "Goals: ${goals.length}",
                        textScaler: TextScaler.linear(1.25),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          String selectedCategory = categories[0];
                          showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (ctx, setStateDialog) => AlertDialog(
                                title: Text("Add Goal"),
                                icon: Icon(Icons.monetization_on),
                                iconColor: Colors.yellow[400],
                                backgroundColor: Colors.deepPurple[100],
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      TextField(
                                        decoration: InputDecoration(
                                          label: Text("Goal Name"),
                                        ),
                                        controller: goalName,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsGeometry.directional(
                                          top: 10,
                                        ),
                                      ),
                                      TextField(
                                        decoration: InputDecoration(
                                          label: Text("Goal Amount"),
                                        ),
                                        controller: goalAmnt,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsGeometry.directional(
                                          top: 10,
                                        ),
                                      ),
                                      DropdownButtonFormField(
                                        initialValue: selectedCategory,
                                        decoration: const InputDecoration(
                                          labelText: "Type",
                                        ),
                                        items: categories
                                            .map(
                                              (c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(c),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) =>
                                            selectedCategory = val!,
                                      ),
                                      Padding(
                                        padding: EdgeInsetsGeometry.directional(
                                          top: 10,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final goal = BudgetGoal(
                                            goalName: goalName.text,
                                            goalAmount:
                                                int.tryParse(goalAmnt.text) ??
                                                0,
                                            goalCategory: selectedCategory,
                                          );
                                          await BudgetGoalsSupa().addGoal(
                                            goal,
                                            user!.id,
                                          );
                                          goalName.clear();
                                          goalAmnt.clear();
                                          Navigator.pop(context);
                                          await loadGoals();
                                        },
                                        child: Text("Add Goal"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Text(goals[index]['goal_name']),
                      Padding(
                        padding: EdgeInsetsGeometry.directional(bottom: 20),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.directional(start: 10),
                          ),
                          Text('Amount: ${goals[index]['goal_amount']}'),
                          Spacer(),
                          IconButton(
                            onPressed: () async {
                              await loadTxns();
                              if (transactions.isEmpty) return;
                              Map<String, dynamic> selectedTxn =
                                  transactions[0];
                              showDialog(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (ctx, setStateDialog) => AlertDialog(
                                    title: Text("Select Transaction"),
                                    backgroundColor: Colors.deepPurple[100],
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          DropdownButtonFormField(
                                            initialValue: selectedTxn,
                                            decoration: const InputDecoration(
                                              labelText: "Transaction",
                                            ),
                                            items: transactions.map((txn) {
                                              return DropdownMenuItem<
                                                Map<String, dynamic>
                                              >(
                                                value: txn,
                                                child: Text(
                                                  txn['title'] ?? 'Unkown',
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              setStateDialog(() {
                                                selectedTxn = val!;
                                              });
                                            },
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsGeometry.directional(
                                                  top: 10,
                                                ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final txnAmount =
                                                  (selectedTxn['amount']
                                                          as num?)
                                                      ?.toInt() ??
                                                  0;
                                              final currentProgress =
                                                  goals[index]['goal_progress'];
                                              final newProgress =
                                                  currentProgress + txnAmount;
                                              await BudgetGoalsSupa()
                                                  .addProgress(
                                                    goals[index]['goal_name'],
                                                    user!.id,
                                                    newProgress,
                                                  );
                                              Navigator.pop(context);
                                              await loadGoals();
                                            },
                                            child: Text("Add"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.add),
                          ),

                          Text('Progress: ${goals[index]['goal_progress']}'),
                          Padding(
                            padding: EdgeInsetsGeometry.directional(end: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
