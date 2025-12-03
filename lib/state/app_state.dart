import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';

// 전역 상태 ------------------------------
List<Question> allQuestions = [];
List<Question> myQuestions  = [];
Set<Question> answered = {};   // ← _answered 대신 공개로 변경
int answerCount = 0;

