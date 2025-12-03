// lib/pages/main_tab_page.dart
import 'package:flutter/material.dart';
import 'package:vote_app/pages/submit_question_page.dart';
import 'package:vote_app/pages/my_questions_page.dart';
import 'package:vote_app/pages/earn_ticket_page.dart';
import 'package:vote_app/pages/profile_page.dart'; // ⬅️ 추가

class MainTabPage extends StatelessWidget {
  const MainTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ⬅️ 탭 수 변경
      child: Scaffold(
        appBar: AppBar(
          title: const Text('결정장애 투표앱', style: TextStyle(fontSize: 32)),
          bottom: const TabBar(
            tabs: [
              Tab(text: '질문하기'),
              Tab(text: '내 질문'),
              Tab(text: '질문권 얻기'),
              Tab(text: '내 정보'), // ⬅️ 새 탭 추가
            ],
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            QuestionSubmitPage(),
            MyQuestionsPage(),
            RandomAnswerPage(),
            ProfilePage(), // ⬅️ 내 정보 탭
          ],
        ),
      ),
    );
  }
}
