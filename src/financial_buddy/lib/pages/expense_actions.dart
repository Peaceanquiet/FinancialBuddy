// This file contains functions to edit and delete transactions both in-memory and in the Supabase database.
import '../widgets/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Edits a transaction in the local list and updates it in Supabase.
Future<void> editTransaction(List<Transaction> transactions, int index, String newTitle, double newAmount) async {
  final supabase = Supabase.instance.client;
  final tx = transactions[index];
  // Update the transaction in the local list
  transactions[index] = Transaction(
    tx.tID,
    newAmount,
    newTitle,
    DateTime.now(),
    tx.tDescription,
  );
  // Update the transaction in Supabase
  await supabase.from('transactions').update({
    'amount': newAmount,
    'title': newTitle,
    'date': DateTime.now().toIso8601String(),
  }).eq('id', tx.tID);
}

// Deletes a transaction from the local list and removes it from Supabase.
Future<void> deleteTransaction(List<Transaction> transactions, int index) async {
  final supabase = Supabase.instance.client;
  final tx = transactions[index];
  // Remove from local list
  transactions.removeAt(index);
  // Delete from Supabase
  await supabase.from('transactions').delete().eq('id', tx.tID);
}


Future<Transaction> addTransaction(String title, double amount) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  try {
    print('Inserting transaction: title=$title, amount=$amount');
    
    final response = await supabase.from('transactions').insert({
      'user_id': user!.id,
      'amount': amount,
      'title': title,
      'date': DateTime.now().toIso8601String(),
    }).select().single();
    
    print('Insert response: $response');

    return Transaction(
      response['id'].toString(),
      amount,
      title,
      DateTime.now(),
      '',
    );
  } catch (e) {
    print('ERROR inserting transaction: $e');
    rethrow;
  }
}

// Loads all transactions from Supabase
Future<List<Transaction>> loadTransactions() async {
  try {
    
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    print('Fetching transactions...');
    final response = await supabase.from('transactions').select().eq('user_id', user!.id);;
    print('Response: $response');
    
    final transactions = <Transaction>[];
    for (final row in response) {
      transactions.add(Transaction(
        row['id'].toString(),
        (row['amount'] as num).toDouble(),
        row['title'] ?? '',
        DateTime.parse(row['date']),
        row['description'] ?? '',
      ));
    }
    return transactions;
  } catch (e) {
    print('ERROR: $e');
    rethrow;
  }
}
