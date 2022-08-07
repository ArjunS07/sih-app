import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutorship.dart';

import 'package:sih_app/utils/tutor_api_utils.dart';
import 'package:sih_app/utils/tutorship_api_utils.dart';
import 'chat/chat_page.dart';

class TutorshipChats extends StatefulWidget {
  Tutor? loggedinTutor;
  Student? loggedinStudent;

  TutorshipChats({Key? key, this.loggedinStudent, this.loggedinTutor})
      : super(key: key);

  @override
  State<TutorshipChats> createState() => TutorshipChatsState();
}

class TutorshipChatsState extends State<TutorshipChats> {
  bool isLoggedInStudent = false;
  var _tutorships = <dynamic>[];

  // API interfacing
  Future<void> _loadTutorships() async {
    List<Tutorship> tutorships = [];
    if (isLoggedInStudent) {
      tutorships = await getMyTutorships(student: widget.loggedinStudent);
    } else {
      tutorships = await getMyTutorships(tutor: widget.loggedinTutor);
    }
    setState(() {
      _tutorships = tutorships;
    });
  }

  // state
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.loggedinStudent != null) {
      isLoggedInStudent = true;
    }
    _loadTutorships();
  }

  Future<Map<String, dynamic>> _decodeTutorshipData(Tutorship tutorship) async {
    var data = {
      'subjects': await tutorship.decodedSubjectsDisplay,
    };
    return data;
  }

  // UI stuff
  Widget _buildRow(int index) {
    var tutorship = _tutorships[index];
    final isSuspended = tutorship.status == 'SUSPND';

    return FutureBuilder(
        future: _decodeTutorshipData(tutorship),
        initialData: 'Loading data...',
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Data is loading...');
          } else {
            print(snapshot.data);
            Map data = snapshot.data as Map;
            return ListTile(
              onTap: isSuspended ? null : () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        tutorship: tutorship,
                        loggedInUser: widget.loggedinStudent != null
                            ? widget.loggedinStudent!
                            : widget.loggedinTutor!,
                        isLoggedInStudent: widget.loggedinStudent != null,
                      ),
                    ));
              },
              title: isLoggedInStudent
                  ? Text(tutorship.tutor.name)
                  : Text(tutorship.student.name),
              subtitle: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: RichText(
                      text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          children: [
                        TextSpan(text: data['subjects']),
                        TextSpan(
                            style: isSuspended
                                ? TextStyle(
                                    color: Colors.red.shade300,
                                    fontWeight: FontWeight.bold)
                                : const TextStyle(color: Colors.black),
                            text: isSuspended
                                ? '\nSUSPENDED'
                                : '\nActive since ${tutorship.relativeTimeSinceCreated}')
                      ]))),
              leading: const CircleAvatar(
                  //TODO
                  backgroundImage: NetworkImage(
                      "https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
              trailing: const Icon(Icons.arrow_forward_ios),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.loggedinStudent != null
            ? const Text('My volunteers')
            : const Text('My students'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _tutorships.isEmpty
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: widget.loggedinStudent != null
                              ? Text(
                                  "You have no volunteers teaching you yet. Go to the 'Find' tab to find volunteers.",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade600))
                              : Text(
                                  "You are not teaching any students currently.\n\nOnce a student sends you a request and you accept it, you'll be able to see them here.",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey.shade600))),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                        itemCount: _tutorships.length,
                        itemBuilder: (BuildContext context, int position) {
                          return _buildRow(position);
                        },
                        separatorBuilder: (context, index) {
                          return const Divider();
                        })),
          ],
        ),
      ),
    );
  }
}
