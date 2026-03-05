import 'package:flutter/material.dart';
import 'package:financial_buddy/widgets/transaction.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final List<Transaction> transactions = [];

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
              Container(
                height: 50,
                width: 411,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Padding(padding: EdgeInsetsGeometry.all(15)),
                    Text("Account Name", textScaler: TextScaler.linear(1.25)),
                    Spacer(),
                    Text(
                      "Account Balance",
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
                            ),
                            Padding(padding: EdgeInsetsGeometry.all(5)),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText:
                                    "Account Type (Checking, Savings, Etc.)",
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            Padding(padding: EdgeInsetsGeometry.all(5)),
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: "Initial Balance",
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                            Padding(padding: EdgeInsetsGeometry.all(25)),
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
