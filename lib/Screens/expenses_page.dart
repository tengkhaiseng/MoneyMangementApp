import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> expenses = [];
  final List<String> categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? expensesString = prefs.getString('expenses');
    if (expensesString != null) {
      setState(() {
        expenses = List<Map<String, dynamic>>.from(json.decode(expensesString));
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('expenses', json.encode(expenses));
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        expenses.insert(0, {
          'amount': double.tryParse(_amountController.text) ?? 0.0,
          'description': _descController.text,
          'category': _selectedCategory,
          'date': _selectedDate.toIso8601String(),
        });
      });
      _saveExpenses();
      _amountController.clear();
      _descController.clear();
      _selectedCategory = categories.first;
      _selectedDate = DateTime.now();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );
    }
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
        final _editFormKey = GlobalKey<FormState>();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Edit Expense"),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountEditController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter amount';
                      if (double.tryParse(value) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: descEditController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter description';
                      return null;
                    },
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
                      editCategory = val!;
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
                    // No trailing button, date is not editable
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editFormKey.currentState!.validate()) {
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
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showExpenseAnalysis() {
    if (expenses.isEmpty) return;
    // Simple breakdown by category
    final Map<String, double> breakdown = {};
    for (var e in expenses) {
      breakdown[e['category']] = (breakdown[e['category']] ?? 0) + (e['amount'] ?? 0);
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Expense Analysis"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Expense Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...breakdown.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text("\$${entry.value.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "Expense Analysis",
            onPressed: _showExpenseAnalysis,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add New Expense Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Add New Expense",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: categories
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
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (\$)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter amount';
                          if (double.tryParse(value) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter description';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text("Date"),
                        subtitle: Text(_formatDate(_selectedDate)),
                        trailing: TextButton(
                          child: const Text("Change"),
                          onPressed: _pickDate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _addExpense,
                        child: const Text("Add Expense"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Expenses List
            Text(
              "Your Expenses",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    "No expenses yet.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ...expenses.asMap().entries.map((entry) {
              final i = entry.key;
              final expense = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.receipt_long, color: Colors.blue.shade700),
                  ),
                  title: Text(
                    "\$${(expense['amount'] ?? 0).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${expense['description']}\n${expense['category']} • ${_formatDate(DateTime.tryParse(expense['date']) ?? DateTime.now())}",
                    style: const TextStyle(height: 1.4),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: "Edit",
                        onPressed: () => _editExpense(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Delete",
                        onPressed: () {
                          setState(() {
                            expenses.removeAt(i);
                          });
                          _saveExpenses();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }
}