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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.background;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Manager'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context, theme),
      body: Container(
        color: bgColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(theme, textColor),
              const SizedBox(height: 24),
              _buildQuickStatsRow(theme, cardColor, textColor, isDark),
              const SizedBox(height: 24),
              _buildSectionHeader('Financial Tools', theme, textColor),
              const SizedBox(height: 16),
              _buildFinancialToolsGrid(context, theme, cardColor, textColor, isDark),
              const SizedBox(height: 24),
              _buildSectionHeader('Recent Activity', theme, textColor),
              const SizedBox(height: 16),
              _buildRecentActivityList(theme, cardColor, textColor, isDark),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'currencyBtn',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            child: const Icon(Icons.currency_exchange),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const CurrencyDialog(),
              );
            },
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final background = theme.colorScheme.background;

    return Drawer(
      child: Container(
        color: isDark ? theme.colorScheme.surface : background,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primary.withOpacity(0.18)
                    : theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: primary,
                    child: Text(
                      user.isNotEmpty ? user[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 28,
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                    ),
                  ),
                ],
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
                    theme,
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.settings,
                    'Settings',
                    const SettingsPage(),
                    theme,
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    Icons.exit_to_app,
                    'Logout',
                    LoginPage(),
                    theme,
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
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDark
              ? theme.colorScheme.onSurface
              : theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Today is ${DateTime.now().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(
      ThemeData theme, Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Balance', '\$2,450.00', Icons.account_balance, theme),
          _buildStatItem('Monthly Budget', '\$1,450.00', Icons.pie_chart, theme),
          _buildStatItem('Savings', '\$1000.00', Icons.savings, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildFinancialToolsGrid(BuildContext context, ThemeData theme,
      Color cardColor, Color textColor, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.2,
      children: [
        _buildToolCard(
          context,
          'Expenses Tracker',
          Icons.receipt_long,
          theme,
          cardColor,
          textColor,
          const ExpensesPage(),
        ),
        _buildToolCard(
          context,
          'Budget Planner',
          Icons.pie_chart,
          theme,
          cardColor,
          textColor,
          const BudgetPage(language: '',),
        ),
        _buildToolCard(
          context,
          'Savings Goals',
          Icons.savings,
          theme,
          cardColor,
          textColor,
          const SavingsGoalPage(language: '',),
        ),
        _buildToolCard(
          context,
          'Spending Analysis',
          Icons.analytics,
          theme,
          cardColor,
          textColor,
          const SpendingAnalysisPage(),
        ),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    ThemeData theme,
    Color cardColor,
    Color textColor,
    Widget page,
  ) {
    return Card(
      elevation: 2,
      color: cardColor,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(
      ThemeData theme, Color cardColor, Color textColor, bool isDark) {
    final recentTransactions = [
      {'name': 'Grocery Store', 'amount': '-\$85.20', 'time': 'Today, 10:30 AM'},
      {'name': 'Salary', 'amount': '+\$2,000.00', 'time': 'Yesterday, 09:00 AM'},
      {'name': 'Netflix', 'amount': '-\$17.99', 'time': 'Yesterday, 08:00 PM'},
      {'name': 'Bus Ticket', 'amount': '-\$2.50', 'time': '2 days ago, 07:45 AM'},
    ];

    return Column(
      children: recentTransactions.map((transaction) {
        final isIncome = transaction['amount']!.startsWith('+');
        return Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              transaction['name']!,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            subtitle: Text(
              transaction['time']!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            trailing: Text(
              transaction['amount']!,
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class CurrencyDialog extends StatefulWidget {
  const CurrencyDialog({super.key});

  @override
  State<CurrencyDialog> createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends State<CurrencyDialog> {
  final amountController = TextEditingController();
  String from = 'USD';
  String to = 'MYR';
  double? rate;
  double amount = 0;
  bool loading = false;
  String? error;

  final Map<String, String> symbols = {
    'USD': '\$',
    'MYR': 'RM',
    'EUR': '€',
    'SGD': 'S\$',
    'JPY': '¥',
  };

  Future<void> _convert() async {
    setState(() {
      loading = true;
      error = null;
      rate = null;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://api.exchangerate-api.com/v4/latest/$from'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        if (rates.containsKey(to)) {
          setState(() {
            rate = (rates[to] as num).toDouble();
          });
        } else {
          setState(() {
            error = 'Currency not supported';
          });
        }
      } else {
        setState(() {
          error = 'Failed to fetch rate';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromSymbol = symbols[from] ?? '';
    final toSymbol = symbols[to] ?? '';
    return AlertDialog(
      title: const Text('Currency Converter'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: from,
                  items: symbols.keys
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => from = val!);
                  },
                  decoration: const InputDecoration(labelText: 'From'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: to,
                  items: symbols.keys
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => to = val!);
                  },
                  decoration: const InputDecoration(labelText: 'To'),
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
            onChanged: (val) {
              setState(() {
                amount = double.tryParse(val) ?? 0;
              });
            },
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
        ElevatedButton(
          onPressed: loading ? null : _convert,
          child: const Text('Convert'),
        ),
      ],
    );
  }
}