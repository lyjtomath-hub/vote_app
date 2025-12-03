import 'package:flutter/material.dart';
import 'result_page.dart';
import '../models/question.dart';
import 'package:vote_app/state/app_state.dart';

class MyQuestionsPage extends StatelessWidget {
  const MyQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (myQuestions.isEmpty) {
      return const Center(
        child: Text('등록된 질문이 없습니다', style: TextStyle(fontSize: 36)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: myQuestions.length,
      itemBuilder: (ctx, i) {
        final q = myQuestions[i];
        final maxVote = q.votes.reduce((a, b) => a > b ? a : b);
        final topIdx = q.votes.indexOf(maxVote);
        return ListTile(
          title: Text(
            q.question,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '✔️ ${q.options[topIdx]} ($maxVote 표)',
            style: const TextStyle(fontSize: 32),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResultPage(question: q),
              ),
            );
          },
        );
      },
    );
  }
}
