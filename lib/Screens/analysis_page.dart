import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spending Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: "Monthly",
              items: const [
                DropdownMenuItem(value: "Weekly", child: Text("Weekly")),
                DropdownMenuItem(value: "Monthly", child: Text("Monthly")),
                DropdownMenuItem(value: "Custom", child: Text("Custom")),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Text("Pie Chart Placeholder"),
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text("Bar Chart Placeholder"),
            ),
            const SizedBox(height: 10),
            const Text("Note: You're spending more than your budget on food!")
          ],
        ),
      ),
    );
  }
}
