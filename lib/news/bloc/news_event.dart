part of 'news_bloc.dart';

sealed class NewsEvent extends Equatable {
  @override
  List<Object> get props => [];
}

final class NewsFetched extends NewsEvent {}

final class SavedNewsFetched extends NewsEvent {
  SavedNewsFetched(this.id);
  String id;
}
