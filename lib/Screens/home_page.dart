import 'package:flutter/material.dart';
import 'expenses_page.dart';
import 'budget_page.dart';
import 'analysis_page.dart';
import 'saving_goals_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Dashboard")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Money Manager Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            child: const Text("Expenses Tracker"),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesPage()));
            },
          ),
          ElevatedButton(
            child: const Text("Budget Planner"),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetPage()));
            },
          ),
          ElevatedButton(
            child: const Text("Spending Analysis"),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisPage()));
            },
          ),
          ElevatedButton(
            child: const Text("Saving Goal Tracker"),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingGoalsPage()));
            },
          ),
        ],
      ),
    );
  }
}
