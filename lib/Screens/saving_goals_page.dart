import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavingGoal {
  String title;
  double goalAmount;
  double savedAmount;
  String targetDate;

  SavingGoal({
    required this.title,
    required this.goalAmount,
    required this.savedAmount,
    required this.targetDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'goalAmount': goalAmount,
        'savedAmount': savedAmount,
        'targetDate': targetDate,
      };

  factory SavingGoal.fromJson(Map<String, dynamic> json) => SavingGoal(
        title: json['title'],
        goalAmount: (json['goalAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        targetDate: json['targetDate'],
      );
}

class SavingsGoalPage extends StatefulWidget {
  const SavingsGoalPage({super.key, this.language = ''});
  final String language;

  @override
  State<SavingsGoalPage> createState() => _SavingsGoalPageState();
}

class _SavingsGoalPageState extends State<SavingsGoalPage> {
  List<SavingGoal> goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString('saving_goals');
    if (goalsJson != null) {
      final List<dynamic> decoded = jsonDecode(goalsJson);
      setState(() {
        goals = decoded.map((e) => SavingGoal.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'saving_goals',
      jsonEncode(goals.map((e) => e.toJson()).toList()),
    );
  }

  void _showGoalForm({SavingGoal? goal, int? editIndex}) async {
    final result = await showModalBottomSheet<SavingGoal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavingGoalForm(goal: goal),
    );
    if (result != null) {
      setState(() {
        if (editIndex != null) {
          goals[editIndex] = result;
        } else {
          goals.add(result);
        }
      });
      _saveGoals();
    }
  }

  void _deleteGoal(int index) async {
    setState(() {
      goals.removeAt(index);
    });
    await _saveGoals();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Savings Goal Tracker"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add New Goal"),
            onPressed: () => _showGoalForm(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (goals.isEmpty)
            Center(
              child: Text(
                "No savings goals yet.",
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ...goals.asMap().entries.map((entry) {
            final i = entry.key;
            final goal = entry.value;
            final percent = (goal.savedAmount / goal.goalAmount).clamp(0.0, 1.0);
            final remaining = (goal.goalAmount - goal.savedAmount).clamp(0.0, goal.goalAmount);
            return Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: "Edit",
                          onPressed: () => _showGoalForm(goal: goal, editIndex: i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete",
                          onPressed: () => _deleteGoal(i),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Saved: \$${goal.savedAmount.toStringAsFixed(2)} / Goal: \$${goal.goalAmount.toStringAsFixed(2)}",
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(percent * 100).toStringAsFixed(1)}% progress",
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: goal.savedAmount,
                              color: Colors.green,
                              title: "Saved\n\$${goal.savedAmount.toStringAsFixed(2)}",
                              radius: 60,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            PieChartSectionData(
                              value: remaining,
                              color: Colors.red,
                              title: "Remaining\n\$${remaining.toStringAsFixed(2)}",
                              radius: 60,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 6),
                        Text("Target: ${goal.targetDate}"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SavingGoalForm extends StatefulWidget {
  final SavingGoal? goal;
  const SavingGoalForm({super.key, this.goal});

  @override
  State<SavingGoalForm> createState() => _SavingGoalFormState();
}

class _SavingGoalFormState extends State<SavingGoalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _goalAmountController;
  late TextEditingController _savedAmountController;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? "");
    _goalAmountController = TextEditingController(
        text: widget.goal != null ? widget.goal!.goalAmount.toString() : "");
    _savedAmountController = TextEditingController(
        text: widget.goal != null ? widget.goal!.savedAmount.toString() : "");
    _targetDate = widget.goal != null
        ? DateTime.tryParse(widget.goal!.targetDate)
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalAmountController.dispose();
    _savedAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.goal == null ? "Add Savings Goal" : "Edit Savings Goal",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Goal Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? "Enter goal title" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _goalAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Goal Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter goal amount";
                    if (double.tryParse(val) == null) return "Enter a valid number";
                    if (double.parse(val) <= 0) return "Goal must be > 0";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _savedAmountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Saved Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter saved amount";
                    if (double.tryParse(val) == null) return "Enter a valid number";
                    if (double.parse(val) < 0) return "Saved can't be negative";
                    if (_goalAmountController.text.isNotEmpty &&
                        double.tryParse(_goalAmountController.text) != null &&
                        double.parse(val) > double.parse(_goalAmountController.text)) {
                      return "Saved can't exceed goal";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(_targetDate == null
                      ? "Select Target Date"
                      : "${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}"),
                  trailing: TextButton(
                    child: const Text("Pick"),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _targetDate != null) {
                        Navigator.pop(
                          context,
                          SavingGoal(
                            title: _titleController.text,
                            goalAmount: double.parse(_goalAmountController.text),
                            savedAmount: double.parse(_savedAmountController.text),
                            targetDate:
                                "${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}",
                          ),
                        );
                      }
                    },
                    child: Text(widget.goal == null ? "Add Goal" : "Save Changes"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}