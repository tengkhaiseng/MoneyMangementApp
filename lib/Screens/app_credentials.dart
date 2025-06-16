class AppCredentials {
  final String username;
  final String email;
  final String phone;
  final String password;

  const AppCredentials({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, String> toMap() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  factory AppCredentials.fromMap(Map<String, dynamic> map) => AppCredentials(
        username: map['username'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        password: map['password'] ?? '',
      );
}