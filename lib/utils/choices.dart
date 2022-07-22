
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sih_app/models/choice.dart';

readJson(String fileName) async {
    final String response = await rootBundle.loadString(fileName);
    print('Loaded response $response');
    final data = await json.decode(response);
    print('Decoded data into $data');
    return data;
}

jsonToChoices(data) async {
    List<Choice> choices = [];
    for (var choice in data) {
        choices.add(Choice.fromJson(choice));
    }
    print('Converted json to choices $choices');
    return choices;
}

loadChoices(String choiceType) async {
  print('Loading choices for $choiceType');
    final data = await readJson('assets/choices/$choiceType.json');
    print('Read data $data');
    return jsonToChoices(data);
}