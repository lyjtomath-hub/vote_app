class Question {
  String question;
  List<String> options;
  List<int> votes;

  Question(this.question, this.options)
      : votes = List.filled(options.length, 0);

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'votes': votes,
      };

  factory Question.fromJson(Map<String, dynamic> json) {
    final q = Question(
      json['question'] as String,
      List<String>.from(json['options'] as List),
    );
    q.votes.setAll(0, List<int>.from(json['votes'] as List));
    return q;
  }
}
