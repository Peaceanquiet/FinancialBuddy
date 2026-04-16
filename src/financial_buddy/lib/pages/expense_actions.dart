import '../widgets/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> editTransaction(
  Transaction tx,
  String newTitle,
  double newAmount,
  String newType,
  String newCategory,
) async {
  final supabase = Supabase.instance.client;
  await supabase
      .from('transactions')
      .update({
        'amount': newAmount,
        'title': newTitle,
        'date': DateTime.now().toIso8601String(),
        'type': newType,
        'category': newCategory,
      })
      .eq('id', tx.tID);
}

Future<void> deleteTransaction(Transaction tx) async {
  final supabase = Supabase.instance.client;
  await supabase.from('transactions').delete().eq('id', tx.tID);
}

Future<Transaction> addTransaction(
  String title,
  double amount,
  String accountId,
  String type,
  String category,
) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  try {
    final response = await supabase
        .from('transactions')
        .insert({
          'user_id': user!.id,
          'amount': amount,
          'title': title,
          'date': DateTime.now().toIso8601String(),
          'account_id': accountId,
          'type': type,
          'category': category,
        })
        .select()
        .single();

    return Transaction(
      response['id'].toString(),
      amount,
      title,
      category,
      DateTime.now(),
      accountId,
      type,
    );
  } catch (e) {
    print('ERROR inserting transaction: $e');
    rethrow;
  }
}

Future<List<Transaction>> loadTransactions() async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('transactions')
        .select('*, Accounts(acc_name)')
        .eq('user_id', user!.id);

    return response.map<Transaction>((row) {
      final accName = row['Accounts']?['acc_name'] ?? 'Unknown';
      return Transaction(
        row['id'].toString(),
        (row['amount'] as num).toDouble(),
        row['title'] ?? '',
        row['category'] ?? 'Other',
        DateTime.parse(row['date']),
        accName,
        row['type'] ?? 'Expense',
      );
    }).toList();
  } catch (e) {
    print('ERROR: $e');
    rethrow;
  }
}
