class HighScore {
  HighScore({this.name = 'NO HIGH SCORE', this.score = -1});

  final String name;
  final int score;

  HighScore.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        score = json['score'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
      };
}

class SongHighScores {
  SongHighScores({this.maxNumScores = 10}) : scores = [];

  final int maxNumScores;
  final List<HighScore> scores;

  SongHighScores.fromJson(Map<String, dynamic> json)
      : maxNumScores = json['maxNumScores'],
        scores = (json['scores'] as List<dynamic>)
            .map((e) => HighScore.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'maxNumScores': maxNumScores,
        'scores': scores,
      };

  void addScore(HighScore score) {
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));

    if (scores.length > maxNumScores) {
      scores.removeLast();
    }
  }
}
