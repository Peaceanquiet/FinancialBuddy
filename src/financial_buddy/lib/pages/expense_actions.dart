import '../widgets/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> editTransaction(List<Transaction> transactions, int index,
    String newTitle, double newAmount, String newType, String newCategory) async {
  final supabase = Supabase.instance.client;
  final tx = transactions[index];

  // Update account balance using acc_id
  final accountResponse = await supabase
      .from('Accounts')
      .select('balance')
      .eq('acc_id', tx.tAccountId)
      .single();

  final currentBalance = (accountResponse['balance'] as num).toDouble();
  final afterUndo = tx.tType == 'Income'
      ? currentBalance - tx.tAmount
      : currentBalance + tx.tAmount;
  final newBalance = newType == 'Income'
      ? afterUndo + newAmount
      : afterUndo - newAmount;

  await supabase
      .from('Accounts')
      .update({'balance': newBalance})
      .eq('acc_id', tx.tAccountId);

  transactions[index] = Transaction(
    tx.tID, newAmount, newTitle, newCategory,
    DateTime.now(), tx.tAccount, tx.tAccountId, newType,
  );

  await supabase.from('transactions').update({
    'amount': newAmount,
    'title': newTitle,
    'date': DateTime.now().toIso8601String(),
    'type': newType,
    'category': newCategory,
  }).eq('id', tx.tID);
}

Future<void> deleteTransaction(List<Transaction> transactions, int index) async {
  final supabase = Supabase.instance.client;
  final tx = transactions[index];

  // Reverse balance using acc_id
  final accountResponse = await supabase
      .from('Accounts')
      .select('balance')
      .eq('acc_id', tx.tAccountId)
      .single();

  final currentBalance = (accountResponse['balance'] as num).toDouble();
  final newBalance = tx.tType == 'Income'
      ? currentBalance - tx.tAmount
      : currentBalance + tx.tAmount;

  await supabase
      .from('Accounts')
      .update({'balance': newBalance})
      .eq('acc_id', tx.tAccountId);

  transactions.removeAt(index);
  await supabase.from('transactions').delete().eq('id', tx.tID);
}

Future<Transaction> addTransaction(
    String title, double amount, String accountId, String type, String category) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  try {
    final response = await supabase.from('transactions').insert({
      'user_id': user!.id,
      'amount': amount,
      'title': title,
      'date': DateTime.now().toIso8601String(),
      'account_id': accountId,
      'type': type,
      'category': category,
    }).select().single();

    // Update account balance and fetch name
    final accountResponse = await supabase
        .from('Accounts')
        .select('balance, acc_name')
        .eq('acc_id', accountId)
        .single();

    final currentBalance = (accountResponse['balance'] as num).toDouble();
    final newBalance = type == 'Income'
        ? currentBalance + amount
        : currentBalance - amount;

    await supabase
        .from('Accounts')
        .update({'balance': newBalance})
        .eq('acc_id', accountId);

    return Transaction(
      response['id'].toString(),
      amount,
      title,
      category,
      DateTime.now(),
      accountResponse['acc_name'], // name for display
      accountId,                    // id for balance updates
      type,
    );
  } catch (e) {
    print('ERROR inserting transaction: $e');
    rethrow;
  }
}

Future<List<Transaction>> loadTransactions({String? accountId}) async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    var query = supabase
        .from('transactions')
        .select('*, Accounts(acc_name)')
        .eq('user_id', user!.id);

    if (accountId != null) query = query.eq('account_id', accountId);

    final response = await query;
    return response.map<Transaction>((row) {
      final accName = row['Accounts']?['acc_name'] ?? 'Unknown';
      return Transaction(
        row['id'].toString(),
        (row['amount'] as num).toDouble(),
        row['title'] ?? '',
        row['category'] ?? 'Other',
        DateTime.parse(row['date']),
        accName,
        row['account_id'].toString(), // store acc_id
        row['type'] ?? 'Expense',
      );
    }).toList();
  } catch (e) {
    print('ERROR: $e');
    rethrow;
  }
}

Future<List<String>> loadCategories() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  const defaults = ['Food', 'Transport', 'Housing', 'Entertainment',
      'Health', 'Shopping', 'Salary', 'Other'];
  final response = await supabase
      .from('categories')
      .select('name')
      .eq('user_id', user!.id);
  final custom = response.map<String>((r) => r['name'] as String).toList();
  return {...defaults, ...custom}.toList();
}

Future<void> saveCategory(String name) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  await supabase.from('categories').insert({'user_id': user!.id, 'name': name});
}