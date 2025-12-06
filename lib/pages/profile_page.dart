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

      // 1. 사용자 정보 가져오기
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        username = user.email?.split('@')[0] ?? 'Unknown User';
        ticket = 5;
        answeredCount = 0;
      } else {
        final data = doc.data();
        username = data?['username'] ?? 'Unknown User';
        ticket = data?['ticket'] ?? 5;
        answeredCount = data?['answeredCount'] ?? 0;
      }

      // 2. 인덱스 없이 간단히 조회
      final qSnap = await FirebaseFirestore.instance
          .collection('questions')
          .where('author', isEqualTo: user.uid)
          .get();

      myQuestions = qSnap.docs.map((d) {
        final q = d.data();
        return {
          'id': d.id,
          'question': q['question'] ?? 'No question',
          'options': List<String>.from(q['options'] ?? []),
          'votes': List<dynamic>.from(q['votes'] ?? []),
          'createdAt': q['createdAt'],
        };
      }).toList();

      // Dart에서 정렬
      myQuestions.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      _error = '정보 불러오기 실패: $e';
      print('Profile Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      print('Logout Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text("내 정보"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('아이디 (닉네임): ${username ?? "정보 없음"}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text('이메일: ${email ?? "정보 없음"}', style: const TextStyle(fontSize: 16)),
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
                            (q['options'] as List<String>);
                        final votes =
                            (q['votes'] as List<dynamic>).map((v) => (v as num).toInt()).toList();
                        
                        // 최다 득표 답변 찾기
                        int maxVotes = votes.isEmpty ? 0 : votes.reduce((a, b) => a > b ? a : b);
                        int maxIndex = votes.indexOf(maxVotes);
                        String topAnswer = maxVotes > 0 ? opts[maxIndex] : '투표 없음';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  q['question'] as String,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(opts.length, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        '${opts[index]}: ${votes[index]}표',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '최다 득표: $topAnswer ($maxVotes표)',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('로그아웃', style: TextStyle(fontSize: 36)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /users/{uid} {
//       allow read, write: if request.auth.uid == uid;
//     }
//     match /questions/{document=**} {
//       allow read: if request.auth != null;
//       allow create: if request.auth != null;
//       allow write: if request.auth.uid == resource.data.author;
//     }
//   }
// }
