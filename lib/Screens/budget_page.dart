import 'package:flutter/material.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final incomeController = TextEditingController();
  final savingsController = TextEditingController();
  final foodController = TextEditingController();
  final transportController = TextEditingController();
  final othersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Budget Planner")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: incomeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Monthly Income")),
            TextField(controller: savingsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Savings")),
            const SizedBox(height: 10),
            Text("Category Budgets", style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: foodController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Food")),
            TextField(controller: transportController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Transport")),
            TextField(controller: othersController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Others")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Save logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Budget Saved")),
                );
              },
              child: const Text("Save Budget"),
            )
          ],
        ),
      ),
    );
  }
}
