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

    print('Got tutors');
  }

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  // General Widgets
  _infoLabel() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0),
      child: Text('Automatically filtering by tutors who teach your grade',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
          )),
    );
  }

  Future<Map<String, dynamic>> tutorData(Tutor tutor) async {
    print('Calling tutordata function');
    var data = {
      'languages': await tutor.decodedLanguagesList,
      'city': await tutor.decodedCity,
      'subjects': await tutor.decodedSubjectsList,
      'grades': await tutor.decodedGradesList,
      'boards': await tutor.decodedBoardsList
    };
    print('Data: $data');
    return data;
  }

  // List view widgets
  _buildRow(int index) {
    var tutor = _tutors[index];

    return Row(children: <Widget>[
      Expanded(
        child: FutureBuilder(
          future: tutorData(tutor),
          initialData: 'Loading tutor data...',
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new Text('Data is loading...');
            } else {
              print(snapshot.data);
              Map data = snapshot.data as Map;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${tutor.name}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('${data['city']}', textAlign: TextAlign.left),
                  const SizedBox(height: 5),
                  Text('Speaks ${data['languages']}',
                      textAlign: TextAlign.left),
                  Text('Teaches ${data['subjects']}',
                      textAlign: TextAlign.left),
                ],
              );
            }
          },
        ),
      ),
      const SizedBox(width: 15.0),
      IconButton(
          onPressed: () => {
                tutorship_api_utils.createTutorship(_tutors[index],
                    widget.student, ['MATH', 'ENGLISH']) //TODO: Read subjects
              },
          icon: const Icon(Icons.person_add, color: Colors.indigo)),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _infoLabel(),
            _tutors.isEmpty
                ? const Text('No tutors available')
                : Expanded(
                    child: ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _tutors.length,
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
