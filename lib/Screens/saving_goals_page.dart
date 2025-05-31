import 'package:flutter/material.dart';

class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  State<SavingGoalsPage> createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage> {
  final List<Map<String, dynamic>> goals = [];
  final goalController = TextEditingController();
  final amountController = TextEditingController();
  DateTime? targetDate;

  void _addGoal() {
    setState(() {
      goals.add({
        "name": goalController.text,
        "target": double.parse(amountController.text),
        "saved": 0.0,
        "date": targetDate,
      });
      goalController.clear();
      amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saving Goals")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: goalController, decoration: const InputDecoration(labelText: "Goal Name")),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Amount")),
            Row(
              children: [
                Text(targetDate == null ? "Pick Target Date" : "Target: ${targetDate!.toLocal()}".split(' ')[0]),
                TextButton(
                  child: const Text("Pick Date"),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => targetDate = picked);
                  },
                )
              ],
            ),
            ElevatedButton(onPressed: _addGoal, child: const Text("Add Goal")),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return Card(
                    child: ListTile(
                      title: Text(goal['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Target: RM${goal['target']}"),
                          LinearProgressIndicator(value: goal['saved'] / goal['target']),
                          Text("Saved: RM${goal['saved']}")
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
