import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavingsGoalPage extends StatefulWidget {
  const SavingsGoalPage({super.key});

  @override
  State<SavingsGoalPage> createState() => _SavingsGoalPageState();
}

class _SavingsGoalPageState extends State<SavingsGoalPage> {
  final titleController = TextEditingController();
  final goalController = TextEditingController();
  final savedController = TextEditingController();
  DateTime? selectedDate;

  List<Map<String, dynamic>> savingsHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('savings_history');
    if (historyJson != null) {
      setState(() {
        savingsHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      });
    }
  }

  Future<void> _saveSavings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savings_history', jsonEncode(savingsHistory));
  }

  double getSavingsProgress() {
    double goalAmount = double.tryParse(goalController.text) ?? 1.0;
    double savedAmount = double.tryParse(savedController.text) ?? 0.0;
    if (goalAmount == 0) return 0.0;
    return savedAmount / goalAmount;
  }

  void saveProgress() {
    if (goalController.text.isNotEmpty && savedController.text.isNotEmpty) {
      setState(() {
        savingsHistory.add({
          "title": titleController.text,
          "goal": goalController.text,
          "saved": savedController.text,
          "date": selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : "No Date Set",
        });
      });
      _saveSavings();
      titleController.clear();
      goalController.clear();
      savedController.clear();
      selectedDate = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget buildProgressBar(ThemeData theme) {
    double progress = getSavingsProgress();
    Color barColor = progress < 0.5
        ? Colors.red
        : (progress < 0.8 ? Colors.orange : Colors.green);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Savings Progress",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            color: barColor,
            minHeight: 12,
            backgroundColor: theme.colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(progress * 100).toStringAsFixed(1)}%",
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                "${savedController.text.isEmpty ? '0' : savedController.text} of ${goalController.text.isEmpty ? '0' : goalController.text}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPieChart(ThemeData theme) {
    double goalAmount = double.tryParse(goalController.text) ?? 1.0;
    double savedAmount = double.tryParse(savedController.text) ?? 0.0;
    double remaining = goalAmount - savedAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Savings Breakdown",
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: savedAmount,
                    title: "Saved\n${savedAmount.toStringAsFixed(2)}",
                    color: Colors.green[400],
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: remaining,
                    title: "Remaining\n${remaining.toStringAsFixed(2)}",
                    color: Colors.red[400],
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                startDegreeOffset: -90,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller, ThemeData theme, {TextInputType? keyboardType}) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: isDark
              ? theme.colorScheme.surface.withOpacity(0.8)
              : theme.colorScheme.surface,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Goal Tracker"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Track Your Savings Goal",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        buildInputField("Goal Title", titleController, theme),
                        const SizedBox(height: 8),
                        const Text(
                          "Target Date",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2050),
                            );
                            if (pickedDate != null) {
                              setState(() => selectedDate = pickedDate);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: theme.colorScheme.primary),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                selectedDate == null
                                    ? "Select Target Date"
                                    : "Target: ${selectedDate!.toLocal()}".split(' ')[0],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildInputField(
                          "Goal Amount",
                          goalController,
                          theme,
                          keyboardType: TextInputType.number,
                        ),
                        buildInputField(
                          "Saved Amount",
                          savedController,
                          theme,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saveProgress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Update Progress",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                buildProgressBar(theme),
                const SizedBox(height: 16),
                buildPieChart(theme),
                const SizedBox(height: 16),
                Text(
                  "Savings History",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (savingsHistory.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "No savings history yet.\nStart by adding your first goal!",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: savingsHistory.length,
                    itemBuilder: (context, index) {
                      var entry = savingsHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 2,
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(
                            entry["title"],
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "Saved: \$${entry["saved"]} / Goal: \$${entry["goal"]}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Target: ${entry["date"]}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          trailing: entry["saved"] == entry["goal"]
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.hourglass_bottom, color: Colors.orange),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    goalController.dispose();
    savedController.dispose();
    super.dispose();
  }
}