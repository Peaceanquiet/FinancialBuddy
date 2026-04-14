import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:fl_chart/fl_chart.dart';

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

  final List<Color> _categoryColors = [
    const Color(0xFFAFA9EC),
    const Color(0xFF5DCAA5),
    const Color(0xFFFAC775),
    const Color(0xFFF09595),
    const Color(0xFF85B7EB),
    const Color(0xFF97C459),
    const Color(0xFFED93B1),
    const Color(0xFFB4B2A9),
  ];

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
      0, (sum, acc) => sum + (acc['balance'] as num).toDouble(),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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

  Widget _statCard(String label, String value, Color color) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    loadAccount();
    _loadDashboard();
  }

  @override
  void dispose() {
    accNameCtrlr.dispose();
    accBlncCtrlr.dispose();
    accTypeCtrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList();

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        title: const Text('Financial Destination',
            textScaler: TextScaler.linear(1.5)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: BuddyDrawer(title: "Financial Destination"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Accounts ──────────────────────────────────────────────
            const Text("Accounts",
                textScaler: TextScaler.linear(1.55),
                style: TextStyle(fontSize: 16, decorationThickness: 1.5)),
            accountInfo.isEmpty
                ? const Text("No accounts to display")
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: accountInfo.length,
                      itemBuilder: (context, index) {
                        final acc = accountInfo[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            height: 50,
                            width: 411,
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 15),
                                Text(acc['acc_name'],
                                    textScaler: const TextScaler.linear(1.25)),
                                const Spacer(),
                                Text("\$${acc['balance']}",
                                    textScaler: const TextScaler.linear(1.25)),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white70, size: 20),
                                  onPressed: () => _deleteAccount(
                                      acc['acc_id'].toString(), acc['acc_name']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.deepPurpleAccent,
                barrierColor: Colors.transparent,
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
                      ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.red)),
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
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text("Add Account"),
            ),

            const SizedBox(height: 24),

            // ── Total Balance ─────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Total Balance',
                      style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('\$${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Income / Expenses ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                    child: _statCard('Income',
                        '\$${totalIncome.toStringAsFixed(2)}',
                        Colors.green.shade800)),
                const SizedBox(width: 12),
                Expanded(
                    child: _statCard('Expenses',
                        '\$${totalExpenses.toStringAsFixed(2)}',
                        Colors.red.shade800)),
              ],
            ),
            const SizedBox(height: 20),

            // ── Donut Chart ───────────────────────────────────────────
            categoryTotals.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        const Text('Spending by Category',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.deepPurple)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 55,
                              sections: entries.asMap().entries.map((e) {
                                final i = e.key;
                                final cat = e.value;
                                final pct = totalExpenses > 0
                                    ? (cat.value / totalExpenses * 100)
                                    : 0.0;
                                return PieChartSectionData(
                                  value: cat.value,
                                  color: _categoryColors[
                                      i % _categoryColors.length],
                                  radius: 45,
                                  title: '${pct.toStringAsFixed(0)}%',
                                  titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ── Legend ────────────────────────────────────
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: entries.asMap().entries.map((e) {
                            final i = e.key;
                            final cat = e.value;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _categoryColors[
                                        i % _categoryColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${cat.key}  \$${cat.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      children: [
                        Icon(Icons.pie_chart_outline,
                            size: 40, color: Colors.deepPurple),
                        SizedBox(height: 8),
                        Text('No expense transactions yet',
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}