import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  Timestamp releaseDate;
  String description;
  Timestamp dateCreated;
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
        releaseDate: Timestamp(json['release_date']['_seconds'],
            json['release_date']['_nanoseconds']),
        description: json['description'],
        dateCreated: Timestamp(json['date_created']['_seconds'],
            json['date_created']['_nanoseconds']),
        name: json['name'],
        imageUrl: json['cover']['imageUrl'],
        gameId: json['gameId']);
  }
}
