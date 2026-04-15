import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';
import 'package:financial_buddy/main.dart';
import 'expense_actions.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:financial_buddy/theme/app_theme.dart';

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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteTransaction(index);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.textWhite),
              ),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    // Use a GlobalKey to access the Form state for validation
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedAccountId;
    String selectedType = 'Expense';
    String selectedCategory = 'Food';
    // Track whether account dropdown was touched without a selection
    bool accountTouched = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Title ──────────────────────────────────────────────
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (val.trim().length < 2) {
                        return 'Title must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // ── Amount ─────────────────────────────────────────────
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null) {
                        return 'Enter a valid number (e.g. 12.50)';
                      }
                      if (parsed <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Type ───────────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    initialValue: selectedType,
                    items: types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) =>
                        setStateDialog(() => selectedType = val!),
                    // Type always has a default, so no validator needed
                  ),
                  const SizedBox(height: 12),

                  // ── Category ───────────────────────────────────────────
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

                  // ── Account ────────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      // Show the error inline via the form validator below
                    ),
                    initialValue: selectedAccountId,
                    hint: const Text('Select an account'),
                    items: accounts.map<DropdownMenuItem<String>>((acc) {
                      return DropdownMenuItem(
                        value: acc['acc_id'].toString(),
                        child: Text(acc['acc_name']),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select an account';
                      }
                      return null;
                    },
                    onChanged: (val) => setStateDialog(() {
                      selectedAccountId = val;
                      accountTouched = true;
                    }),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Trigger all validators at once; red messages appear inline
                if (formKey.currentState!.validate()) {
                  _addTransaction(
                    titleController.text.trim(),
                    double.parse(amountController.text.trim()),
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
    final formKey = GlobalKey<FormState>();
    final tx = transactions[index];
    final titleController = TextEditingController(text: tx.tTitle);
    final amountController = TextEditingController(text: tx.tAmount.toString());
    String selectedType = tx.tType;
    String selectedCategory = categories.contains(tx.tCategory)
        ? tx.tCategory
        : 'Other';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Title ──────────────────────────────────────────────
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (val.trim().length < 2) {
                        return 'Title must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // ── Amount ─────────────────────────────────────────────
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Amount is required';
                      }
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null) {
                        return 'Enter a valid number (e.g. 12.50)';
                      }
                      if (parsed <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Type ───────────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    initialValue: selectedType,
                    items: types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) =>
                        setStateDialog(() => selectedType = val!),
                  ),
                  const SizedBox(height: 12),

                  // ── Category ───────────────────────────────────────────
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) =>
                        setStateDialog(() => selectedCategory = val!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _editTransaction(
                    index,
                    titleController.text.trim(),
                    double.parse(amountController.text.trim()),
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
  //
  //



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
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
                  color: AppColors.darkSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tx.tTitle,
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
                                  ? AppColors.neonGreen
                                  : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  size: 14,
                                  color: AppColors.accentBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tx.tAccount,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${tx.tDate.month}/${tx.tDate.day}/${tx.tDate.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.category,
                              size: 14,
                              color: AppColors.mutedText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tx.tCategory,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showEditExpenseDialog(index),
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.accentBlue,
                              ),
                              label: const Text(
                                'Edit',
                                style: TextStyle(color: AppColors.accentBlue),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _confirmDeleteTransaction(index),
                              icon: const Icon(
                                Icons.delete,
                                size: 16,
                                color: AppColors.danger,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.danger),
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
