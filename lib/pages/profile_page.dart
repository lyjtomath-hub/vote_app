// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  int ticket = 0;
  int answeredCount = 0;
  List<Map<String, dynamic>> myQuestions = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인된 사용자 없음');

      email = user.email;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) throw Exception('유저 정보 없음');

      final data = doc.data()!;
      username = data['username'];
      ticket = data['ticket'] ?? 0;
      answeredCount = data['answeredCount'] ?? 0;

      final qSnap = await FirebaseFirestore.instance
          .collection('questions')
          .where('author', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      myQuestions = qSnap.docs.map((d) {
        final q = d.data();
        return {
          'id': d.id,
          'question': q['question'],
          'options': List<String>.from(q['options']),
          'votes': List<dynamic>.from(q['votes']),
        };
      }).toList();
    } catch (e) {
      _error = '정보 불러오기 실패: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 여기 수정됨: Scaffold 앞의 const 삭제
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("내 정보")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("내 정보")),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("내 정보")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('아이디 (닉네임): $username', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text('이메일: ${email ?? ""}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('남은 질문권: $ticket', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text('답변한 질문 수: $answeredCount',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Divider(),
            const Text('내가 만든 질문들',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: myQuestions.isEmpty
                  ? const Text("등록된 질문이 없습니다.")
                  : ListView.builder(
                      itemCount: myQuestions.length,
                      itemBuilder: (context, i) {
                        final q = myQuestions[i];
                        final opts =
                            (q['options'] as List<String>).join(", ");
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              q['question'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("보기: $opts"),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
