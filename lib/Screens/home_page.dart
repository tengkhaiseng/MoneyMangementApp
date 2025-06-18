import 'package:flutter/material.dart';
import 'expenses_page.dart';
import 'budget_page.dart';
import 'saving_goals_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'spending_analysis_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String user;
  final String email;
  final String phone;

  const HomePage({
    super.key,
    required this.user,
    required this.email,
    required this.phone,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getStringList('notifications') ?? [];
    });
  }

  Future<void> addNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifs = prefs.getStringList('notifications') ?? [];
    notifs.insert(0, message);
    await prefs.setStringList('notifications', notifs);
    setState(() {
      notifications = notifs;
    });
  }

  void _showNotifications(BuildContext context) async {
    await _loadNotifications();
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
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context, theme),
      body: Container(
        decoration: isDark
            ? null
            : const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFe8f5e9),
                    Color(0xFFb2f7cc),
                    Color(0xFFd0f8ce),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(theme, textColor, isDark),
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
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: isDark
                    ? null
                    : const LinearGradient(
                        colors: [
                          Color(0xFF43e97b),
                          Color(0xFF38f9d7),
                          Color(0xFF43e97b),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isDark ? Colors.green[900] : null,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        widget.user.isNotEmpty ? widget.user[0].toUpperCase() : "?",
                        style: TextStyle(
                          fontSize: 28,
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.user,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.green[800]?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.green[800]?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
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
                  ProfilePage(user: widget.user, email: widget.email, phone: widget.phone),
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
                  const LoginPage(),
                  theme,
                ),
              ],
            ),
          ),
        ],
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
      leading: Icon(icon, color: isDark ? Colors.green : Colors.green[700]),
      title: Text(
        title,
        style: TextStyle(
          color: isDark
              ? theme.colorScheme.onSurface
              : Colors.green[900],
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme, Color textColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.green[900],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.green.withOpacity(0.18)
                : Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Today is ${DateTime.now().toString().split(' ')[0]}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.green[200] : Colors.green[900],
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
        color: isDark ? cardColor : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.green.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Balance', '\$2,450.00', Icons.account_balance, theme, isDark),
          _buildStatItem('Monthly Budget', '\$1,450.00', Icons.pie_chart, theme, isDark),
          _buildStatItem('Savings', '\$1000.00', Icons.savings, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String title, String value, IconData icon, ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.green.withOpacity(0.15)
                : Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: isDark ? Colors.green : Colors.green[700]),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white70 : Colors.green[900],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.green[900],
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
          color: Colors.green[800],
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
          isDark,
        ),
        _buildToolCard(
          context,
          'Budget Planner',
          Icons.pie_chart,
          theme,
          cardColor,
          textColor,
          BudgetPage(
            language: 'en',
            onBudgetSaved: () async { return; }, // required param
          ),
          isDark,
        ),
        _buildToolCard(
          context,
          'Savings Goals',
          Icons.savings,
          theme,
          cardColor,
          textColor,
          const SavingsGoalPage(),
          isDark,
        ),
        _buildToolCard(
          context,
          'Spending Analysis',
          Icons.analytics,
          theme,
          cardColor,
          textColor,
          const SpendingAnalysisPage(),
          isDark,
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
    bool isDark,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.green.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green.withOpacity(0.13)
                    : Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? Colors.green : Colors.green[700],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.green[900],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(
      ThemeData theme, Color cardColor, Color textColor, bool isDark) {
    // Dummy data for recent activity
    final recent = [
      {
        'name': 'Grocery Shopping',
        'amount': '-\$45.00',
        'time': '2025-06-17',
        'isIncome': false,
      },
      {
        'name': 'Salary',
        'amount': '+\$1,200.00',
        'time': '2025-06-15',
        'isIncome': true,
      },
      {
        'name': 'Electricity Bill',
        'amount': '-\$60.00',
        'time': '2025-06-14',
        'isIncome': false,
      },
    ];

    return Column(
      children: recent
          .map(
            (transaction) => Card(
              elevation: 0,
              color: isDark ? cardColor : Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: transaction['isIncome'] as bool
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction['isIncome'] as bool
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: transaction['isIncome'] as bool
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                title: Text(
                  transaction['name'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.green[900],
                  ),
                ),
                subtitle: Text(
                  transaction['time'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.green[800]?.withOpacity(0.7),
                  ),
                ),
                trailing: Text(
                  transaction['amount'] as String,
                  style: TextStyle(
                    color: transaction['isIncome'] as bool
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}