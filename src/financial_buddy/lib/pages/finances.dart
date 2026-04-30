import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:financial_buddy/theme/app_theme.dart';
import 'package:financial_buddy/widgets/neon_cards.dart';
import 'package:financial_buddy/widgets/gradient_button.dart';
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
        .eq("goal_name", goalName)
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

  Color getRotatingAccentColor(int index) {
    final colors = [
      AppColors.primaryPink,
      AppColors.accentBlue,
      AppColors.neonGreen,
    ];

    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text(' '),
        centerTitle: true,
        backgroundColor: AppColors.backgroundBlack,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: NeonCard(
              backgroundColor: AppColors.darkSurface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text(
                    "Savings Goals",
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "Goals: ${goals.length}",
                    style: const TextStyle(
                      color: AppColors.mutedText,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // KEEP your existing dialog logic here
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final goalAmount = goal['goal_amount'] ?? 0;
              final progress = goal['goal_progress'] ?? 0;
              final percent =
                  goalAmount > 0 ? (progress / goalAmount).clamp(0.0, 1.0) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: NeonCard(
                  backgroundColor: AppColors.darkSurface,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // ---------------- ICON ----------------
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: getRotatingAccentColor(index),
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ---------------- TEXT + PROGRESS ----------------
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['goal_name'] ?? '',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '\$$progress of \$$goalAmount',
                              style: const TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ---------------- PROGRESS BAR ----------------
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      getRotatingAccentColor(index),
                                      getRotatingAccentColor(index)
                                          .withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                      const AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ---------------- % ----------------
                      Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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