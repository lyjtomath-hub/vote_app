import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyQuestionsPage extends StatefulWidget {
  const MyQuestionsPage({super.key});

  @override
  State<MyQuestionsPage> createState() => _MyQuestionsPageState();
}

class _MyQuestionsPageState extends State<MyQuestionsPage> {
  List<Map<String, dynamic>> myQuestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyQuestions();
  }

  Future<void> _loadMyQuestions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final qSnap = await FirebaseFirestore.instance
          .collection('questions')
          .where('author', isEqualTo: user.uid)
          .get();

      myQuestions = qSnap.docs.map((d) {
        final q = d.data();
        return {
          'id': d.id,
          'questions': q['questions'] ?? q['question'] ?? 'No question',
          'options': List<String>.from(q['options'] ?? []),
          'votes': List<int>.from((q['votes'] as List?)?.map((v) => (v as num).toInt()) ?? []),
          'createdAt': q['createdAt'] as Timestamp?,
        };
      }).toList();

      // Dart에서 정렬
      myQuestions.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });
    } catch (e) {
      print('My Questions Load Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showVoteDetails(Map<String, dynamic> question) {
    final options = question['options'] as List<String>;
    final votes = question['votes'] as List<int>;
    final totalVotes = votes.fold<int>(0, (sum, v) => sum + v);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question['questions'] as String),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final voteCount = votes[index];
              final percentage = totalVotes > 0 ? (voteCount / totalVotes * 100).toStringAsFixed(1) : '0.0';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$voteCount표 ($percentage%)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: totalVotes > 0 ? voteCount / totalVotes : 0,
                        minHeight: 20,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.primaries[index % Colors.primaries.length],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("내가 만든 질문")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("내가 만든 질문")),
      body: myQuestions.isEmpty
          ? const Center(child: Text("등록된 질문이 없습니다"))
          : ListView.builder(
              itemCount: myQuestions.length,
              itemBuilder: (context, index) {
                final q = myQuestions[index];
                final opts = (q['options'] as List<String>).join(", ");
                final votes = (q['votes'] as List<int>).fold<int>(0, (sum, v) => sum + v);

                return GestureDetector(
                  onTap: () => _showVoteDetails(q),
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['questions'] as String,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("보기: $opts",
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text("총 투표수: $votes표",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          const Text(
                            "탭하여 투표 결과 보기",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
