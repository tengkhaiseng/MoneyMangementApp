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
  String language = 'en';
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLanguage();
    _loadNotifications();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('profile_email') ?? prefs.getString('email') ?? 'user@email.com';
      phone = prefs.getString('profile_phone') ?? prefs.getString('phone') ?? '+60 123456789';
      user = prefs.getString('username') ?? 'User';
      password = prefs.getString('password') ?? '';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_email', email);
    await prefs.setString('profile_phone', phone);
    await prefs.setString('password', password);
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() {
      language = lang;
    });
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
    notifications.insert(0, message);
    await prefs.setStringList('notifications', notifications);
    setState(() {});
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
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
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
        title: Text(language == 'ms' ? "Tetapan" : "Settings"),
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
                language == 'ms' ? "AKAUN" : "ACCOUNT",
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
                    title: language == 'ms' ? "Tukar Kata Laluan" : "Change Password",
                    subtitle: language == 'ms'
                        ? "Kemas kini kata laluan anda"
                        : "Update your login password",
                    showTrailing: true,
                    onTap: () {
                      _editField(
                        language == 'ms' ? "Kata Laluan" : "Password",
                        password,
                        (val) {
                          password = val;
                          _addNotification(language == 'ms'
                              ? "Kata laluan berjaya ditukar"
                              : "Password changed successfully");
                        },
                        isPassword: true,
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.email_outlined,
                    title: language == 'ms' ? "Tukar Emel" : "Change Email",
                    subtitle: email,
                    showTrailing: true,
                    onTap: () {
                      _editField(
                        language == 'ms' ? "Emel" : "Email",
                        email,
                        (val) {
                          email = val;
                          _addNotification(language == 'ms'
                              ? "Emel berjaya dikemaskini"
                              : "Email updated successfully");
                        },
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.phone_android_outlined,
                    title: language == 'ms' ? "Nombor Telefon" : "Phone Number",
                    subtitle: phone,
                    showTrailing: true,
                    onTap: () {
                      _editField(
                        language == 'ms' ? "Telefon" : "Phone",
                        phone,
                        (val) {
                          phone = val;
                          _addNotification(language == 'ms'
                              ? "Nombor telefon berjaya dikemaskini"
                              : "Phone number updated successfully");
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
                language == 'ms' ? "TETAPAN APLIKASI" : "APP SETTINGS",
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
                    title: language == 'ms' ? "Tema" : "Theme",
                    subtitle: isDarkMode
                        ? (language == 'ms' ? "Mod Gelap" : "Dark Mode")
                        : (language == 'ms' ? "Mod Cerah" : "Light Mode"),
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
                    icon: Icons.language,
                    title: language == 'ms' ? "Bahasa" : "Language",
                    subtitle: language == 'ms' ? "Melayu" : "English",
                    showTrailing: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(language == 'ms'
                              ? "Pilih Bahasa"
                              : "Select Language"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<String>(
                                value: 'en',
                                groupValue: language,
                                onChanged: (val) {
                                  _saveLanguage(val!);
                                  Navigator.pop(context);
                                },
                                title: const Text("English"),
                              ),
                              RadioListTile<String>(
                                value: 'ms',
                                groupValue: language,
                                onChanged: (val) {
                                  _saveLanguage(val!);
                                  Navigator.pop(context);
                                },
                                title: const Text("Melayu"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: language == 'ms' ? "Notifikasi" : "Notifications",
                    subtitle: language == 'ms'
                        ? "Lihat notifikasi terkini"
                        : "View recent notifications",
                    showTrailing: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(language == 'ms'
                              ? "Notifikasi"
                              : "Notifications"),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: notifications.isEmpty
                                ? Text(language == 'ms'
                                    ? "Tiada notifikasi"
                                    : "No notifications yet.")
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: notifications.length,
                                    itemBuilder: (context, index) => ListTile(
                                      leading:
                                          const Icon(Icons.notifications),
                                      title: Text(notifications[index]),
                                    ),
                                  ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(language == 'ms'
                                  ? "Tutup"
                                  : "Close"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.share_outlined,
                    title: language == 'ms'
                        ? "Kongsi dengan rakan"
                        : "Tell your friends",
                    subtitle: language == 'ms'
                        ? "Kongsi aplikasi ini"
                        : "Share this app",
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
                  child: Text(language == 'ms' ? "Log Keluar" : "Log Out"),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// Helper for other pages to add notifications
Future<void> addNotification(String message) async {
  final prefs = await SharedPreferences.getInstance();
  final notifications = prefs.getStringList('notifications') ?? [];
  notifications.insert(0, message);
  await prefs.setStringList('notifications', notifications);
}