import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:financial_buddy/theme/app_theme.dart';
import 'package:financial_buddy/widgets/neon_cards.dart';
import 'package:financial_buddy/pages/expense_actions.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  final user = supabase.auth.currentUser;
  final goalNameCtrl = TextEditingController();
  final goalAmntCtrl = TextEditingController();
  List<Map<String, dynamic>> goals = [];
  List accounts = [];
  bool _isLoading = true;

  List<String> categories = [];
  String selectedCategory = 'Food';
  String? selectedAccountId;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    goalNameCtrl.dispose();
    goalAmntCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadGoals(), _loadAccounts(), _loadCategories()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadGoals() async {
    final response = await supabase
        .from("Budget_Goals")
        .select("goal_id, goal_name, goal_amount, goal_category, goal_progress, acc_link")
        .eq("user_id", user!.id);
    setState(() => goals = List<Map<String, dynamic>>.from(response));
  }

  Future<void> _loadAccounts() async {
    final response = await supabase
        .from('Accounts')
        .select('acc_id, acc_name')
        .eq('user_id', user!.id);
    setState(() => accounts = response);
  }

  Future<void> _loadCategories() async {
    final loaded = await loadCategories();
    setState(() => categories = loaded);
  }

  Future<void> _addGoal() async {
    final name = goalNameCtrl.text.trim();
    final amount = double.tryParse(goalAmntCtrl.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) return;

    await supabase.from("Budget_Goals").insert({
      'user_id': user!.id,
      'goal_name': name,
      'goal_amount': amount,
      'goal_category': selectedCategory,
      'goal_progress': 0,
      if (selectedAccountId != null) 'acc_link': selectedAccountId,
    });

    goalNameCtrl.clear();
    goalAmntCtrl.clear();
    selectedCategory = 'Food';
    selectedAccountId = null;
    await _loadGoals();
  }

  Future<void> _deleteGoal(String goalId) async {
    await supabase.from("Budget_Goals").delete().eq('goal_id', goalId);
    await _loadGoals();
  }

  Future<void> _updateProgress(String goalId, double currentProgress, double goalAmount) async {
    final ctrl = TextEditingController(text: currentProgress.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Progress'),
        content: TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Current amount saved (\$)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim());
              if (val != null && val >= 0) Navigator.pop(ctx, val);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await supabase.from("Budget_Goals")
          .update({'goal_progress': result}).eq('goal_id', goalId);
      await _loadGoals();
    }
  }

  Future<String?> _showCustomCategoryDialog() async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Category name'),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Name is required';
              if (val.trim().length < 2) return 'Must be at least 2 characters';
              if (categories.contains(val.trim())) return 'Category already exists';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final name = ctrl.text.trim();
                await saveCategory(name);
                await _loadCategories();
                if (ctx.mounted) Navigator.pop(ctx, name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final formKey = GlobalKey<FormState>();
    selectedCategory = 'Food';
    selectedAccountId = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('New Savings Goal'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: goalNameCtrl,
                    decoration: const InputDecoration(labelText: 'Goal Name'),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: goalAmntCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Target Amount (\$)'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Amount is required';
                      if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
                      if (double.parse(val.trim()) <= 0) return 'Must be greater than zero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) async {
                      if (val == 'Other') {
                        final newCat = await _showCustomCategoryDialog();
                        if (newCat != null) setStateDialog(() => selectedCategory = newCat);
                      } else {
                        setStateDialog(() => selectedCategory = val!);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Linked Account (optional)'),
                    value: selectedAccountId,
                    hint: const Text('Select account'),
                    items: accounts
                        .map<DropdownMenuItem<String>>((acc) => DropdownMenuItem(
                              value: acc['acc_id'].toString(),
                              child: Text(acc['acc_name']),
                            ))
                        .toList(),
                    onChanged: (val) => setStateDialog(() => selectedAccountId = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await _addGoal();
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Color getRotatingAccentColor(int index) {
    final colors = [AppColors.primaryPink, AppColors.accentBlue, AppColors.neonGreen];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text(' '),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: BuddyDrawer(title: "Finances"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // -- Header -------------------------------------
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: NeonCard(
                    backgroundColor: AppColors.darkSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Text("Savings Goals",
                            style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text("Goals: ${goals.length}",
                            style: const TextStyle(color: AppColors.mutedText)),
                        const SizedBox(width: 10),
                        Container(
                          decoration: const BoxDecoration(
                              color: AppColors.neonGreen, shape: BoxShape.circle),
                          child: IconButton(
                            onPressed: _showAddGoalDialog,
                            icon: const Icon(Icons.add, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- Goals list ---------------------------
                Expanded(
                  child: goals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flag_outlined,
                                  size: 60, color: AppColors.mutedText),
                              const SizedBox(height: 16),
                              const Text('No savings goals yet',
                                  style: TextStyle(
                                      color: AppColors.mutedText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Tap the + button to create your first goal.',
                                  style:
                                      TextStyle(color: AppColors.mutedText, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: goals.length,
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final goalAmount = (goal['goal_amount'] as num).toDouble();
                            final progress = (goal['goal_progress'] as num).toDouble();
                            final percent =
                                goalAmount > 0 ? (progress / goalAmount).clamp(0.0, 1.0) : 0.0;
                            final goalId = goal['goal_id'].toString();

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: NeonCard(
                                backgroundColor: AppColors.darkSurface,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            color: getRotatingAccentColor(index),
                                          ),
                                          child: const Icon(Icons.flag, color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(goal['goal_name'] ?? '',
                                                  style: const TextStyle(
                                                      color: AppColors.textWhite,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16)),
                                              const SizedBox(height: 2),
                                              Text(goal['goal_category'] ?? '',
                                                  style: const TextStyle(
                                                      color: AppColors.mutedText, fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Text('\$$progress of \$$goalAmount',
                                                  style: const TextStyle(
                                                      color: AppColors.mutedText, fontSize: 12)),
                                              const SizedBox(height: 8),
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: LinearProgressIndicator(
                                                  value: percent,
                                                  minHeight: 6,
                                                  backgroundColor: AppColors.darkCard,
                                                  valueColor: AlwaysStoppedAnimation(
                                                      getRotatingAccentColor(index)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${(percent * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              color: AppColors.textWhite,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                          onPressed: () =>
                                              _updateProgress(goalId, progress, goalAmount),
                                          icon: const Icon(Icons.edit,
                                              size: 14, color: AppColors.accentBlue),
                                          label: const Text('Update',
                                              style: TextStyle(
                                                  fontSize: 12, color: AppColors.accentBlue)),
                                        ),
                                        const SizedBox(width: 12),
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                          onPressed: () => _deleteGoal(goalId),
                                          icon: const Icon(Icons.delete,
                                              size: 14, color: AppColors.danger),
                                          label: const Text('Delete',
                                              style: TextStyle(
                                                  fontSize: 12, color: AppColors.danger)),
                                        ),
                                      ],
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