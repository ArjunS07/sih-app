import 'package:flutter/material.dart';

import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:search_choices/search_choices.dart';

import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/models/student.dart';

import 'package:sih_app/utils/choices.dart';
import 'package:sih_app/models/choice.dart';

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

  late List<Choice> _languageChoices = [];
  late List<String> _selectedLanguagesIds = [];
  late List<Choice> _subjectChoices = [];
  late List<String> _selectedSubjectIds = [];
  late List<String> _selectedSubjectDisplays = [];

  //API interfacing
  Future<void> _loadTutors() async {
    print("loading tutors from params");
    print('Student grade: ${widget.student.grade}');
    final loadedTutors = await tutor_api_utils.loadTutorsFromParams(
        widget.student.uuid,
        boards: [widget.student.board],
        grades: [widget.student.grade],
        languages: _selectedLanguagesIds,
        subjects: _selectedSubjectIds);
    setState(() {
      _tutors = loadedTutors;
    });

    print('Got tutors');
  }

  void _getChoices() async {
    _languageChoices = await loadChoices('languages');
    _subjectChoices = await loadChoices('subjects');

    setState(() {
      _languageChoices = _languageChoices;
      _subjectChoices = _subjectChoices;
    });
  }

  Future<Map<String, dynamic>> tutorData(Tutor tutor) async {
    print('Calling tutordata function');
    var data = {
      'languages': await tutor.decodedLanguagesDisplay,
      'city': await tutor.decodedCity,
      'subjects': await tutor.decodedSubjects,
      'grades': await tutor.decodedGrades,
      'boards': await tutor.decodedBoards
    };
    print('Data: $data');
    return data;
  }

  Future<void> confirmRequestToTutor(Tutor tutor, Student student) async {

    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Send request to ${tutor.name}?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ask ${tutor.name} to help you with ${_selectedSubjectDisplays.join(', ')}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green)),
                onPressed: () {
                  if (_selectedSubjectIds.isNotEmpty) {
                    tutorship_api_utils
                        .createTutorship(
                            tutor, widget.student, _selectedSubjectIds)
                        .then((value) {
                      Navigator.of(context).pop();
                      _showTutorRequestSnackBar(tutor.name);
                      _loadTutors(); // reload tutors list which will exclude tutors you already have a tutorship with
                    });
                  } else {

                  }
                },
                child: const Text(
                  'Yes',
                )),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTutors();
    _getChoices();
  }

  // search widgets

  _languageSelectionField() {
    return MultiSelectDialogField(
        title: const Text('Filter tutors by languages'),
        buttonText: const Text('What language do you speak?',
            style: TextStyle(color: Colors.grey)),
        buttonIcon: const Icon(Icons.language),
        separateSelectedItems: true,
        items: _languageChoices
            .map((language) => MultiSelectItem(language.id, language.name))
            .toList(),
        listType: MultiSelectListType.CHIP,
        onConfirm: (values) {
          _selectedLanguagesIds = [];
          for (var value in values) {
            print(value);
            _selectedLanguagesIds.add(value.toString());
          }
          _loadTutors();
        });
  }

  _subjectSelectionField() {
    return MultiSelectDialogField(
        buttonText: const Text('What do you want to learn?',
            style: TextStyle(color: Colors.grey)),
        title: const Text('Filter tutors by subjects'),
        buttonIcon: Icon(Icons.class_),
        separateSelectedItems: true,
        items: _subjectChoices
            .map((subject) => MultiSelectItem(subject.id, subject.name))
            .toList(),
        listType: MultiSelectListType.CHIP,
        onConfirm: (values) async {
          _selectedSubjectIds = [];
          for (var value in values) {
            print(value);
            _selectedSubjectIds.add(value.toString());
            var decoded = await decodeChoice(value.toString(), 'subjects');
            _selectedSubjectDisplays.add(decoded!);
          }
          _loadTutors();
        });
  }

  // General Widgets
  _generalFilterInfoLabel() {
    return Text(
        'Automatically filtering by tutors who teach your grade and board',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.grey.shade600,
        ));
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
              return const Text('Data is loading...');
            } else {
              print(snapshot.data);
              Map data = snapshot.data as Map;
              return Card(
                  child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ListTile(
                  title: Text('${tutor.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 21.0)),
                  isThreeLine: true,
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                        'City: ${data['city']}\nSpeaks ${data['languages']}\n\nSubjects: ${data['subjects']}',
                        style: const TextStyle(fontSize: 16.0)),
                  ),

                  // leading: const CircleAvatar(
                  //   //TODO
                  //     backgroundImage: NetworkImage(
                  //         "https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
                  trailing: IconButton(
                    
                      onPressed: _selectedSubjectIds.isEmpty || _selectedLanguagesIds.isEmpty ? null: () => {
                            confirmRequestToTutor(
                                _tutors[index], widget.student)
                          },
                      icon: const Icon(Icons.person_add, color: Colors.indigo)),
                ),
              ));
            }
          },
        ),
      ),
    ]);
  }

  void _showTutorRequestSnackBar(String tutorName) {
    String message = 'Sent request to $tutorName';
    var snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search for tutors'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Filter tutors',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10.0),
            _languageSelectionField(),
            const SizedBox(height: 5.0),
            _subjectSelectionField(),
            const SizedBox(height: 20),
            _generalFilterInfoLabel(),
            const SizedBox(height: 35.0),
            const Text('Matching tutors',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            _tutors.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                          'No matching tutors found. Try reducing the number of search requirements you set.'),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                    itemCount: _tutors.length,
                    itemBuilder: (BuildContext context, int position) {
                      return _buildRow(position);
                    },
                  )),
          ],
        ),
      ),
    );
  }
}
