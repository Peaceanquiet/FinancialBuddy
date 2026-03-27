import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';
import 'package:financial_buddy/main.dart';
import 'expense_actions.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPage();
}

class _TransactionsPage extends State<TransactionsPage> {
  final List<Transaction> transactions = [];
  List accounts = [];

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
  final List<String> types = ['Expense', 'Income'];

  Future<void> _loadTransactions() async {
    final loaded = await loadTransactions();
    setState(() {
      transactions.clear();
      transactions.addAll(loaded);
    });
  }

  Future<void> _loadAccounts() async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('Accounts')
        .select('acc_id, acc_name')
        .eq('user_id', user!.id);
    setState(() {
      accounts = response;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _loadAccounts();
  }

  void _addTransaction(
    String title,
    double amount,
    String accountId,
    String type,
    String category,
  ) async {
    await addTransaction(title, amount, accountId, type, category);
    await _loadTransactions();
  }

  void _editTransaction(
    int index,
    String newTitle,
    double newAmount,
    String newType,
    String newCategory,
  ) async {
    await editTransaction(
      transactions,
      index,
      newTitle,
      newAmount,
      newType,
      newCategory,
    );
    await _loadTransactions();
  }

  void _deleteTransaction(int index) async {
    await deleteTransaction(transactions, index);
    await _loadTransactions();
  }

  void _confirmDeleteTransaction(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteTransaction(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    String title = '';
    String price = '';
    String? selectedAccountId;
    String selectedType = 'Expense';
    String selectedCategory = 'Food';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: (val) => title = val,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => price = val,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  initialValue: selectedType,
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setStateDialog(() => selectedType = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  initialValue: selectedCategory,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Account'),
                  initialValue: selectedAccountId,
                  items: accounts.map<DropdownMenuItem<String>>((acc) {
                    return DropdownMenuItem(
                      value: acc['acc_id'].toString(),
                      child: Text(acc['acc_name']),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedAccountId = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty &&
                    double.tryParse(price) != null &&
                    selectedAccountId != null) {
                  _addTransaction(
                    title,
                    double.parse(price),
                    selectedAccountId!,
                    selectedType,
                    selectedCategory,
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExpenseDialog(int index) {
    final tx = transactions[index];
    String title = tx.tTitle;
    String price = tx.tAmount.toString();
    String selectedType = tx.tType;
    String selectedCategory = categories.contains(tx.tCategory)
        ? tx.tCategory
        : 'Other';
    String? selectedAccountId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  controller: TextEditingController(text: title),
                  onChanged: (val) => title = val,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: price),
                  onChanged: (val) => price = val,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type'),
                  initialValue: selectedType,
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setStateDialog(() => selectedType = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  initialValue: selectedCategory,
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedCategory = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Account'),
                  initialValue: selectedAccountId,
                  items: accounts.map<DropdownMenuItem<String>>((acc) {
                    return DropdownMenuItem(
                      value: acc['acc_id'].toString(),
                      child: Text(acc['acc_name']),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedAccountId = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty && double.tryParse(price) != null) {
                  _editTransaction(
                    index,
                    title,
                    double.parse(price),
                    selectedType,
                    selectedCategory,
                  );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Transactions'),
        centerTitle: true,
      ),
      drawer: BuddyDrawer(title: "Transactions"),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: title + amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tx.tTitle, // was tx.tCategory
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              tx.tType == 'Income'
                                  ? '+\$${tx.tAmount.toStringAsFixed(2)}'
                                  : '-\$${tx.tAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: tx.tType == 'Income'
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Account + date row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  size: 14,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tx.tAccount,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${tx.tDate.month}/${tx.tDate.day}/${tx.tDate.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Category row
                        Row(
                          children: [
                            const Icon(
                              Icons.category,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tx.tCategory,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        // Edit + Delete buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditExpenseDialog(index),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _confirmDeleteTransaction(index),
                              icon: const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
