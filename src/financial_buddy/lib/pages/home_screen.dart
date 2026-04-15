import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:financial_buddy/widgets/buddy_drawer.dart';
import 'package:financial_buddy/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = supabase.auth.currentUser;
  final accNameCtrlr = TextEditingController();
  final accTypeCtrlr = TextEditingController();
  final accBlncCtrlr = TextEditingController();
  List accountInfo = [];

  Future<void> loadAccount() async {
    final response = await supabase
        .from("Accounts")
        .select('acc_id, acc_name, type, balance')
        .eq('user_id', user!.id);

    setState(() {
      accountInfo = response;
    });
  }

  Future<void> _deleteAccount(String accId, String accName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "$accName"?\n\nThis will also delete all transactions associated with this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
           style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete related transactions first
      await supabase.from('transactions').delete().eq('account_id', accId);
      // Then delete the account
      await supabase.from('Accounts').delete().eq('acc_id', accId);
      await loadAccount();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadAccount();
  }

  @override
  void dispose() {
    accNameCtrlr.dispose();
    accBlncCtrlr.dispose();
    accTypeCtrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text(
          'Financial Destination',
          textScaler: TextScaler.linear(1.5),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: BuddyDrawer(title: "Financial Destination"),
      body: Column(
        children: [
          Text(
            "Accounts",
            textScaler: const TextScaler.linear(1.55),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            children: [
              accountInfo.isEmpty
                  ? const Text("No accounts to display")
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: accountInfo.length,
                        itemBuilder: (context, index) {
                          final acc = accountInfo[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              height: 50,
                              width: 411,
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 15),
                                  Text(
                                    acc['acc_name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "\$${acc['balance']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // DELETE BUTTON
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.danger,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteAccount(
                                      acc['acc_id'].toString(),
                                      acc['acc_name'],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Padding(padding: EdgeInsetsGeometry.all(5)),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.darkSurface,
                    isScrollControlled: false,
                    builder: (_) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(padding: EdgeInsetsGeometry.all(5)),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "Account Name",
                                contentPadding: EdgeInsets.all(10),
                              ),
                              controller: accNameCtrlr,
                            ),
                            Padding(padding: EdgeInsetsGeometry.all(5)),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText:
                                    "Account Type (Checking, Savings, Etc.)",
                                contentPadding: EdgeInsets.all(10),
                              ),
                              controller: accTypeCtrlr,
                            ),
                            Padding(padding: EdgeInsetsGeometry.all(5)),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "Initial Balance",
                                contentPadding: EdgeInsets.all(10),
                              ),
                              controller: accBlncCtrlr,
                            ),
                            Padding(padding: EdgeInsetsGeometry.all(25)),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  AppColors.neonGreen,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await supabase.from('Accounts').insert({
                                    'user_id': user!.id,
                                    'acc_name': accNameCtrlr.text.trim(),
                                    'type': accTypeCtrlr.text.trim(),
                                    'balance': toDouble(
                                      accBlncCtrlr.text.trim(),
                                    ),
                                  });
                                  await loadAccount();
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  );
                                }
                              },
                              child: Text("Save"),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text("Add Account"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
