import 'package:flutter/material.dart';

import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutorship.dart';

import 'package:sih_app/utils/tutor_api_utils.dart';
import 'package:sih_app/utils/tutorship_api_utils.dart';

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
              title: isLoggedInStudent
                  ? Text(tutorship.tutor.name)
                  : Text(tutorship.student.name),
              subtitle: Text(data['subjects']),
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
            ? const Text('My tutors')
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
                    child: Center(
                      child: widget.loggedinStudent != null
                          ? const Text('No tutors')
                          : const Text('No students'),
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
