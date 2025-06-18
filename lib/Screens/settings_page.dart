import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String email = '';
  String phone = '';
  String user = '';
  String password = '';
  bool _loading = true;
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotifications();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? 'user@email.com';
      phone = prefs.getString('phone') ?? '+60 123456789';
      user = prefs.getString('username') ?? 'User';
      password = prefs.getString('password') ?? '';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
    await prefs.setString('password', password);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notif = prefs.getStringList('notifications');
    setState(() {
      notifications = notif ?? [];
    });
  }

  Future<void> _addNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifs = prefs.getStringList('notifications') ?? [];
    notifs.insert(0, message);
    await prefs.setStringList('notifications', notifs);
  }

  void _editField(
    String title,
    String initialValue,
    Function(String) onSaved, {
    bool isPassword = false,
  }) {
    final controller = TextEditingController(text: initialValue);
    bool obscure = isPassword;
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit $title'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              keyboardType: title == "Phone"
                  ? TextInputType.phone
                  : (isPassword
                      ? TextInputType.visiblePassword
                      : TextInputType.emailAddress),
              decoration: InputDecoration(
                labelText: title,
                border: const OutlineInputBorder(),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setDialogState(() {
                            obscure = !obscure;
                          });
                        },
                      )
                    : null,
              ),
              validator: (value) {
                if (isPassword) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                } else if (title == "Email" || title == "Emel") {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                } else if (title == "Phone" || title == "Telefon") {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  onSaved(controller.text.trim());
                  _saveProfile();
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // DO NOT clear all prefs! Only navigate to login page.
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: ListView(
          children: [
            const SizedBox(height: 24),
            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user.isNotEmpty ? user[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 28,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Account Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "ACCOUNT",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    subtitle: "Update your login password",
                    showTrailing: true,
                    onTap: () {
                      _editField(
                        "Password",
                        password,
                        (val) {
                          password = val;
                          _addNotification("You have changed your password.");
                        },
                        isPassword: true,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.email_outlined,
                    title: "Change Email",
                    subtitle: email,
                    showTrailing: true,
                    onTap: () {
                      _editField(
                        "Email",
                        email,
                        (val) {
                          email = val;
                          _addNotification("You have changed your email.");
                        },
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.phone_android_outlined,
                    title: "Phone Number",
                    subtitle: phone,
                    showTrailing: true,
                    onTap: () {
                      _editField(
                        "Phone",
                        phone,
                        (val) {
                          phone = val;
                          _addNotification("You have changed your phone number.");
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "APP SETTINGS",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    icon: Icons.palette_outlined,
                    title: "Theme",
                    subtitle: isDarkMode ? "Dark Mode" : "Light Mode",
                    showTrailing: false,
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (val) {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme(val);
                      },
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.share_outlined,
                    title: "Tell your friends",
                    subtitle: "Share this app",
                    showTrailing: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showLogoutConfirmation(context);
                  },
                  child: Text("Log Out"),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showTrailing,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: showTrailing
          ? trailing ??
              Icon(Icons.chevron_right, color: theme.colorScheme.primary)
          : trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minVerticalPadding: 0,
    );
  }
}