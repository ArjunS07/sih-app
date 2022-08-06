import 'dart:convert';

import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:file_picker/file_picker.dart';

import 'package:sih_app/models/platform_user.dart';
import 'package:sih_app/models/tutorship.dart';
import 'package:sih_app/models/api_message.dart';

import 'package:sih_app/utils/base_api_utils.dart';

class ChatPage extends StatefulWidget {
  final Tutorship tutorship;
  final PlatformUser loggedInUser;

  final bool isLoggedInStudent;

  const ChatPage({
    super.key,
    required this.tutorship,
    required this.loggedInUser,
    required this.isLoggedInStudent,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late CollectionReference messagesCollection = db
      .collection('messages')
      .withConverter<APIMessage>(
        fromFirestore: (snapshot, _) => APIMessage.fromJson(snapshot.data()!),
        toFirestore: (model, _) => model.toJson(),
      );
  final List<types.Message> _messages = [];

  late types.User _loggedInChatTypeUser;
  late types.User _otherChatTypeUser;

  late PlatformUser otherUser;
  late String _loggedInUserUuid; // convenience variable
  late String _otherUserUuid;


  void addSnapshotListener() {
    messagesCollection.snapshots().listen(
      (event) {
        final docs = event.docs;
        for (var messageDoc in docs) {
          addFirebaseMessageDoc(messageDoc);
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  @override
  void initState() {
    super.initState();
    _loggedInUserUuid = widget.loggedInUser.uuid;
    otherUser = widget.isLoggedInStudent
        ? widget.tutorship.tutor
        : widget.tutorship.student;
    _otherUserUuid = otherUser.uuid;

    _loggedInChatTypeUser = types.User(id: _loggedInUserUuid);
    if (widget.isLoggedInStudent) {
      _otherChatTypeUser = types.User(id: widget.tutorship.tutor.uuid);
    } else {
      _otherChatTypeUser = types.User(id: widget.tutorship.student.uuid);
    }

    addSnapshotListener();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Chat with ${otherUser.name}')),
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _loggedInChatTypeUser,
        ),
      );

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _loggedInChatTypeUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: message.text,
        id: randomString() // we dont care about this very much
        );

    _sendMessage(textMessage);
  }

  // Add message to list. Called by master methods which handle API
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _sendMessage(types.TextMessage message) async {
    final APIMessage apiMessage = APIMessage(
        senderUuid: _loggedInUserUuid,
        textContent: message.text,
        type: APIMessageType.text,
        timeSent: DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
        tutorshipId: widget.tutorship.id);
    await messagesCollection.add(apiMessage);
  }

  void addFirebaseMessageDoc(doc) {
    final message = doc.data() as APIMessage;
    if (message.type == APIMessageType.text) {
      bool wasSentByLoggedIn = message.senderUuid == _loggedInUserUuid;
      final id = doc.id;
      _addMessage(types.TextMessage(
        author: wasSentByLoggedIn ? _loggedInChatTypeUser : _otherChatTypeUser,
        id: id,
        text: message.textContent!,
      ));
    }
  }

  // helpers
  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
