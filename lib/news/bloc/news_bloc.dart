import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

// import 'package:flutter_infinite_list/bloc/bloc.dart';
// import 'package:flutter_infinite_list/news.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_firebase_login/news/news.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:http/http.dart';
part 'news_event.dart';
part 'news_state.dart';

const _newsLimit = 20;
const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc({required this.httpClient}) : super(const NewsState()) {
    on<NewsFetched>(
      _onNewsFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }
  final http.Client httpClient;

  Future<void> _onNewsFetched(
      NewsFetched event, Emitter<NewsState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == NewsStatus.initial) {
        final News = await _fetchNews();
        return emit(state.copyWith(
          status: NewsStatus.success,
          news: News,
          hasReachedMax: false,
        ));
      }
      final News = await _fetchNews(state.news.length);
      emit(News.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: NewsStatus.success,
              news: List.of(state.news)..addAll(News),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: NewsStatus.failure));
    }
  }

  Future<List<News>> _fetchNews(
      [int startIndex = 0,
      String key = '35876774ff514a83bd13505b9dd0a9b9',
      String country = 'in']) async {
    final res = await httpClient.get(Uri.https(
      'https://newsapi.org/v2',
      '/top-headlines',
      <String, String>{'country': '$country', 'apiKey': '$key'},
    ));

    if (res.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(res.body);

      List<dynamic> body = json['articles'];

      List<News> articles =
          body.map((dynamic item) => News.fromJson(item)).toList();

      return articles;
    } else {
      print("error hua sirji");
      throw ("Can't get the Articles");
    }
  }
}
