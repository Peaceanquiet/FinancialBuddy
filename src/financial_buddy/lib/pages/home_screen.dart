import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';
import 'package:financial_buddy/widgets/transactionsform.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final List<Transaction> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];

          return ListTile(
            leading: Text("\$${tx.tAmount.toStringAsFixed(0)}"),
            title: Text(tx.tCategory),
            subtitle: Text(tx.tDescription),
            trailing: Text("${tx.tDate.month}/${tx.tDate.day}/${tx.tDate.day}"),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.deepPurple,
        child: TransactionsForm(),
      ),
    );
  }
}
