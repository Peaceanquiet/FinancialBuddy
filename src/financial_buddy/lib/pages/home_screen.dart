import 'package:financial_buddy/main.dart';
import 'transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:financial_buddy/theme/app_theme.dart';
import 'package:financial_buddy/widgets/neon_cards.dart';
import 'package:financial_buddy/widgets/gradient_button.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = supabase.auth.currentUser;
  final accNameCtrlr = TextEditingController();
  final accTypeCtrlr = TextEditingController();
  final accBlncCtrlr = TextEditingController();
  List accountInfo = [];
  double totalBalance = 0;
  double totalIncome = 0;
  double totalExpenses = 0;
  Map<String, double> categoryTotals = {};
  String? firstName;
  bool _isLoading = true;

  Future<void> _loadProfile() async {
    final data = await supabase
        .from('profiles')
        .select('first_name')
        .eq('id', user!.id)
        .single();
    setState(() => firstName = data['first_name'] ?? '');
  }

  Future<void> loadAccount() async {
    final response = await supabase
        .from("Accounts")
        .select('acc_id, acc_name, type, balance')
        .eq('user_id', user!.id);
    setState(() => accountInfo = response);
  }

  Future<void> _loadDashboard() async {
    final txData = await supabase
        .from('transactions')
        .select('amount, type, category')
        .eq('user_id', user!.id);

    final accData = await supabase
        .from('Accounts')
        .select('balance')
        .eq('user_id', user!.id);

    double income = 0, expenses = 0;
    Map<String, double> cats = {};

    for (final tx in txData) {
      final amount = (tx['amount'] as num).toDouble();
      if (tx['type'] == 'Income') {
        income += amount;
      } else {
        expenses += amount;
        final cat = tx['category'] ?? 'Other';
        cats[cat] = (cats[cat] ?? 0) + amount;
      }
    }

    final balance = accData.fold<double>(
      0,
      (sum, acc) => sum + (acc['balance'] as num).toDouble(),
    );

    final sortedCats = Map.fromEntries(
      cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    setState(() {
      totalBalance = balance;
      totalIncome = income;
      totalExpenses = expenses;
      categoryTotals = sortedCats;
    });
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadProfile(), loadAccount(), _loadDashboard()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteAccount(String accId, String accName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "$accName"?\n\nThis will also delete all transactions associated with this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.textWhite,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabase.from('transactions').delete().eq('account_id', accId);
      await supabase.from('Accounts').delete().eq('acc_id', accId);
      await loadAccount();
      await _loadDashboard();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _statCard(String label, String value, Color color) => NeonCard(
    gradient: AppGradients.cardGradient,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    accNameCtrlr.dispose();
    accBlncCtrlr.dispose();
    accTypeCtrlr.dispose();
    super.dispose();
  }

  List<Color> chartColors = [
    AppColors.primaryPink,
    AppColors.accentBlue,
    AppColors.neonGreen,
    AppColors.primaryPink.withValues(alpha: 0.7),
    AppColors.accentBlue.withValues(alpha: 0.7),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text(' '),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: BuddyDrawer(title: "Financial Destination"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ---------------------- Greeting ----------------------
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hello,',
                            style: TextStyle(color: AppColors.textWhite, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          firstName ?? '',
                          style: const TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Your financial summary',
                            style: TextStyle(color: AppColors.mutedText, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------------- Total Balance ----------------------
                  SizedBox(
                    width: double.infinity,
                    child: NeonCard(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      gradient: AppGradients.neonGradient,
                      child: Column(
                        children: [
                          const Text('Total Balance',
                              style: TextStyle(fontSize: 20, color: AppColors.textWhite)),
                          const SizedBox(height: 6),
                          Text(
                            '\$${totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---------------------- Income / Expenses ----------------------
                  Row(
                    children: [
                      Expanded(
                        child: _statCard('Income', '\$${totalIncome.toStringAsFixed(2)}',
                            AppColors.neonGreen),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard('Expenses', '\$${totalExpenses.toStringAsFixed(2)}',
                            AppColors.danger),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---------------------- Donut Chart ----------------------
                  categoryTotals.isNotEmpty
                      ? NeonCard(
                          backgroundColor: AppColors.darkSurface,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Spending Overview',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textWhite)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 145,
                                    height: 145,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 38,
                                        sections: entries.asMap().entries.map((e) {
                                          final i = e.key;
                                          final cat = e.value;
                                          return PieChartSectionData(
                                            value: cat.value,
                                            color: chartColors[i % chartColors.length],
                                            radius: 28,
                                            title: '',
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      children: entries.asMap().entries.map((e) {
                                        final i = e.key;
                                        final cat = e.value;
                                        final pct = totalExpenses > 0
                                            ? (cat.value / totalExpenses * 100)
                                            : 0.0;
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: chartColors[i % chartColors.length],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(cat.key,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.mutedText)),
                                              ),
                                              Text('${pct.toStringAsFixed(0)}%',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textWhite,
                                                      fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : NeonCard(
                          backgroundColor: AppColors.darkSurface,
                          padding: const EdgeInsets.all(24),
                          child: const Column(
                            children: [
                              Icon(Icons.pie_chart_outline, size: 40, color: AppColors.mutedText),
                              SizedBox(height: 8),
                              Text('No expense transactions yet',
                                  style: TextStyle(
                                      color: AppColors.mutedText,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Add a transaction to see your spending breakdown.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                            ],
                          ),
                        ),
                  const SizedBox(height: 24),

                  // ---------------------- Accounts ----------------------
                  const Text("Accounts",
                      textScaler: TextScaler.linear(1.55),
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  accountInfo.isEmpty
                      ? NeonCard(
                          backgroundColor: AppColors.darkSurface,
                          padding: const EdgeInsets.all(24),
                          child: const Column(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined,
                                  size: 40, color: AppColors.mutedText),
                              SizedBox(height: 8),
                              Text('No accounts yet',
                                  style: TextStyle(
                                      color: AppColors.mutedText,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Tap "Add Account" below to get started.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: accountInfo.length,
                            itemBuilder: (context, index) {
                              final acc = accountInfo[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TransactionsPage(
                                        filterAccountId: acc['acc_id'].toString(),
                                        filterAccountName: acc['acc_name'],
                                      ),
                                    ),
                                  ),
                                  child: NeonCard(
                                    gradient: AppGradients.cardGradient,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: SizedBox(
                                      height: 50,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 15),
                                          Text(acc['acc_name'],
                                              style: const TextStyle(
                                                  fontSize: 18, color: AppColors.textWhite)),
                                          const Spacer(),
                                          Text("\$${acc['balance']}",
                                              style: const TextStyle(
                                                  fontSize: 18, color: AppColors.textWhite)),
                                          const SizedBox(width: 6),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: AppColors.danger, size: 20),
                                            onPressed: () => _deleteAccount(
                                                acc['acc_id'].toString(), acc['acc_name']),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  const Padding(padding: EdgeInsets.all(5)),

                  // ---------------------- Add Account Button ----------------------
                  GradientButton(
                    text: "Add Account",
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.darkSurface,
                      isScrollControlled: true,
                      builder: (_) => Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(padding: EdgeInsets.all(5)),
                            TextFormField(
                              controller: accNameCtrlr,
                              decoration: const InputDecoration(
                                  hintText: "Account Name",
                                  contentPadding: EdgeInsets.all(10)),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            TextFormField(
                              controller: accTypeCtrlr,
                              decoration: const InputDecoration(
                                  hintText: "Account Type (Checking, Savings, Etc.)",
                                  contentPadding: EdgeInsets.all(10)),
                            ),
                            const Padding(padding: EdgeInsets.all(5)),
                            TextFormField(
                              controller: accBlncCtrlr,
                              decoration: const InputDecoration(
                                  hintText: "Initial Balance",
                                  contentPadding: EdgeInsets.all(10)),
                            ),
                            const Padding(padding: EdgeInsets.all(25)),
                            GradientButton(
                              text: "Save",
                              onPressed: () async {
                                try {
                                  await supabase.from('Accounts').insert({
                                    'user_id': user!.id,
                                    'acc_name': accNameCtrlr.text.trim(),
                                    'type': accTypeCtrlr.text.trim(),
                                    'balance': toDouble(accBlncCtrlr.text.trim()),
                                  });
                                  await loadAccount();
                                  await _loadDashboard();
                                  accNameCtrlr.clear();
                                  accTypeCtrlr.clear();
                                  accBlncCtrlr.clear();
                                  if (context.mounted) Navigator.pop(context);
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}