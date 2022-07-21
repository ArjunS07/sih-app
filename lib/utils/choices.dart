import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String> _mapBoardFromId(String boardId) async {
  final String res = await rootBundle.loadString('assets/choices/boards.json');
  final Map<String, String> data = await json.decode(res);
  final language = data[boardId];
  if (language == null) {
    return 'Unknown';
  }
  return language;
}


Future<String> _mapCityFromId(String cityId) async {
  final String res = await rootBundle.loadString('assets/choices/cities.json');
  final Map<String, String> data = await json.decode(res);
  final language = data[cityId];
  if (language == null) {
    return 'Unknown';
  }
  return language;
}



Future<String> _mapGradeFromId(String gradeId) async {
  final String res = await rootBundle.loadString('assets/choices/grades.json');
  final Map<String, String> data = await json.decode(res);
  final language = data[gradeId];
  if (language == null) {
    return 'Unknown';
  }
  return language;
}



Future<String> _mapLanguageFromId(String languageId) async {
  final String res = await rootBundle.loadString('assets/choices/languages.json');
  final Map<String, String> data = await json.decode(res);
  final language = data[languageId];
  if (language == null) {
    return 'Unknown';
  }
  return language;
}

Future<String> _mapSubjectFromId(String cityId) async {
  final String res = await rootBundle.loadString('assets/choices/subjects.json');
  final Map<String, String> data = await json.decode(res);
  final language = data[cityId];
  if (language == null) {
    return 'Unknown';
  }
  return language;
}