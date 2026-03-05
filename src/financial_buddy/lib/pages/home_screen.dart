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
                    Text("Account Name", textScaler: TextScaler.linear(1.5)),
                    Spacer(),
                    Text("Account Balance", textScaler: TextScaler.linear(1.5)),
                    Padding(padding: EdgeInsetsGeometry.all(10)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsetsGeometry.all(5)),
              ElevatedButton(
                onPressed: () {
                  //               showModalBottomSheet(context: context, builder: builder)
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
