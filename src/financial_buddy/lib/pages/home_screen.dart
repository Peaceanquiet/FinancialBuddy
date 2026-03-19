import 'package:financial_buddy/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Transactions', style: optionStyle),
    Text('Index 2: Budgeting', style: optionStyle),
  ];

  /*
  void _OnItemTapped(int index) {
    setState(() {
      //
    });
  }
  */

  final user = supabase.auth.currentUser;
  final accNameCtrlr = TextEditingController();
  final accTypeCtrlr = TextEditingController();
  final accBlncCtrlr = TextEditingController();
  List accountInfo = [];

  Future<void> loadAccount() async {
    final response = await supabase
        .from("Accounts")
        .select('acc_name, type, balance')
        .eq('user_id', user!.id);

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
        /* **************
        *  Hamburger Menu
        *  **************
        */
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
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      /*
       *  Drawer from Hamburger 
       */
      drawer: Drawer(
        child: ListView(
          padding: (EdgeInsets.fromLTRB(0, 0, 0, 0)),
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Placeholder Menu Name',
                textScaler: TextScaler.linear(1.4),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              //selected: Navigator.pushNamed(context, HomeScreen()),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
                //Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Transactions'),
              //selected:Navigator.pushNamed(context, TransactionsPage()),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/transactions');
              },
            ),
          ],
        ),
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
                                color: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 15),
                                  Text(
                                    acc['acc_name'],
                                    textScaler: const TextScaler.linear(1.25),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "\$${acc['balance']}",
                                    textScaler: const TextScaler.linear(1.25),
                                  ),
                                  const SizedBox(width: 10),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/transactions");
            },
            child: Text("Transactions"),
          ),
        ],
      ),
    );
  }
}
