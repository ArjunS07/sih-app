import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sih_app/models/platform_user.dart';
import 'package:sih_app/models/tutorship.dart';

class ChatPage extends StatefulWidget {
  final Tutorship tutorship;
  final PlatformUser loggedInUser;
  final bool isLoggedInStudent;

  const ChatPage(
      {super.key,
      required this.tutorship,
      required this.loggedInUser,
      required this.isLoggedInStudent});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late types.User _user;

  final List<types.Message> _messages = [];
  bool _isAttachmentUploading = false;
  late String loggedInUserUuid; // convenience variable

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loggedInUserUuid = widget.loggedInUser.uuid;
    _user = types.User(
      id: loggedInUserUuid
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
    // TODO: Send API request
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: message.text,
        id: randomString() // we dont care about this very much
        );

    _addMessage(textMessage);
  }

  // helpers
  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }
}
