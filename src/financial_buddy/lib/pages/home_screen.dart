import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> transactions = [];
  final accNameCtrlr = TextEditingController();
  final accTypeCtrlr = TextEditingController();
  final accBlncCtrlr = TextEditingController();
  List accountInfo = [];

  Future<void> loadAccount() async {
    final response = await supabase
        .from("Accounts")
        .select('acc_name, type, balance');

    setState(() {
      accountInfo = response;
    });
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
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        title: const Text('Financial Buddy', textScaler: TextScaler.linear(2)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Text(
            "Accounts",
            textScaler: TextScaler.linear(1.55),
            style: TextStyle(fontSize: 16, decorationThickness: 1.5),
          ),
          Column(
            children: [
              accountInfo.isEmpty
                  ? const Text("Add an account")
                  : Container(
                      height: 50,
                      width: 411,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Padding(padding: EdgeInsetsGeometry.all(15)),
                          Text(
                            "${accountInfo[0]['acc_name']}",
                            textScaler: TextScaler.linear(1.25),
                          ),
                          Spacer(),
                          Text(
                            "\$${accountInfo[2]['balance']}",
                            textScaler: TextScaler.linear(1.25),
                          ),
                          Padding(padding: EdgeInsetsGeometry.all(10)),
                        ],
                      ),
                    ),
              Padding(padding: EdgeInsetsGeometry.all(5)),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.deepPurpleAccent,
                    barrierColor: Colors.transparent,
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
                                  Colors.red,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await supabase.from('Accounts').insert({
                                    'acc_name': accNameCtrlr.text.trim(),
                                    'type': accTypeCtrlr.text.trim(),
                                    'balance': toDouble(
                                      accBlncCtrlr.text.trim(),
                                    ),
                                  });
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
