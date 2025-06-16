import 'package:flutter/material.dart';
import 'expenses_page.dart';
import 'budget_page.dart';
import 'saving_goals_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'spending_analysis_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  final String user;
  final String email;
  final String phone;

  const HomePage({
    super.key,
    required this.user,
    required this.email,
    required this.phone,
  });

  Future<void> _showNotifications(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications"),
        content: SizedBox(
          width: double.maxFinite,
          child: notifications.isEmpty
              ? const Text("No notifications yet.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(notifications[index]),
                  ),
                ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Manager'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade50.withOpacity(0.3),
                  Colors.white,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 24),
                  _buildQuickStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Financial Tools'),
                  const SizedBox(height: 16),
                  _buildFinancialToolsGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Recent Activity'),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(),
                ],
              ),
            ),
          ),
          // Currency button at bottom right
          Positioned(
            bottom: 90,
            right: 24,
            child: FloatingActionButton.small(
              heroTag: 'currencyBtn',
              backgroundColor: Colors.teal,
              child: const Icon(Icons.currency_exchange),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const CurrencyDialog(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.isNotEmpty ? user[0].toUpperCase() : "?",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    Icons.person,
                    'Profile',
                    ProfilePage(user: user, email: email, phone: phone),
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.settings,
                    'Settings',
                    const SettingsPage(),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    Icons.exit_to_app,
                    'Logout',
                    LoginPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Today is ${DateTime.now().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Balance', '\$2,450.00', Icons.account_balance),
          _buildStatItem('Monthly Budget', '\$1,450.00', Icons.pie_chart),
          _buildStatItem('Savings', '\$1000.00', Icons.savings),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget _buildFinancialToolsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildToolCard(
          context,
          'Expenses Tracker',
          Icons.receipt,
          [Colors.red.shade100, Colors.red.shade50],
          const ExpensesPage(),
        ),
        _buildToolCard(
          context,
          'Budget Planner',
          Icons.pie_chart,
          [Colors.green.shade100, Colors.green.shade50],
          const BudgetPage(),
        ),
        _buildToolCard(
          context,
          'Savings Goals',
          Icons.savings,
          [Colors.blue.shade100, Colors.blue.shade50],
          const SavingsGoalPage(),
        ),
        _buildToolCard(
          context,
          'Spending Analysis',
          Icons.analytics,
          [Colors.purple.shade100, Colors.purple.shade50],
          const SpendingAnalysisPage(),
        ),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> colors,
    Widget page,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final recentTransactions = [
      {'name': 'Grocery Store', 'amount': '-\$85.20', 'time': 'Today, 10:30 AM'},
      {'name': 'Salary Deposit', 'amount': '+\$2,500.00', 'time': 'Yesterday'},
      {'name': 'Electric Bill', 'amount': '-\$120.50', 'time': '2 days ago'},
      {'name': 'Coffee Shop', 'amount': '-\$4.75', 'time': '3 days ago'},
    ];

    return Column(
      children: recentTransactions.map((transaction) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: transaction['amount']!.startsWith('+')
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction['amount']!.startsWith('+')
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: transaction['amount']!.startsWith('+')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            title: Text(
              transaction['name']!,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            subtitle: Text(
              transaction['time']!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            trailing: Text(
              transaction['amount']!,
              style: TextStyle(
                color: transaction['amount']!.startsWith('+')
                    ? Colors.green
                    : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// --- CurrencyDialog Widget ---
class CurrencyDialog extends StatefulWidget {
  const CurrencyDialog({super.key});

  @override
  State<CurrencyDialog> createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends State<CurrencyDialog> {
  final List<String> currencies = [
    'USD', 'MYR', 'EUR', 'GBP', 'JPY', 'SGD', 'AUD', 'CNY', 'INR'
  ];
  final Map<String, String> currencySymbols = {
    'USD': '\$', 'MYR': 'RM', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'SGD': '\$', 'AUD': '\$', 'CNY': '¥', 'INR': '₹'
  };
  String from = 'MYR';
  String to = 'USD';
  double? rate;
  bool loading = false;
  String? error;
  final amountController = TextEditingController(text: "1.0");
  double amount = 1.0;

  Future<void> fetchRate() async {
    setState(() {
      loading = true;
      error = null;
      rate = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/$from'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rate = (data['rates'][to] as num?)?.toDouble();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch rate';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRate();
    amountController.addListener(() {
      setState(() {
        amount = double.tryParse(amountController.text) ?? 1.0;
      });
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromSymbol = currencySymbols[from] ?? '';
    final toSymbol = currencySymbols[to] ?? '';

    return AlertDialog(
      title: const Text('Currency Converter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Currency icon row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currencies.map((c) {
              return IconButton(
                icon: Text(
                  currencySymbols[c] ?? c,
                  style: TextStyle(
                    fontSize: 20,
                    color: c == from ? Colors.teal : Colors.grey,
                  ),
                ),
                tooltip: c,
                onPressed: () {
                  setState(() {
                    from = c;
                  });
                  fetchRate();
                },
              );
            }).toList(),
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: from,
                  isExpanded: true,
                  items: currencies
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('$c (${currencySymbols[c] ?? ''})'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      from = v!;
                    });
                    fetchRate();
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.swap_horiz),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: to,
                  isExpanded: true,
                  items: currencies
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('$c (${currencySymbols[c] ?? ''})'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      to = v!;
                    });
                    fetchRate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: fromSymbol,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          loading
              ? const CircularProgressIndicator()
              : error != null
                  ? Text(error!, style: const TextStyle(color: Colors.red))
                  : rate != null
                      ? Text(
                          '$fromSymbol${amount.toStringAsFixed(2)} $from = $toSymbol${(amount * rate!).toStringAsFixed(2)} $to',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : const SizedBox.shrink(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}