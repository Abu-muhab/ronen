import 'dart:math';

class Game {
  DateTime releaseDate;
  String description;
  DateTime dateCreated;
  String name;
  String imageUrl;
  String gameId;
  Game(
      {this.name,
      this.description,
      this.dateCreated,
      this.gameId,
      this.imageUrl,
      this.releaseDate});
  factory Game.fromJson(Map json) {
    return Game(
        releaseDate: DateTime.fromMillisecondsSinceEpoch((json['release_date']
                    ['_seconds'] +
                json['release_date']['_nanoseconds'] * pow(10, -9))
            .round()),
        description: json['description'],
        dateCreated: DateTime.fromMillisecondsSinceEpoch((json['date_created']
                    ['_seconds'] +
                json['date_created']['_nanoseconds'] * pow(10, -9))
            .round()),
        name: json['name'],
        imageUrl: json['cover']['imageUrl'],
        gameId: json['gameId']);
  }
}
