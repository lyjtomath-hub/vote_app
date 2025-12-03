import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vote_app/state/app_state.dart';
import 'package:vote_app/utils/storage.dart';
import '../models/question.dart';

class RandomAnswerPage extends StatefulWidget {
  const RandomAnswerPage({super.key});
  @override
  State<RandomAnswerPage> createState() => _RandomAnswerPageState();
}

class _RandomAnswerPageState extends State<RandomAnswerPage> {
  Question? _current;

  void _loadQuestion() {
    final pool = allQuestions
        .where((q) => !answered.contains(q) && !myQuestions.contains(q))
        .toList();
    if (pool.isEmpty) {
      setState(() => _current = null);
    } else {
      setState(() => _current = pool[Random().nextInt(pool.length)]);
    }
  }

  Future<void> _vote(int idx) async {
    if (_current == null) return;
    setState(() {
      _current!.votes[idx]++;
      answered.add(_current!);
      answerCount++;
    });

    await saveAll();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('투표 완료! 질문권 +1', style: TextStyle(fontSize: 36))),
    );

    _loadQuestion();
  }

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    if (q == null) {
      return const Center(child: Text('답변할 질문이 없습니다', style: TextStyle(fontSize: 36)));
    }
    final count = q.options.length;

    Widget layout;
    Widget btn(int i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () => _vote(i),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24)),
              child: Text(q.options[i], style: const TextStyle(fontSize: 36)),
            ),
          ),
        );

    if (count == 2) {
      layout = Row(children: [btn(0), btn(1)]);
    } else if (count == 3) {
      layout = Column(children: [btn(0), btn(1), btn(2)]);
    } else {
      layout = Column(children: [
        Row(children: [btn(0), btn(1)]),
        Row(children: [btn(2), btn(3)]),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            q.question,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(child: layout),
        ],
      ),
    );
  }
}
