import 'package:vote_app/state/app_state.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



Future<void> saveAll() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('answerCount', answerCount);

  final allJson = allQuestions.map((q) => jsonEncode(q.toJson())).toList();
  final myJson  = myQuestions.map((q) => jsonEncode(q.toJson())).toList();

  await prefs.setStringList('allQuestions', allJson);
  await prefs.setStringList('myQuestions',  myJson);
}
