import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';
import 'expense_actions.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPage();
}

class _TransactionsPage extends State<TransactionsPage> {
  // List of transactions displayed on the home screen
  final List<Transaction> transactions = [];

  // Loads all transactions from Supabase and updates the local list
  Future<void> _loadTransactions() async {
    final loadedTransactions = await loadTransactions();
    setState(() {
      transactions.clear();
      transactions.addAll(loadedTransactions);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Load transactions on startup
  }

  // Adds a new transaction to Supabase and reloads the list from Supabase
  void _addTransaction(String title, double amount) async {
    await addTransaction(title, amount); // Insert into Supabase
    await _loadTransactions(); // Reload from Supabase to display
  }

  // Edits a transaction in Supabase and reloads the list
  void _editTransaction(int index, String newTitle, double newAmount) async {
    await editTransaction(transactions, index, newTitle, newAmount);
    await _loadTransactions();
  }

  // Deletes a transaction in Supabase and reloads the list
  void _deleteTransaction(int index) async {
    await deleteTransaction(transactions, index);
    await _loadTransactions();
  }

  // Shows a dialog to add a new expense
  void _showAddExpenseDialog() {
    String title = '';
    String price = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (val) => title = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (val) => price = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty && double.tryParse(price) != null) {
                _addTransaction(title, double.parse(price));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Shows a dialog to edit an existing expense
  void _showEditExpenseDialog(int index) {
    String title = transactions[index].tCategory;
    String price = transactions[index].tAmount.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: TextEditingController(text: title),
              onChanged: (val) => title = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: price),
              onChanged: (val) => price = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty && double.tryParse(price) != null) {
                _editTransaction(index, title, double.parse(price));
                Navigator.of(ctx).pop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      // List of transactions
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            leading: Text("\$${tx.tAmount.toStringAsFixed(0)}"),
            title: Text(tx.tCategory),
            subtitle: Text(tx.tDescription),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditExpenseDialog(index);
                  },
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteTransaction(index);
                  },
                ),
                // Date display
                Text("${tx.tDate.month}/${tx.tDate.day}/${tx.tDate.year}"),
              ],
            ),
          );
        },
      ),
      // Plus button to add a new expense
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 10),
          child: FloatingActionButton(
            onPressed: _showAddExpenseDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
