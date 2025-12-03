import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:vote_app/state/app_state.dart';
import 'package:vote_app/utils/storage.dart';

class QuestionSubmitPage extends StatefulWidget {
  const QuestionSubmitPage({super.key});
  @override
  State<QuestionSubmitPage> createState() => _QuestionSubmitPageState();
}

class _QuestionSubmitPageState extends State<QuestionSubmitPage> {
  final TextEditingController _qCtrl = TextEditingController();
  final List<TextEditingController> _optCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addOption() {
    if (_optCtrls.length < 4) {
      setState(() {
        _optCtrls.add(TextEditingController());
      });
    }
  }

  Future<void> _submit() async {
    if (answerCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 질문권 얻기 탭에서 답변하세요!', style: TextStyle(fontSize: 36)),
        ),
      );
      return;
    }

    final qText = _qCtrl.text.trim();
    final opts = _optCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (qText.isEmpty || opts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('질문과 보기 2개 이상 입력하세요', style: TextStyle(fontSize: 36)),
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('questions').add({
      'author': uid,
      'question': qText,
      'options': opts,
      'votes': List.filled(opts.length, 0),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      answerCount--;
    });
    await saveAll();

    _qCtrl.clear();
    for (var c in _optCtrls) {
      c.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('등록! 남은 질문권: $answerCount',
            style: const TextStyle(fontSize: 36)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text('남은 질문권: $answerCount',
              style:
                  const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _qCtrl,
            decoration: const InputDecoration(labelText: '질문 입력'),
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 24),
          ..._optCtrls.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: e.value,
                decoration: InputDecoration(labelText: '보기 ${e.key + 1}'),
                style: const TextStyle(fontSize: 36),
              ),
            );
          }),
          if (_optCtrls.length < 4)
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 36),
              label: const Text('보기 추가', style: TextStyle(fontSize: 36)),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('등록', style: TextStyle(fontSize: 36)),
            ),
          ),
        ],
      ),
    );
  }
}
