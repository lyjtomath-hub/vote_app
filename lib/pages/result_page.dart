import 'package:flutter/material.dart';
import '../models/question.dart';

class ResultPage extends StatelessWidget {
  final Question question;
  const ResultPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final total = question.votes.fold<int>(0, (s, v) => s + v);

    return Scaffold(
      appBar: AppBar(
        title: const Text('투표 결과', style: TextStyle(fontSize: 40)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Builder(builder: (context) {
                final count = question.options.length;

                Widget opt(int idx) {
                  final vote = question.votes[idx];
                  final ratio = total == 0 ? 0.0 : vote / total;
                  final opacity = 0.3 + 0.7 * ratio;
                  return Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(opacity),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${question.options[idx]}\n$vote 표\n(${(ratio * 100).toStringAsFixed(1)}%)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 36),
                    ),
                  );
                }

                if (count == 2) {
                  return Row(children: [Expanded(child: opt(0)), Expanded(child: opt(1))]);
                } else if (count == 3) {
                  return Column(children: [
                    Expanded(child: opt(0)),
                    Expanded(child: opt(1)),
                    Expanded(child: opt(2)),
                  ]);
                } else {
                  return GridView.count(
                    crossAxisCount: 2,
                    children: List.generate(count, (i) => opt(i)),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
