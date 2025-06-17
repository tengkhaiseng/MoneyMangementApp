import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetPage extends StatefulWidget {
  final String language;
  const BudgetPage({super.key, required this.language});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController savingsController = TextEditingController();
  final TextEditingController foodController = TextEditingController();
  final TextEditingController transportController = TextEditingController();
  final TextEditingController othersController = TextEditingController();

  double income = 0;
  double targetSavings = 0;
  double food = 0;
  double transport = 0;
  double others = 0;

  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('budget_history');
    if (historyJson != null) {
      setState(() {
        history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('budget_history', jsonEncode(history));
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        income = double.tryParse(incomeController.text) ?? 0;
        targetSavings = double.tryParse(savingsController.text) ?? 0;
        food = double.tryParse(foodController.text) ?? 0;
        transport = double.tryParse(transportController.text) ?? 0;
        others = double.tryParse(othersController.text) ?? 0;
        final entry = {
          'date': DateTime.now().toIso8601String(),
          'income': income,
          'targetSavings': targetSavings,
          'food': food,
          'transport': transport,
          'others': others,
        };
        history.insert(0, entry);
        _saveHistory();
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget saved!')),
      );
    }
  }

  double get totalExpenses => food + transport + others;
  double get actualSaved => (income - totalExpenses).clamp(0, income);
  double get budgetUsagePercent => (income > 0) ? (totalExpenses / income) : 0.0;

  String get feedback {
    if (income == 0) return '';
    if (totalExpenses > income) {
      return "You are over budget!";
    } else if (actualSaved >= targetSavings) {
      return "Congratulations! You achieved your savings target.";
    } else if (actualSaved < targetSavings && actualSaved >= 0) {
      return "Warning: You are below your savings target.";
    } else {
      return "";
    }
  }

  Color get feedbackColor {
    if (income == 0) return Colors.transparent;
    if (totalExpenses > income) {
      return Colors.red.shade100;
    } else if (actualSaved >= targetSavings) {
      return Colors.green.shade100;
    } else if (actualSaved < targetSavings && actualSaved >= 0) {
      return Colors.orange.shade100;
    } else {
      return Colors.pink.shade100;
    }
  }

  IconData get feedbackIcon {
    if (income == 0) return Icons.info;
    if (totalExpenses > income) {
      return Icons.warning;
    } else if (actualSaved >= targetSavings) {
      return Icons.check_circle;
    } else if (actualSaved < targetSavings && actualSaved >= 0) {
      return Icons.info;
    } else {
      return Icons.info;
    }
  }

  Color get feedbackIconColor {
    if (income == 0) return Colors.blue;
    if (totalExpenses > income) {
      return Colors.red;
    } else if (actualSaved >= targetSavings) {
      return Colors.green;
    } else if (actualSaved < targetSavings && actualSaved >= 0) {
      return Colors.orange;
    } else {
      return Colors.pink;
    }
  }

  double get savedAmount => (income - totalExpenses).clamp(0, income);

  List<PieChartSectionData> getPieSections() {
    final total = income > 0 ? income : 1; // avoid division by zero
    final saved = savedAmount;
    final foodPct = food / total;
    final transportPct = transport / total;
    final othersPct = others / total;
    final savedPct = saved / total;

    return [
      PieChartSectionData(
        value: saved.toDouble(),
        color: Colors.green,
        title: saved > 0 ? "${(savedPct * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: food,
        color: Colors.orange,
        title: food > 0 ? "${(foodPct * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: transport,
        color: Colors.blue,
        title: transport > 0 ? "${(transportPct * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: others,
        color: Colors.red,
        title: others > 0 ? "${(othersPct * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  List<BarChartGroupData> getBarGroups() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: food,
            color: Colors.orange,
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: transport,
            color: Colors.blue,
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: others,
            color: Colors.red,
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: savedAmount,
            color: Colors.green,
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BudgetHistorySheet(
        history: history,
        onSelect: (entry) {
          setState(() {
            income = entry['income'];
            targetSavings = entry['targetSavings'];
            food = entry['food'];
            transport = entry['transport'];
            others = entry['others'];
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Enter $label";
        if (double.tryParse(val) == null) return "Enter a valid number";
        if (double.parse(val) < 0) return "Amount can't be negative";
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Planner"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "History",
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Enter Your Budget",
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: incomeController,
                        label: "Monthly Income (\$)",
                        icon: Icons.attach_money,
                        hint: "e.g. 3000",
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: savingsController,
                        label: "Target Savings (\$)",
                        icon: Icons.savings,
                        hint: "e.g. 500",
                      ),
                      const SizedBox(height: 18),
                      Text("Expense Categories",
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: foodController,
                        label: "Food & Dining (\$)",
                        icon: Icons.restaurant,
                        hint: "e.g. 800",
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: transportController,
                        label: "Transportation (\$)",
                        icon: Icons.directions_car,
                        hint: "e.g. 300",
                      ),
                      const SizedBox(height: 10),
                      _buildInputField(
                        controller: othersController,
                        label: "Other Expenses (\$)",
                        icon: Icons.more_horiz,
                        hint: "e.g. 200",
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calculate),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _submit,
                          label: const Text("Calculate Budget"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Budget Overview
            if (income > 0) ...[
              Text("Budget Overview",
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Budget Usage",
                                style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 8),
                            Text(
                              "${(budgetUsagePercent * 100).toStringAsFixed(1)}% of income",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Actual Saved: \$${actualSaved.toStringAsFixed(2)} / Target: \$${targetSavings.toStringAsFixed(2)}",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: budgetUsagePercent.clamp(0.0, 1.0),
                              strokeWidth: 7,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary),
                            ),
                          ),
                          Text(
                            "${(budgetUsagePercent * 100).toStringAsFixed(0)}%",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (feedback.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feedbackColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        feedbackIcon,
                        color: feedbackIconColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feedback,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: feedbackIconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              // Budget Visualization
              Text("Budget Visualization",
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Expense Distribution",
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: getPieSections(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegend("Savings", Colors.green),
                          _buildLegend("Food", Colors.orange),
                          _buildLegend("Transport", Colors.blue),
                          _buildLegend("Others", Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Spending Comparison",
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: [
                              food,
                              transport,
                              others,
                              savedAmount
                            ].reduce((a, b) => a > b ? a : b) +
                                100,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) => Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(
                                      "\$${value.toInt()}",
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text("Food");
                                      case 1:
                                        return const Text("Transport");
                                      case 2:
                                        return const Text("Others");
                                      case 3:
                                        return const Text("Savings");
                                      default:
                                        return const Text("");
                                    }
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true, horizontalInterval: 100),
                            borderData: FlBorderData(show: false),
                            barGroups: getBarGroups(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BudgetHistorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final void Function(Map<String, dynamic> entry) onSelect;

  const BudgetHistorySheet({
    super.key,
    required this.history,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Budget History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: history.isEmpty
                    ? const Center(child: Text("No history yet."))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final entry = history[index];
                          final date = DateTime.tryParse(entry['date'] ?? "") ??
                              DateTime.now();
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(
                                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  "Income: \$${entry['income']} | Target Savings: \$${entry['targetSavings']} | Food: \$${entry['food']} | Transport: \$${entry['transport']} | Others: \$${entry['others']}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.bar_chart),
                                tooltip: "View Chart",
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "Expense & Savings Distribution",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                height: 180,
                                                child: PieChart(
                                                  PieChartData(
                                                    sections: _getPieSectionsHistory(entry),
                                                    centerSpaceRadius: 40,
                                                    sectionsSpace: 2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                onSelect(entry);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getPieSectionsHistory(Map<String, dynamic> entry) {
    final income = (entry['income'] as num).toDouble();
    final food = (entry['food'] as num).toDouble();
    final transport = (entry['transport'] as num).toDouble();
    final others = (entry['others'] as num).toDouble();
    final saved = (income - (food + transport + others)).clamp(0, income);
    final total = income > 0 ? income : 1;

    return [
      PieChartSectionData(
        value: saved.toDouble(),
        color: Colors.green,
        title: saved > 0 ? "${((saved / total) * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: food,
        color: Colors.orange,
        title: food > 0 ? "${((food / total) * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: transport,
        color: Colors.blue,
        title: transport > 0 ? "${((transport / total) * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: others,
        color: Colors.red,
        title: others > 0 ? "${((others / total) * 100).round()}%" : "",
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }
}