import 'package:flutter/material.dart';
import 'package:vote_app/pages/submit_question_page.dart';
import 'package:vote_app/pages/my_questions_page.dart';
import 'package:vote_app/pages/earn_ticket_page.dart';

class MainTabPage extends StatelessWidget {
  const MainTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('결정장애 투표앱', style: TextStyle(fontSize: 40)),
          bottom: const TabBar(
            tabs: [
              Tab(text: '질문하기'),
              Tab(text: '내 질문'),
              Tab(text: '질문권 얻기'),
            ],
            labelStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            QuestionSubmitPage(),
            MyQuestionsPage(),
            RandomAnswerPage(),
          ],
        ),
      ),
    );
  }
}
