import 'package:flutter/material.dart';
import 'package:financial_buddy/main.dart';

class TransactionsForm extends StatefulWidget {
  const TransactionsForm({super.key});

  @override
  State<StatefulWidget> createState() => _TransactionsFormState();
}

class _TransactionsFormState extends State<TransactionsForm> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();

  Future<void> submit() async {
    final amount = double.tryParse(amountController.text);
    if (amount == null) return;

    await supabase.from('initial_budget_list').insert({
      'amount': amount,
      'category': categoryController.text,
      'description': descriptionController.text,
      'today': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        TextField(
          controller: categoryController,
          decoration: const InputDecoration(labelText: 'Category'),
        ),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        ElevatedButton(onPressed: submit, child: const Text('Add')),
      ],
    );
  }
}
