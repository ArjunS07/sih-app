class Account {
  final String email;
  final String firstName;
  final String lastName;
  final int accountId;

  const Account({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.accountId
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      accountId: json['pk'] as int
    );
  }
}