import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> expenses = [];

  final List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Bills',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> decoded = jsonDecode(expensesJson);
      setState(() {
        expenses = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(expenses));
  }

  void _addExpense() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      expenses.add({
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'description': descriptionController.text,
        'category': selectedCategory,
        'date': selectedDate.toIso8601String(),
      });
      amountController.clear();
      descriptionController.clear();
      selectedCategory = 'Food';
      selectedDate = DateTime.now();
    });
    _saveExpenses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Expense added successfully"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editExpense(int index) async {
    final expense = expenses[index];
    final amountEditController = TextEditingController(text: expense['amount'].toString());
    final descEditController = TextEditingController(text: expense['description']);
    String editCategory = expense['category'];
    DateTime editDate = DateTime.tryParse(expense['date']) ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Expense"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: amountEditController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descEditController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: editCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) editCategory = val;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text("Date"),
                  subtitle: Text(_formatDate(editDate)),
                  trailing: TextButton(
                    child: const Text("Change"),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: editDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => editDate = picked);
                        Navigator.of(context).pop();
                        _editExpense(index); // Reopen dialog with updated date
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  expenses[index] = {
                    'amount': double.tryParse(amountEditController.text) ?? 0.0,
                    'description': descEditController.text,
                    'category': editCategory,
                    'date': editDate.toIso8601String(),
                  };
                });
                _saveExpenses();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
    _saveExpenses();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String _formatDisplayDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills':
        return Icons.receipt;
      case 'Others':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses Tracker"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        color: colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surface.withOpacity(0.8)
                            : colorScheme.surface,
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
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surface.withOpacity(0.8)
                            : colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surface.withOpacity(0.8)
                            : colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text("Date"),
                      subtitle: Text(_formatDate(selectedDate)),
                      trailing: TextButton(
                        child: const Text("Change"),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _addExpense,
                        child: const Text("Add Expense"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Text(
                        "No expenses yet.\nAdd your first expense above.",
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final isIncome = (expense['amount'] as double) > 0;
                        return Card(
                          color: isDark
                              ? colorScheme.surfaceVariant.withOpacity(0.7)
                              : colorScheme.surface,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(expense['category']),
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              expense['description'],
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey[900],
                              ),
                            ),
                            subtitle: Text(
                              "${expense['category']} • ${_formatDisplayDate(expense['date'])}",
                              style: textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[700],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${expense['amount'] < 0 ? '-' : '+'}\$${expense['amount'].abs().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: "Edit",
                                  onPressed: () => _editExpense(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  tooltip: "Delete",
                                  onPressed: () => _deleteExpense(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}