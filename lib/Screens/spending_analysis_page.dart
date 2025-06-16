import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Expense {
  final String category;
  final double amount;
  final String date;
  final String description;

  Expense({
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'date': date,
        'description': description,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        category: json['category'],
        amount: (json['amount'] as num).toDouble(),
        date: json['date'],
        description: json['description'],
      );
}

class SpendingAnalysisPage extends StatefulWidget {
  const SpendingAnalysisPage({super.key});

  @override
  State<SpendingAnalysisPage> createState() => _SpendingAnalysisPageState();
}

class _SpendingAnalysisPageState extends State<SpendingAnalysisPage> {
  List<Expense> expenses = [];
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? expensesJson = prefs.getString('spending_analysis_expenses');
    if (expensesJson != null) {
      final List<dynamic> decoded = jsonDecode(expensesJson);
      setState(() {
        expenses = decoded.map((e) => Expense.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'spending_analysis_expenses',
      jsonEncode(expenses.map((e) => e.toJson()).toList()),
    );
  }

  void _openExpenseForm({Expense? editExpense, int? editIndex}) async {
    final expense = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseForm(expense: editExpense),
    );
    if (expense != null) {
      setState(() {
        if (editIndex != null) {
          expenses[editIndex] = expense;
        } else {
          expenses.add(expense);
        }
      });
      _saveExpenses();
    }
  }

  void _deleteExpense(int index) async {
    setState(() {
      expenses.removeAt(index);
    });
    await _saveExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.background;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending Analysis"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openExpenseForm(),
            tooltip: 'Add Expense',
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    _buildCategoryFilter(theme, isDarkMode),
                    _buildSummaryCards(theme, isDarkMode),
                    SizedBox(
                      height: 400,
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              labelColor: theme.colorScheme.primary,
                              unselectedLabelColor: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
                              indicatorColor: theme.colorScheme.primary,
                              tabs: const [
                                Tab(icon: Icon(Icons.pie_chart)),
                                Tab(icon: Icon(Icons.bar_chart)),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildPieChart(isDarkMode, theme),
                                  _buildBarChart(isDarkMode, theme),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recent Expenses",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    _buildExpenseList(isDarkMode, theme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openExpenseForm(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter(ThemeData theme, bool isDarkMode) {
    final categories = ["All", "Food", "Transport", "Entertainment", "Shopping", "Bills", "Others"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: selectedCategory == category,
              onSelected: (bool selected) {
                setState(() {
                  selectedCategory = selected ? category : "All";
                });
              },
              selectedColor: theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: selectedCategory == category
                    ? theme.colorScheme.primary
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
              backgroundColor: isDarkMode
                  ? theme.colorScheme.surface.withOpacity(0.5)
                  : theme.colorScheme.surface,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, bool isDarkMode) {
    final filteredExpenses = selectedCategory == "All"
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    final totalSpent = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final avgSpending = filteredExpenses.isEmpty ? 0 : totalSpent / filteredExpenses.length;
    final budget = 1000.0;
    final remainingBudget = budget - totalSpent;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          _buildSummaryCard(
            theme,
            "Total Spent",
            "\$${totalSpent.toStringAsFixed(2)}",
            Colors.redAccent,
            Icons.attach_money,
            isDarkMode,
          ),
          _buildSummaryCard(
            theme,
            "Avg Spending",
            "\$${avgSpending.toStringAsFixed(2)}",
            Colors.orangeAccent,
            Icons.trending_up,
            isDarkMode,
          ),
          _buildSummaryCard(
            theme,
            "Remaining",
            "\$${remainingBudget.toStringAsFixed(2)}",
            remainingBudget >= 0 ? Colors.green : Colors.red,
            remainingBudget >= 0 ? Icons.check_circle : Icons.warning,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    String value,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        color: isDarkMode
            ? theme.colorScheme.surface.withOpacity(0.7)
            : theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDarkMode, ThemeData theme) {
    final filteredExpenses = selectedCategory == "All"
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    if (filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No data available",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var e in filteredExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: categoryTotals.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value,
              title: "${entry.key}\n\$${entry.value.toStringAsFixed(2)}",
              color: getCategoryColor(entry.key),
              radius: 80,
              titleStyle: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDarkMode, ThemeData theme) {
    final filteredExpenses = selectedCategory == "All"
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    if (filteredExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "No data available",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var e in filteredExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final categories = categoryTotals.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add a simple legend for the bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Text(
                "Bar height = Total spent per category",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          "\$${value.toInt()}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= categories.length) return const SizedBox.shrink();
                        return Text(
                          categories[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, horizontalInterval: 10),
                borderData: FlBorderData(show: false),
                barGroups: categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: categoryTotals[category]!,
                        color: getCategoryColor(category),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(bool isDarkMode, ThemeData theme) {
    final filteredExpenses = selectedCategory == "All"
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    if (filteredExpenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            "No expenses yet.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = filteredExpenses[index];
        final realIndex = expenses.indexOf(expense);
        return Card(
          color: isDarkMode
              ? theme.colorScheme.surface.withOpacity(0.7)
              : theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: getCategoryColor(expense.category).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: getCategoryColor(expense.category),
              ),
            ),
            title: Text(
              expense.category,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              "${expense.date} • ${expense.description}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "-\$${expense.amount.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: "Edit",
                  onPressed: () => _openExpenseForm(editExpense: expense, editIndex: realIndex),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: "Delete",
                  onPressed: () => _deleteExpense(realIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;
      case "Transport":
        return Icons.directions_car;
      case "Entertainment":
        return Icons.movie;
      case "Shopping":
        return Icons.shopping_bag;
      case "Bills":
        return Icons.receipt;
      case "Others":
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }
}

class ExpenseForm extends StatefulWidget {
  final Expense? expense;
  const ExpenseForm({super.key, this.expense});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategory;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.expense?.category ?? "Food";
    _amountController = TextEditingController(
        text: widget.expense != null ? widget.expense!.amount.toString() : "");
    _descController = TextEditingController(
        text: widget.expense != null ? widget.expense!.description : "");
    _selectedDate = widget.expense != null
        ? DateTime.tryParse(widget.expense!.date) ?? DateTime.now()
        : DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.expense == null ? "Add New Expense" : "Edit Expense",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: [
                  "Food",
                  "Transport",
                  "Entertainment",
                  "Shopping",
                  "Bills",
                  "Others"
                ]
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? theme.colorScheme.surface.withOpacity(0.8)
                      : theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? theme.colorScheme.surface.withOpacity(0.8)
                      : theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: isDarkMode
                        ? theme.colorScheme.surface.withOpacity(0.8)
                        : theme.colorScheme.surface,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? theme.colorScheme.surface.withOpacity(0.8)
                      : theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                        context,
                        Expense(
                          category: _selectedCategory,
                          amount: double.parse(_amountController.text),
                          date:
                              "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                          description: _descController.text,
                        ));
                  }
                },
                child: Text(widget.expense == null ? "Add Expense" : "Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case "Food":
      return Colors.green;
    case "Transport":
      return Colors.blue;
    case "Entertainment":
      return Colors.orange;
    case "Shopping":
      return Colors.purple;
    case "Bills":
      return Colors.red;
    case "Others":
      return Colors.grey;
    default:
      return Colors.grey;
  }
}