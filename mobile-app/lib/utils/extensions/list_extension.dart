extension ListExtension on List {
  String joinedWithAnd() {
    if (length == 1) {
      return first;
    }
    String message = sublist(0, length - 1).join(', ');
    message += ' and ${this[length - 1]}';
    return message;
  }
}
