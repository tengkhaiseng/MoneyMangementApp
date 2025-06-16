import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Planner"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearAllFields,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1F5FE),
              Color(0xFFB3E5FC),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Input Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enter Your Budget",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCurrencyInputField(
                        context,
                        controller: incomeController,
                        label: "Monthly Income",
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(height: 12),
                      _buildCurrencyInputField(
                        context,
                        controller: savingsController,
                        label: "Target Savings",
                        icon: Icons.savings,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Expense Categories",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCurrencyInputField(
                        context,
                        controller: foodController,
                        label: "Food & Dining",
                        icon: Icons.restaurant,
                      ),
                      const SizedBox(height: 8),
                      _buildCurrencyInputField(
                        context,
                        controller: transportController,
                        label: "Transportation",
                        icon: Icons.directions_car,
                      ),
                      const SizedBox(height: 8),
                      _buildCurrencyInputField(
                        context,
                        controller: othersController,
                        label: "Other Expenses",
                        icon: Icons.more_horiz,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.calculate, size: 20),
                          label: const Text("Calculate Budget"),
                          onPressed: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _buildBudgetOverview(context),
              const SizedBox(height: 20),
              _buildVisualizationSection(context),
            ],
          ),
        ),
      ),
    );
  }

  void _clearAllFields() {
    incomeController.clear();
    savingsController.clear();
    foodController.clear();
    transportController.clear();
    othersController.clear();
    setState(() {});
  }

  double _parseInput(String text) {
    return double.tryParse(text) ?? 0.0;
  }

  Widget _buildCurrencyInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: '\$ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildBudgetOverview(BuildContext context) {
    final theme = Theme.of(context);
    final usage = getBudgetUsage();
    final recommendation = getBudgetRecommendations();
    final isWarning = recommendation.contains("⚠");

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Budget Overview",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Budget Usage",
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${(usage * 100).toStringAsFixed(1)}% of income",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: usage,
                        strokeWidth: 10,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        color: _getUsageColor(usage),
                      ),
                      Text(
                        "${(usage * 100).toStringAsFixed(0)}%",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isWarning
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isWarning ? Icons.warning : Icons.check_circle,
                    color: isWarning
                        ? theme.colorScheme.error
                        : theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.replaceAll("⚠", "").replaceAll("✅", "").trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isWarning
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizationSection(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = incomeController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Budget Visualization",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Expense Distribution",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: hasData
                      ? PieChart(
                          PieChartData(
                            sections: _generatePieData(),
                            centerSpaceRadius: 50,
                            sectionsSpace: 2,
                            startDegreeOffset: -90,
                          ),
                        )
                      : Center(
                          child: Text(
                            "Enter your budget to see the chart",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                ),
                if (hasData) ...[
                  const SizedBox(height: 16),
                  _buildPieChartLegend(),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Spending Comparison",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: hasData
                      ? BarChart(
                          _generateBarChartData(),
                        )
                      : Center(
                          child: Text(
                            "Enter your budget to see the chart",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartLegend() {
    final List<Map<String, dynamic>> categories = [
      {"label": "Savings", "color": Colors.green},
      {"label": "Food", "color": Colors.orange},
      {"label": "Transport", "color": Colors.blue},
      {"label": "Others", "color": Colors.red},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: categories.map((category) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category["color"],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(category["label"]),
          ],
        );
      }).toList(),
    );
  }

  Color _getUsageColor(double usage) {
    if (usage < 0.5) return Colors.green;
    if (usage < 0.8) return Colors.orange;
    return Colors.red;
  }

  List<PieChartSectionData> _generatePieData() {
    final savings = _parseInput(savingsController.text);
    final food = _parseInput(foodController.text);
    final transport = _parseInput(transportController.text);
    final others = _parseInput(othersController.text);
    final total = savings + food + transport + others;

    if (total == 0) return [];

    return [
      PieChartSectionData(
        value: savings,
        title: "${((savings / total) * 100).toStringAsFixed(1)}%",
        color: Colors.green,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: food,
        title: "${((food / total) * 100).toStringAsFixed(1)}%",
        color: Colors.orange,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: transport,
        title: "${((transport / total) * 100).toStringAsFixed(1)}%",
        color: Colors.blue,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: others,
        title: "${((others / total) * 100).toStringAsFixed(1)}%",
        color: Colors.red,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  BarChartData _generateBarChartData() {
    final food = _parseInput(foodController.text);
    final transport = _parseInput(transportController.text);
    final others = _parseInput(othersController.text);
    final savings = _parseInput(savingsController.text);

    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.black87,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String category;
            switch (group.x) {
              case 1:
                category = 'Food';
                break;
              case 2:
                category = 'Transport';
                break;
              case 3:
                category = 'Others';
                break;
              case 4:
                category = 'Savings';
                break;
              default:
                category = '';
            }
            return BarTooltipItem(
              '$category\n\$${rod.toY.toStringAsFixed(2)}',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              String text;
              switch (value.toInt()) {
                case 1:
                  text = 'Food';
                  break;
                case 2:
                  text = 'Transport';
                  break;
                case 3:
                  text = 'Others';
                  break;
                case 4:
                  text = 'Savings';
                  break;
                default:
                  text = '';
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(text),
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: food,
              color: Colors.orange,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: transport,
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: others,
              color: Colors.red,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(
              toY: savings,
              color: Colors.green,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      ],
      gridData: FlGridData(show: true),
    );
  }

  double getBudgetUsage() {
    double totalExpenses = _parseInput(foodController.text) +
        _parseInput(transportController.text) +
        _parseInput(othersController.text);
    double income = _parseInput(incomeController.text);
    return income > 0 ? totalExpenses / income : 0.0;
  }

  String getBudgetRecommendations() {
    double income = _parseInput(incomeController.text);
    if (income == 0) return "Enter your income to get recommendations";

    double savings = _parseInput(savingsController.text);
    double totalExpenses = _parseInput(foodController.text) +
        _parseInput(transportController.text) +
        _parseInput(othersController.text);

    if (savings < (income * 0.2)) {
      return "⚠ Consider increasing savings to at least 20% of your income";
    } else if (totalExpenses > (income * 0.7)) {
      return "⚠ Your expenses exceed 70% of your income! Try adjusting spending";
    } else {
      return "✅ Your budget allocation looks balanced";
    }
  }

  @override
  void dispose() {
    incomeController.dispose();
    savingsController.dispose();
    foodController.dispose();
    transportController.dispose();
    othersController.dispose();
    super.dispose();
  }
}