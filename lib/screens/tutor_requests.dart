import 'package:flutter/material.dart';

import 'package:sih_app/models/tutor.dart';
import 'package:sih_app/utils/tutor_api_utils.dart';
import 'package:sih_app/utils/tutorship_api_utils.dart';

class MyTutorRequests extends StatefulWidget {
  Tutor loggedInTutor;
  MyTutorRequests({Key? key, required this.loggedInTutor}) : super(key: key);

  @override
  State<MyTutorRequests> createState() => _MyTutorRequestsState();
}

class _MyTutorRequestsState extends State<MyTutorRequests> {
  var _requests = <dynamic>[];

  // api stuff
  Future<void> _loadRequests() async {
    final tutorshipRequests =
        await getMyTutorshipRequests(widget.loggedInTutor);
    setState(() {
      _requests = tutorshipRequests;
    });
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
      Text(request.name,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
      Text(request.relativeTimeSinceCreated, style: const TextStyle(color: Colors.grey)),
      Text('Wants to learn')
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
