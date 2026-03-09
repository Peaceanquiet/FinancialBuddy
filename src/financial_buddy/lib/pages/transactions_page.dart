import 'package:flutter/material.dart';
//import 'package:financial_buddy/main.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  ListTileTitleAlignment? titleAlignment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: <Widget>[
          const Divider(),
          ListTile(
            titleAlignment: titleAlignment,
            leading: Checkbox(value: true, onChanged: (bool? value) {}),
            title: const Text("Transaction Description"),
            subtitle: const Text("Merchant Information"),
            trailing: const Text("Cash Amount"),
          ),
          const Divider(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
