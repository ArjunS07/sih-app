import 'dart:convert';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';


import 'package:sih_app/models/platform_user.dart';
import 'package:sih_app/models/tutorship.dart';
import 'package:sih_app/models/api_message.dart';



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
  late var messagesCollection = db
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

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
      _messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    });
  }

  void _sendMessage(types.TextMessage message) async {
    final APIMessage apiMessage = APIMessage(
        senderUuid: _loggedInUserUuid,
        textContent: message.text,
        type: APIMessageType.text,
        timeSent: DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
        tutorshipId: widget.tutorship.id);

    var messageDocResponse = await messagesCollection
        .doc(message.id)
        .set(apiMessage); // set at a custom ID in the reference collection
  }

  void addSnapshotListener() {
    messagesCollection.snapshots().listen(
      (event) {
        final isPendingLocalUpload = (event.metadata.hasPendingWrites);
        if (isPendingLocalUpload) {
          return;
        }
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              final doc = change.doc;
              addFirebaseMessageDoc(doc);
              break;
            case DocumentChangeType.removed:
              print('Detected deletion');
              _messages.removeWhere((message) => message.id == change.doc.id);
              break;
            default:
              break;
          }
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  // Add message to list. Called by master methods which handle API
  void addFirebaseMessageDoc(doc) {
    final message = doc.data() as APIMessage;
    if (message.type == APIMessageType.text) {
      bool wasSentByLoggedIn = message.senderUuid == _loggedInUserUuid;
      final id = doc.id;

      _addMessage(types.TextMessage(
        author: wasSentByLoggedIn ? _loggedInChatTypeUser : _otherChatTypeUser,
        id: id,
        text: message.textContent!,
        createdAt: message.timeSent.millisecondsSinceEpoch,
      ));
    }
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
        appBar: AppBar(
          title: Text(otherUser.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.video_call),
              iconSize: 28.0,
              onPressed: _showZoomPopUp,
            )
          ],
        ),
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _loggedInChatTypeUser,
        ),
      );

  void _handleSendPressed(types.PartialText message) {
    String id = randomString();
    final textMessage = types.TextMessage(
        author: _loggedInChatTypeUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: message.text,
        id: id);

    _addMessage(textMessage);
    _sendMessage(textMessage);
  }

  // Zoom methods
  void _showZoomPopUp() {
    print('Showing zoom pop up');
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
