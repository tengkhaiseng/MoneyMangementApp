import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spending Analysis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
      ),
      home: const SpendingAnalysisPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SpendingAnalysisPage extends StatefulWidget {
  const SpendingAnalysisPage({super.key});

  @override
  State<SpendingAnalysisPage> createState() => _SpendingAnalysisPageState();
}

class _SpendingAnalysisPageState extends State<SpendingAnalysisPage> {
  final List<Expense> expenses = [];
  String selectedCategory = "All";

  void _openExpenseForm() async {
    final expense = await showModalBottomSheet<Expense>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ExpenseForm(),
    );

    if (expense != null) {
      setState(() {
        expenses.add(expense);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spending Analysis"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openExpenseForm,
            tooltip: 'Add Expense',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Colors.deepPurple.shade900,
                    Colors.indigo.shade900,
                    Colors.black,
                  ]
                : [
                    Colors.blue.shade50,
                    Colors.blue.shade100,
                    Colors.white,
                  ],
          ),
        ),
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
                    const SizedBox(height: 80), // Space for app bar
                    
                    // Category Filter Chip Bar
                    _buildCategoryFilter(),
                    
                    // Summary Cards
                    _buildSummaryCards(),
                    
                    // Charts Section
                    SizedBox(
                      height: 400,
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            const TabBar(
                              tabs: [
                                Tab(icon: Icon(Icons.pie_chart)),
                                Tab(icon: Icon(Icons.bar_chart)),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildPieChart(isDarkMode),
                                  _buildBarChart(isDarkMode),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Expense List Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recent Expenses",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    
                    // Expense List
                    _buildExpenseList(isDarkMode),
                    
                    // Add some bottom padding
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openExpenseForm,
        child: const Icon(Icons.add),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ["All", "Food", "Transport", "Entertainment", "Shopping", "Bills"];
    final theme = Theme.of(context);
    
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
              selectedColor: theme.primaryColor.withOpacity(0.2),
              checkmarkColor: theme.primaryColor,
              labelStyle: TextStyle(
                color: selectedCategory == category ? theme.primaryColor : null,
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.7),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards() {
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
          // Total Spent Card
          _buildSummaryCard(
            "Total Spent",
            "\$${totalSpent.toStringAsFixed(2)}",
            Colors.redAccent,
            Icons.attach_money,
          ),
          // Average Spending Card
          _buildSummaryCard(
            "Avg Spending",
            "\$${avgSpending.toStringAsFixed(2)}",
            Colors.orangeAccent,
            Icons.trending_up,
          ),
          // Budget Card
          _buildSummaryCard(
            "Remaining",
            "\$${remainingBudget.toStringAsFixed(2)}",
            remainingBudget >= 0 ? Colors.green : Colors.red,
            remainingBudget >= 0 ? Icons.check_circle : Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        color: isDarkMode 
            ? Colors.black.withOpacity(0.4)
            : Colors.white.withOpacity(0.8),
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
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
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

  Widget _buildPieChart(bool isDarkMode) {
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
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: filteredExpenses.map((expense) {
            return PieChartSectionData(
              value: expense.amount,
              title: "${expense.category}\n\$${expense.amount.toStringAsFixed(2)}",
              color: getCategoryColor(expense.category),
              radius: 80,
              titleStyle: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDarkMode) {
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
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      filteredExpenses[value.toInt()].category.substring(0, 3),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: filteredExpenses.asMap().entries.map((entry) {
            final index = entry.key;
            final expense = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: expense.amount,
                  color: getCategoryColor(expense.category),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseList(bool isDarkMode) {
    final filteredExpenses = selectedCategory == "All"
        ? expenses
        : expenses.where((e) => e.category == selectedCategory).toList();

    if (filteredExpenses.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No expenses recorded",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _openExpenseForm,
                child: const Text("Add Your First Expense"),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: filteredExpenses.length,
      itemBuilder: (context, index) {
        final expense = filteredExpenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          elevation: 1,
          color: isDarkMode 
              ? Colors.black.withOpacity(0.4)
              : Colors.white.withOpacity(0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            subtitle: Text(
              expense.date,
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[600]),
            ),
            trailing: Text(
              "\$${expense.amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food": return Icons.restaurant;
      case "Transport": return Icons.directions_car;
      case "Entertainment": return Icons.movie;
      case "Shopping": return Icons.shopping_bag;
      case "Bills": return Icons.receipt;
      default: return Icons.money;
    }
  }
}

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = "Food";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Colors.deepPurple.shade800,
                    Colors.indigo.shade800,
                  ]
                : [
                    Colors.blue.shade100,
                    Colors.white,
                  ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Add New Expense",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: isDarkMode 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                ),
                items: ["Food", "Transport", "Entertainment", "Shopping", "Bills"]
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  prefixText: "\$ ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: isDarkMode 
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
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
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_selectedDate.toLocal()}".split(' ')[0],
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final expense = Expense(
                      category: _selectedCategory,
                      amount: double.parse(_amountController.text),
                      date: "${_selectedDate.toLocal()}".split(' ')[0],
                    );
                    Navigator.pop(context, expense);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Add Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Expense {
  final String category;
  final double amount;
  final String date;

  Expense({
    required this.category,
    required this.amount,
    required this.date,
  });
}

Color getCategoryColor(String category) {
  switch (category) {
    case "Food": return Colors.green;
    case "Transport": return Colors.blue;
    case "Entertainment": return Colors.orange;
    case "Shopping": return Colors.purple;
    case "Bills": return Colors.red;
    default: return Colors.grey;
  }
}