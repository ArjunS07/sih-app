import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/models/student.dart';

import 'package:sih_app/utils/tutor_api_utils.dart' as tutor_api_utils;
import 'package:sih_app/utils/tutorship_api_utils.dart' as tutorship_api_utils;

class TutorSearch extends StatefulWidget {
  Student student;
  TutorSearch({Key? key, required this.student}) : super(key: key);

  @override
  State<TutorSearch> createState() => _TutorSearchState();
}

class _TutorSearchState extends State<TutorSearch> {
  var _tutors = <dynamic>[];

  //API interfacing
  Future<void> _loadTutors() async {
    print("loading tutors from params");
    final loadedTutors = await tutor_api_utils.loadTutorsFromParams();
    setState(() {
      _tutors = loadedTutors;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  // General Widgets
  _infoLabel() {
    return Text('Automatically filtering by tutors who teach your grade',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
        ));
  }

  // List view widgets
  Widget _buildRow(int index) {
    var tutor = _tutors[index];
    return Row(children: <Widget>[
      Column(
        children: <Widget>[
          Text('${tutor.name}}',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
          Text('Speaks ${tutor.languages.join(',')}'),
          Text('Subjects: ${tutor.subjects.join(',')}'),
          Text('Lives in ${tutor.city}')
        ],
      ),
      ElevatedButton(
          onPressed: () => {
                tutorship_api_utils.createTutorship(
                    _tutors[index], widget.student)
              },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.indigo.shade600)),
          child: const Text('Send request'))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for tutors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _infoLabel(),
            _tutors.isEmpty
                ? const Text('No tutors available')
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _tutors.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _buildRow(position);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    })
          ],
        ),
      ),
    );
  }
}
