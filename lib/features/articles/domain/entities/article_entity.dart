import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final String imageUrl;
  final List<String> tags;
  final int views;
  final int likes;
  final int dislikes;
  final int userId;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.tags,
    required this.views,
    required this.likes,
    required this.dislikes,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    imageUrl,
    tags,
    views,
    likes,
    dislikes,
    userId,
  ];
}