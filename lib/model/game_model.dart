class Game {
  final int? id;
  final int? userId;
  final String title;
  final String genre;
  final String platform;
  final String status; // Ada 3 status: Playing, Backlog, Completed
  final String coverUrl;

  Game({
    this.id,
    this.userId,
    required this.title,
    required this.genre,
    required this.platform,
    required this.status,
    required this.coverUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'genre': genre,
      'platform': platform,
      'status': status,
      'coverUrl': coverUrl,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      genre: map['genre'],
      platform: map['platform'],
      status: map['status'],
      coverUrl: map['coverUrl'],
    );
  }
}