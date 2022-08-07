import 'dart:convert';

import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import 'package:sih_app/models/platform_user.dart';
import 'package:sih_app/models/tutorship.dart';
import 'package:sih_app/models/api_message.dart';
import 'package:sih_app/models/zoom_meeting.dart';

import 'package:sih_app/utils/tutorship_api_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  final storageRef = FirebaseStorage.instance.ref();
  ImagePicker picker = ImagePicker();

  final uuid = const Uuid();

  final List<types.Message> _messages = [];

  var _reportTextController = TextEditingController();

  late types.User _loggedInChatTypeUser;
  late types.User _otherChatTypeUser;
  late PlatformUser otherUser;
  late String _loggedInUserUuid; // convenience variable
  late String _otherUserUuid;

  // local sending and adding
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
      _messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    });
  }

  // Database stuff
  void addFirebaseMessageDoc(doc) async {
    final message = doc.data() as APIMessage;
    bool wasSentByLoggedIn = message.senderUuid == _loggedInUserUuid;
    final author =
        wasSentByLoggedIn ? _loggedInChatTypeUser : _otherChatTypeUser;
    final id = doc.id;

    if (message.type == APIMessageType.text) {
      _addMessage(types.TextMessage(
        author: author,
        id: id,
        text: message.textContent!,
        createdAt: message.timeSent.millisecondsSinceEpoch,
      ));
      return;
    }
    // File or image message

    // Download all files associated with the image
    final files = messageFirebaseFiles(id);
    for (var file in files) {
      final url = await file.getDownloadURL();
      final extension = url.path.split('.').last;
    }
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
              final data = doc.data() as APIMessage;
              if (data.tutorshipId == widget.tutorship.id) {
                addFirebaseMessageDoc(doc);
              }
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.video_call),
              onPressed: _showZoomPopUp,
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: Icon(Icons.report, color: Colors.red.shade400),
              onPressed: _report,
            ),
            const SizedBox(width: 5)
          ],
        ),
        body: Chat(
          messages: _messages,
          onSendPressed: _handleTextSendPressed,
          user: _loggedInChatTypeUser,
          onAttachmentPressed: _handleAtachmentPress,
        ),
      );

// Text messages
  void _handleTextSendPressed(types.PartialText message) {
    final id = uuid.v4();
    final textMessage = types.TextMessage(
        author: _loggedInChatTypeUser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        text: message.text,
        id: id);

    _addMessage(textMessage);
    _sendTextMessage(textMessage);
  }

  void _sendTextMessage(types.TextMessage message) async {
    final APIMessage apiMessage = APIMessage(
        senderUuid: _loggedInUserUuid,
        textContent: message.text,
        type: APIMessageType.text,
        timeSent: DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
        tutorshipId: widget.tutorship.id);

    await messagesCollection
        .doc(message.id)
        .set(apiMessage); // set at a custom ID in the reference collection
  }

  // Attachment messages
  void _handleAtachmentPress() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 275.0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(children: <Widget>[
              ListTile(
                  title: const Text('Open file picker'),
                  onTap: () {
                    _showFilePicker();
                    Navigator.pop(context);
                  }),
              const Divider(),
              ListTile(
                  title: const Text('Open image picker'),
                  onTap: () {
                    _showImagePicker();
                    Navigator.pop(context);
                  }),
              const Divider(),
              ListTile(
                  title: const Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ]),
          ),
        );
      },
    );
  }

  void uploadMessageFileToFirebase(File file) {
    final uploadFolderRef =
        storageRef.child("tutorship/${widget.tutorship.id}");
    uploadFolderRef.putFile(file);
  }

  messageFirebaseFiles(String messageId) async {
    final messageFolderRef =
        storageRef.child("tutorship/${widget.tutorship.id}/$messageId");
    final listResult = await messageFolderRef.listAll();
    final files = listResult.items;
    return files;
  }

  void _showFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final message = types.FileMessage(
        author: _loggedInChatTypeUser,
        id: uuid.v4(),
        name: result.files.single.name,
        mimeType: lookupMimeType(result.files.single.path!),
        size: result.files.single.size,
        uri: result.files.single.path!,
      );
      for (var platformFile in result.files) {
        final file = File(platformFile.path!);
        uploadMessageFileToFirebase(file);
      }
      _addMessage(message);
    } else {
      // User canceled the picker
    }
  }

  void _showImagePicker() async {
    await Permission.photos.request().then((value) async {
      if (await Permission.camera.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.

        final ImagePicker _picker = ImagePicker();
        final pickedImages = await _picker.pickMultiImage();
        if (pickedImages == null) {
          return;
        }
        for (var result in pickedImages) {
          final imageFile = File(result.path);
          final size = imageFile.lengthSync();
          final extension = result.path.split('.').last;

          final message = types.ImageMessage(
            author: _loggedInChatTypeUser,
            id: uuid.v4(),
            name: 'image.$extension',
            size: size,
            uri: result.path,
          );

          uploadMessageFileToFirebase(imageFile);
          _addMessage(message);
        }
      }
    });
    // final pickedImages = await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  // Zoom methods
  void _showZoomPopUp() async {
    final zoomMeeting =
        await getZoomMeetingFromId(widget.tutorship.zoomMeetingId!);

    print('Showing zoom pop up');
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Start zoom session with ${otherUser.name}?'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 25.0),
                Row(
                  children: const [
                    Text('Meeting details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start),
                    Spacer()
                  ],
                ),
                Row(
                  children: [
                    Text('Meeting ID: ${zoomMeeting.meetingId}'),
                    const Spacer(),
                    IconButton(
                        onPressed: () =>
                            {copyToClipboard(zoomMeeting.meetingId)},
                        icon: const Icon(Icons.copy))
                  ],
                ),
                Row(
                  children: [
                    Text('Meeting password: ${zoomMeeting.meetingPassword}'),
                    const Spacer(),
                    IconButton(
                        onPressed: () =>
                            {copyToClipboard(zoomMeeting.meetingPassword)},
                        icon: const Icon(Icons.copy))
                  ],
                ),
                const SizedBox(height: 25.0),
                const Text(
                  'Or launch the meeting directly from the app',
                  style: TextStyle(fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  Text('Close', style: TextStyle(color: Colors.grey.shade500)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              // style: ButtonStyle(
              //     backgroundColor:
              //         MaterialStateProperty.all<Color>(Colors.green)),
              child: const Text('Launch',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final canLaunch =
                    await canLaunchUrlString(zoomMeeting.startUrl);
                if (canLaunch) {
                  launchUrlString(zoomMeeting.startUrl);
                } else {
                  throw 'Could not launch ${zoomMeeting.startUrl}';
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _report() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report ${otherUser.name}?'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _reportTextController,
                  decoration: InputDecoration(
                    labelText: 'Describe what ${otherUser.name} did',
                  ),
                  minLines: 2, //Normal textInputField will be displayed
                  maxLines: 6, //
                  
                ),
                const SizedBox(height: 25),
                Text(
                    widget.isLoggedInStudent
                        ? 'Your school will receive this report'
                        : "The student's school will receive this report",
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600)),
                const SizedBox(height: 15),
                Text('This will suspend your tutorship with ${otherUser.name}',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red)),
              child: const Text('Report',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                print(_reportTextController.text);
                reportTutorship(widget.tutorship, widget.loggedInUser,
                    _reportTextController.text);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Utilities
  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
