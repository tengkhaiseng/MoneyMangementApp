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

  void _editField(String title, String initialValue, Function(String) onSaved, {bool isPassword = false}) {
    final controller = TextEditingController(text: initialValue);
    bool obscure = isPassword;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: title == "Phone" ? TextInputType.phone : (isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress),
            decoration: InputDecoration(
              labelText: title,
              border: const OutlineInputBorder(),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setDialogState(() {
                          obscure = !obscure;
                        });
                      },
                    )
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                onSaved(controller.text.trim());
                _saveProfile();
                Navigator.pop(context);
                setState(() {});
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) =>  LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'en',
              groupValue: language,
              title: const Text("English"),
              onChanged: (val) {
                _saveLanguage(val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'ms',
              groupValue: language,
              title: const Text("Bahasa Malaysia"),
              onChanged: (val) {
                _saveLanguage(val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'ms' ? "Tetapan" : "Settings"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 30),
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
                    subtitle: language == 'ms' ? "Kemas kini kata laluan anda" : "Update your login password",
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
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                        _addNotification(language == 'ms'
                            ? (value ? "Mod gelap diaktifkan" : "Mod cerah diaktifkan")
                            : (value ? "Dark mode enabled" : "Light mode enabled"));
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications_none,
                    title: language == 'ms' ? "Notifikasi" : "Notifications",
                    subtitle: language == 'ms'
                        ? "Lihat semua aktiviti"
                        : "View all activities",
                    showTrailing: true,
                    onTap: () => _showNotifications(context),
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.language_outlined,
                    title: language == 'ms' ? "Bahasa" : "Language",
                    subtitle: language == 'ms' ? "Bahasa Malaysia" : "English (US)",
                    showTrailing: true,
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Support Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                language == 'ms' ? "SOKONGAN" : "SUPPORT",
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
                    icon: Icons.help_outline,
                    title: language == 'ms' ? "Pusat Bantuan" : "Help Center",
                    subtitle: language == 'ms'
                        ? "Dapatkan bantuan aplikasi"
                        : "Get help with the app",
                    showTrailing: true,
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.feedback_outlined,
                    title: language == 'ms' ? "Maklum Balas" : "Send Feedback",
                    subtitle: language == 'ms'
                        ? "Kongsi pendapat anda"
                        : "Share your thoughts with us",
                    showTrailing: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                language == 'ms' ? "TENTANG" : "ABOUT",
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
                    icon: Icons.info_outline,
                    title: language == 'ms' ? "Tentang Aplikasi" : "About App",
                    subtitle: "Version 1.0.0",
                    showTrailing: true,
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: "Money Manager",
                        applicationVersion: "1.0.0",
                        applicationLegalese: "© 2025 Your Company",
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            language == 'ms'
                                ? "Aplikasi pengurusan wang yang cantik untuk membantu anda menjejak perbelanjaan dan simpanan anda."
                                : "A beautiful money management app to help you track your expenses and savings.",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.star_border_outlined,
                    title: language == 'ms' ? "Beri Penilaian" : "Rate Us",
                    subtitle: language == 'ms'
                        ? "Kongsi pengalaman anda"
                        : "Share your experience",
                    showTrailing: true,
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.share_outlined,
                    title: language == 'ms' ? "Kongsi Aplikasi" : "Share App",
                    subtitle: language == 'ms'
                        ? "Beritahu rakan anda"
                        : "Tell your friends",
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

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool showTrailing = true,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: showTrailing
          ? trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              )
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
}

// Helper for other pages to add notifications
Future<void> addNotification(String message) async {
  final prefs = await SharedPreferences.getInstance();
  final notifications = prefs.getStringList('notifications') ?? [];
  notifications.insert(0, message);
  await prefs.setStringList('notifications', notifications);
}