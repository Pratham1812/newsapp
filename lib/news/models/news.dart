import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'news.g.dart';

@HiveType(typeId: 0)
class News extends Equatable {
  News({required this.author, required this.title, required this.body});

  @HiveField(0)
  String author;

  @HiveField(1)
  String title;

  @HiveField(2)
  String body;

  @override
  List<Object> get props => [author, title, body];
}
