import 'package:flutter/material.dart';

import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/models/student.dart';
import 'package:sih_app/models/tutorship.dart';

import 'package:sih_app/utils/tutor_api_utils.dart';
import 'package:sih_app/utils/tutorship_api_utils.dart';

class MyTutorRequests extends StatefulWidget {
  Tutor loggedInTutor;
  MyTutorRequests({Key? key, required this.loggedInTutor}) : super(key: key);

  @override
  State<MyTutorRequests> createState() => _MyTutorRequestsState();
}

class _MyTutorRequestsState extends State<MyTutorRequests> {
  var _requests =
      <dynamic>[]; // array of tutorships each of which contain a student

  // api stuff
  Future<void> _loadRequests() async {
    final tutorshipRequests =
        await getMyTutorshipRequests(widget.loggedInTutor, 'PNDG');
    setState(() {
      _requests = tutorshipRequests;
    });
  }

  Future<Map<String, dynamic>> _decodeTutorshipData(Tutorship tutorship) async {
    var data = {
      'city': await tutorship.student.decodedCity,
      'languages': await tutorship.student.decodedLanguagesDisplay,
      'subjects': await tutorship.decodedSubjectsDisplay,
    };
    return data;
  }

  _acceptTutorshipRequest(Tutorship tutorship) async {
    var decodedData = await _decodeTutorshipData(tutorship);
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accept request?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Accept request from ${tutorship.student.name} to learn ${decodedData['languages']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  updateTutorshipStatus('ACPT', tutorship.id).then((tutorship) => {
                  Navigator.of(context).pop(),
                  _showAcceptedRequestSnackBar(tutorship),
                  _loadRequests()
                  });
                },
                child: const Text('Yes'),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)))
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadRequests();
  }

  // ui stuff

  Widget _buildRow(int index) {
    var request = _requests[index];
    return Row(children: <Widget>[
      Expanded(
        child: FutureBuilder(
          future: _decodeTutorshipData(request),
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
                  title: Text('${request.student.name}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 21.0)),
                  isThreeLine: true,
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                        'City: ${data['city']}\nSpeaks ${data['languages']}\n\nWants help with ${data['subjects']}',
                        style: const TextStyle(fontSize: 16.0)),
                  ),

                  // leading: const CircleAvatar(
                  //   //TODO
                  //     backgroundImage: NetworkImage(
                  //         "https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
                  trailing: IconButton(
                      onPressed: () => {_acceptTutorshipRequest(request)},
                      icon: const Icon(Icons.check, color: Colors.indigo)),
                ),
              ));
            }
          },
        ),
      ),
    ]);
  }

  void _showAcceptedRequestSnackBar(Tutorship tutorship) {
    String message = 'Accepted request from ${tutorship.student.name}';
    var snackBar = SnackBar(
      content: Text(message),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _requests.isEmpty
                ? const Center(
                    child: Text('No incoming requests from students'),
                  )
                : Expanded(
                    child: ListView.builder(
                    itemCount: _requests.length,
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
