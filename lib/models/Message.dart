import 'tutorship.dart';

class Message {
  Tutorship tutorship;
  String? text;
  DateTime timeSent;
  String senderUuid;
  String? folderPath;

  Message({
    required this.tutorship,
    this.text,
    required this.timeSent,
    required this.senderUuid,
    this.folderPath,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      tutorship: Tutorship.fromJson(json['tutorship']),
      text: json['text'] as String?,
      timeSent: DateTime.parse(json['time_sent']),
      senderUuid: json['sender_uuid'] as String,
      folderPath: json['folder_path'] as String?,
    );
  }
}
