import 'package:financial_buddy/widgets/transaction.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import 'package:financial_buddy/main.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  ListTileTitleAlignment? titleAlignment;
  List transactions = [];
  final user = supabase.auth.currentUser;

  Future<void> loadTransactions() async {
    final response = await supabase
        .from("Transactions")
        .select('title, description, category, amount, date')
        .eq('user_id', user!.id);

    setState(() {
      transactions = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),

      body: Column(
        children: <Widget>[
          const Divider(),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text('title'),
            subtitle: Text("Merchant Information"),
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
