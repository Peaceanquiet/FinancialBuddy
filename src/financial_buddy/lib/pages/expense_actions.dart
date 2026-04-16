import '../widgets/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> editTransaction(List<Transaction> transactions, int index,
    String newTitle, double newAmount, String newType, String newCategory) async {
  final supabase = Supabase.instance.client;
  final tx = transactions[index];

  //this updates the account's balance accordingly
  final accountResponse = await supabase
        .from('Accounts')
        .select('balance, acc_id')
        .eq('acc_name', tx.tAccount)
        .single();

    final currentBalance = (accountResponse['balance'] as num).toDouble();
    // Undo old transaction effect
    final afterUndo = tx.tType == 'Income'
        ? currentBalance - tx.tAmount
        : currentBalance + tx.tAmount;
    // Apply new transaction effect
    final newBalance = newType == 'Income'
        ? afterUndo + newAmount
        : afterUndo - newAmount;

    await supabase
        .from('Accounts')
        .update({'balance': newBalance})
        .eq('acc_id', accountResponse['acc_id']);
  



  transactions[index] = Transaction(
    tx.tID, newAmount, newTitle, newCategory, DateTime.now(), tx.tAccount, newType,
  );
  await supabase.from('transactions').update({
    'amount': newAmount,
    'title': newTitle,
    'date': DateTime.now().toIso8601String(),
    'type': newType,
    'category': newCategory,
  }).eq('id', tx.tID);
}

Future<void> deleteTransaction(
    List<Transaction> transactions, int index) async {
  final supabase = Supabase.instance.client;
  final tx = transactions[index];

  //this updates the account's balance accordingly
  // Reverse the balance effect 
  final accountResponse = await supabase
      .from('Accounts')
      .select('balance, acc_id')
      .eq('acc_name', tx.tAccount) 
      .single();

  final currentBalance = (accountResponse['balance'] as num).toDouble();
  final newBalance = tx.tType == 'Income'
      ? currentBalance - tx.tAmount   // undo income
      : currentBalance + tx.tAmount;  // undo expense

  await supabase
      .from('Accounts')
      .update({'balance': newBalance})
      .eq('acc_id', accountResponse['acc_id']);



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

    //this updates the account's balance accordingly
    final accountResponse = await supabase
        .from('Accounts')
        .select('balance')
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