// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sih_app/models/choice.dart';

Future<String?> decodeChoice(String choiceCode, String choiceType) async {
  print('Decoding choice');
  final data = await readJson('assets/choices/$choiceType.json');
  for (var choiceData in data) {
    Choice choice = Choice.fromJson(choiceData);
    if (choice.id == choiceCode) {
      return choice.name;
    }
  }
  return null;
}

readJson(String fileName) async {
  final String response = await rootBundle.loadString(fileName);
  final data = await json.decode(response);
  return data;
}

jsonToChoices(data) async {
  List<Choice> choices = [];
  for (var choice in data) {
    choices.add(Choice.fromJson(choice));
  }
  return choices;
}

loadChoices(String choiceType) async {
  final data = await readJson('assets/choices/$choiceType.json');
  return jsonToChoices(data);
}
