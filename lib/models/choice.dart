class Choice{
  final String id;
  final String name;

  Choice({required this.id, required this.name});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'],
      name: json['name']
    );
  }
}
