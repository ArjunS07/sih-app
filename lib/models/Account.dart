class Account {
  final String email;
  final String firstName;
  final String lastName;
  final int accountId;
  String? authToken = '';

  Account({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountId,
    this.authToken
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      accountId: json['id'] as int
    );
  }
}