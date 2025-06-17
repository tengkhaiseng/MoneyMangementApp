import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'app_credentials.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasRegisteredUser = false;
  AppCredentials? _registeredUser;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRegisteredUser();
  }

  Future<void> _loadRegisteredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    final email = prefs.getString('email');
    final phone = prefs.getString('phone');
    if (username != null && password != null && email != null && phone != null) {
      setState(() {
        _hasRegisteredUser = true;
        _registeredUser = AppCredentials(
          username: username,
          password: password,
          email: email,
          phone: phone,
        );
      });
    } else {
      setState(() {
        _hasRegisteredUser = false;
        _registeredUser = null;
      });
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your username';
    if (value.length < 4) return 'Username too short';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      final password = prefs.getString('password');
      final email = prefs.getString('email');
      final phone = prefs.getString('phone');

      if (username == null ||
          password == null ||
          email == null ||
          phone == null ||
          usernameController.text.trim() != username ||
          passwordController.text != password) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Account does not exist or wrong password.";
        });
      } else {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              user: username,
              email: email,
              phone: phone,
            ),
          ),
        );
      }
    }
  }

  Future<void> _navigateToRegister() async {
    final credentials = await Navigator.push<AppCredentials>(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );

    if (credentials != null && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', credentials.username);
      await prefs.setString('password', credentials.password);
      await prefs.setString('email', credentials.email);
      await prefs.setString('phone', credentials.phone);

      setState(() {
        _hasRegisteredUser = true;
        _registeredUser = credentials;
        usernameController.text = credentials.username;
        passwordController.text = credentials.password;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please sign in'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const FlutterLogo(size: 100),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: hintColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: hintColor),
                        prefixIcon: Icon(Icons.person_outline, color: hintColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: _validateUsername,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: hintColor),
                        prefixIcon: Icon(Icons.lock_outlined, color: hintColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: hintColor,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: _validatePassword,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 8),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('SIGN IN'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: _navigateToRegister,
                    child: const Text(
                      'Register Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}