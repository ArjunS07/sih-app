import 'package:flutter/material.dart';

import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:search_choices/search_choices.dart';

import 'package:sih_app/utils/auth_api_utils.dart';
import 'package:sih_app/utils/choices.dart';
import 'package:sih_app/models/choice.dart';

class TutorDetails extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  TutorDetails(
      {Key? key,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.password})
      : super(key: key);

  @override
  State<TutorDetails> createState() => _TutorDetailsState();
}

class _TutorDetailsState extends State<TutorDetails> {
  late List<Choice> _languageChoices = [];
  late List<String> _selectedLanguagesIds = [];

  late List<Choice> _boardChoices = [];
  late List<String> _selectedBoardIds = [];

  late List<Choice> _cityChoices = [];
  late String? _selectedCityId = null;

  late List<Choice> _gradeChoices = [];
  late List<String> _selectedGradeIds = [];

  late List<Choice> _subjectChoices = [];
  late List<String> _selectedSubjectIds = [];

  void getChoices() async {
    _languageChoices = await loadChoices('languages');
    _boardChoices = await loadChoices('boards');
    _cityChoices = await loadChoices('cities');
    _gradeChoices = await loadChoices('grades');
    _subjectChoices = await loadChoices('subjects');

    setState(() {
      _languageChoices = _languageChoices;
      _boardChoices = _boardChoices;
      _cityChoices = _cityChoices;
      _gradeChoices = _gradeChoices;
      _subjectChoices = _subjectChoices;
    });
    // _languageChoices = await getChoicesMap('languages').values.toList();
    // _cityChoices = await getChoicesMap('cities');
    // _gradeChoices = await getChoicesMap('grades');
  }

  @override
  void initState() {
    getChoices();
    super.initState();
  }

  void _submitRegistration(context) async {
    var account = await registerNewAccount(
            widget.email, widget.password, widget.firstName, widget.lastName)
        .catchError((error) {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Error'),
                content: Text('$error'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
      print('Error creating account');
    });
    if (account != null) {
      print('Creating tutor account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('What languages do you speak?'),
                  MultiSelectDialogField(
                      items: _languageChoices
                          .map((language) =>
                              MultiSelectItem(language.id, language.name))
                          .toList(),
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        for (var value in values) {
                          _selectedLanguagesIds.add(value.toString());
                        }
                      }),
                  const SizedBox(height: 32.0),
                  const Text('What city do you live in?'),
                  SearchChoices.single(
                    items: _cityChoices
                        .map((city) => DropdownMenuItem(
                            value: city.id, child: Text(city.name)))
                        .toList(),
                    value: _selectedCityId,
                    hint: "Select one",
                    searchHint: "Select one",
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                      });
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 32.0),
                  const Text('What boards can you teach?'),
                  MultiSelectDialogField(
                      items: _boardChoices
                          .map((board) => MultiSelectItem(board.id, board.name))
                          .toList(),
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        for (var value in values) {
                          _selectedBoardIds.add(value.toString());
                        }
                      }),
                  const SizedBox(height: 32.0),
                  const Text('What grades can you teach?'),
                  MultiSelectDialogField(
                      items: _gradeChoices
                          .map((grade) => MultiSelectItem(grade.id, grade.name))
                          .toList(),
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        for (var value in values) {
                          _selectedGradeIds.add(value.toString());
                        }
                      }),
                  const SizedBox(height: 32.0),
                  const Text('What subjects can you teach?'),
                  MultiSelectDialogField(
                      items: _subjectChoices
                          .map((subject) => MultiSelectItem(subject.id,subject.name))
                          .toList(),
                      listType: MultiSelectListType.CHIP,
                      onConfirm: (values) {
                        for (var value in values) {
                          _selectedGradeIds.add(value.toString());
                        }
                      }),
                  SizedBox(height: 25.0),
                  ElevatedButton(
                      onPressed: () => {_submitRegistration(context)},
                      child: Text('Complete registration')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
