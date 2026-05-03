import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';
import 'package:financial_buddy/main.dart';
import 'expense_actions.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:financial_buddy/theme/app_theme.dart';
import 'package:financial_buddy/widgets/neon_cards.dart';

class TransactionsPage extends StatefulWidget {
  final String? filterAccountId;
  final String? filterAccountName;
  const TransactionsPage({super.key, this.filterAccountId, this.filterAccountName});

  @override
  State<TransactionsPage> createState() => _TransactionsPage();
}

class _TransactionsPage extends State<TransactionsPage> {
  final List<Transaction> transactions = [];
  List accounts = [];
  bool _isLoading = true;

  String selectedCategoryFilter = 'All';
  List<String> categories = [];
  final List<String> types = ['Expense', 'Income'];

  Future<void> _loadTransactions() async {
    final loaded = await loadTransactions(accountId: widget.filterAccountId);
    setState(() {
      transactions.clear();
      transactions.addAll(loaded);
    });
  }

  Future<void> _loadCategories() async {
    final loaded = await loadCategories();
    setState(() => categories = loaded);
  }

  Future<void> _loadAccounts() async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('Accounts')
        .select('acc_id, acc_name')
        .eq('user_id', user!.id);
    setState(() => accounts = response);
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadTransactions(), _loadAccounts(), _loadCategories()]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _addTransaction(String title, double amount, String accountId, String type, String category) async {
    await addTransaction(title, amount, accountId, type, category);
    await _loadTransactions();
  }

  void _editTransaction(Transaction tx, String newTitle, double newAmount, String newType, String newCategory) async {
    final index = transactions.indexOf(tx);
    await editTransaction(transactions, index, newTitle, newAmount, newType, newCategory);
    await _loadTransactions();
  }

  void _deleteTransaction(Transaction tx) async {
    final index = transactions.indexOf(tx);
    await deleteTransaction(transactions, index);
    await _loadTransactions();
  }

  void _confirmDeleteTransaction(Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteTransaction(tx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.textWhite)),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedAccountId;
    String selectedType = 'Expense';
    String selectedCategory = 'Food';
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
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Title is required';
                      if (val.trim().length < 2) return 'Title must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Amount is required';
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null) return 'Enter a valid number (e.g. 12.50)';
                      if (parsed <= 0) return 'Amount must be greater than zero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    initialValue: selectedType,
                    items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setStateDialog(() => selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
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
                    decoration: const InputDecoration(labelText: 'Account'),
                    initialValue: selectedAccountId,
                    hint: const Text('Select an account'),
                    items: accounts.map<DropdownMenuItem<String>>((acc) {
                      return DropdownMenuItem(
                        value: acc['acc_id'].toString(),
                        child: Text(acc['acc_name']),
                      );
                    }).toList(),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please select an account';
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
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
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

  void _showEditExpenseDialog(Transaction tx) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: tx.tTitle);
    final amountController = TextEditingController(text: tx.tAmount.toString());
    String selectedType = tx.tType;
    String selectedCategory = categories.contains(tx.tCategory) ? tx.tCategory : 'Other';

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
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Title is required';
                      if (val.trim().length < 2) return 'Title must be at least 2 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Amount is required';
                      final parsed = double.tryParse(val.trim());
                      if (parsed == null) return 'Enter a valid number (e.g. 12.50)';
                      if (parsed <= 0) return 'Amount must be greater than zero';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    initialValue: selectedType,
                    items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setStateDialog(() => selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) async {
                      if (val == 'Other') {
                        final newCat = await _showCustomCategoryDialog();
                        if (newCat != null) setStateDialog(() => selectedCategory = newCat);
                      } else {
                        setStateDialog(() => selectedCategory = val!);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _editTransaction(tx, titleController.text.trim(),
                      double.parse(amountController.text.trim()), selectedType, selectedCategory);
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

  Color getRotatingAccentColor(int index) {
    final colors = [AppColors.primaryPink, AppColors.accentBlue, AppColors.neonGreen];
    return colors[index % colors.length];
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Housing': return Icons.home;
      case 'Entertainment': return Icons.movie;
      case 'Health': return Icons.favorite;
      case 'Shopping': return Icons.shopping_bag;
      case 'Salary': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  String formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final check = DateTime(date.year, date.month, date.day);
    if (check == today) return "Today";
    if (check == yesterday) return "Yesterday";
    return "${date.month}/${date.day}/${date.year}";
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
                try {
                  await saveCategory(name);
                  await _loadCategories();
                  if (ctx.mounted) Navigator.pop(ctx, name);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var filteredTransactions = selectedCategoryFilter == 'All'
        ? transactions
        : transactions.where((tx) => tx.tCategory == selectedCategoryFilter).toList();
    filteredTransactions.sort((a, b) => b.tDate.compareTo(a.tDate));

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => selectedCategoryFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text("All")),
              ...categories.map((c) => PopupMenuItem(value: c, child: Text(c))),
            ],
          ),
        ],
        title: Text(widget.filterAccountName ?? 'Transactions'),
        centerTitle: true,
      ),
      drawer: BuddyDrawer(title: "Transactions"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 60, color: AppColors.mutedText),
                      const SizedBox(height: 16),
                      Text(
                        selectedCategoryFilter == 'All'
                            ? 'No transactions yet'
                            : 'No "$selectedCategoryFilter" transactions',
                        style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button to add your first transaction.',
                        style: TextStyle(color: AppColors.mutedText, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = filteredTransactions[index];
                    final currentDate = formatDateLabel(tx.tDate);
                    final bool showDateHeader = index == 0 ||
                        formatDateLabel(filteredTransactions[index - 1].tDate) != currentDate;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
                            child: Text(currentDate,
                                style: const TextStyle(
                                    color: AppColors.mutedText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: NeonCard(
                            backgroundColor: AppColors.darkSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: getRotatingAccentColor(index),
                                      ),
                                      child: Icon(getCategoryIcon(tx.tCategory),
                                          color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tx.tTitle,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textWhite)),
                                          const SizedBox(height: 2),
                                          Text(tx.tCategory,
                                              style: const TextStyle(
                                                  fontSize: 12, color: AppColors.mutedText)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
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
                                        const SizedBox(height: 4),
                                        Text(
                                          '${tx.tDate.month}/${tx.tDate.day}/${tx.tDate.year}',
                                          style: const TextStyle(
                                              fontSize: 12, color: AppColors.mutedText),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(color: AppColors.darkSurface, height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet,
                                        size: 12, color: AppColors.accentBlue),
                                    const SizedBox(width: 4),
                                    Text(tx.tAccount,
                                        style: const TextStyle(
                                            fontSize: 12, color: AppColors.accentBlue)),
                                    const Spacer(),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                      onPressed: () => _showEditExpenseDialog(tx),
                                      icon: const Icon(Icons.edit,
                                          size: 14, color: AppColors.accentBlue),
                                      label: const Text('Edit',
                                          style: TextStyle(
                                              fontSize: 12, color: AppColors.accentBlue)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                      onPressed: () => _confirmDeleteTransaction(tx),
                                      icon: const Icon(Icons.delete,
                                          size: 14, color: AppColors.danger),
                                      label: const Text('Delete',
                                          style:
                                              TextStyle(fontSize: 12, color: AppColors.danger)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.textWhite,
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}