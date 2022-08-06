import 'package:flutter_chat_types/flutter_chat_types.dart';

enum APIMessageType { text, image, file }

class APIMessage {
  final APIMessageType type;

  final String senderUuid;
  final int tutorshipId;


  final DateTime timeSent;
  String? textContent;

  APIMessage(
      {required this.type,
      required this.senderUuid,
      required this.tutorshipId,
      required this.timeSent,
      this.textContent});

  factory APIMessage.fromJson(Map<String, dynamic> json) {
    print(json);
    final timeSent = json['time_sent'].toDate();

    print('$timeSent of type ${timeSent.runtimeType}');
    return APIMessage(
        type: APIMessageType.values.byName(json['type']),
        senderUuid: json['sender_uuid'],
        tutorshipId: json['tutorship_id'],
        textContent: json['text_content'],
        timeSent: timeSent);
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'sender_uuid': senderUuid,
        'tutorship_id': tutorshipId,
        'text_content': textContent,
        'time_sent': timeSent
      };
}
