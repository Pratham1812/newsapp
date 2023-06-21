import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_firebase_login/news/news.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    on<SavedNewsFetched>(_onSavedNewsFetch);
  }
  final http.Client httpClient;

  Future<void> _onNewsFetched(
      NewsFetched event, Emitter<NewsState> emit) async {
    if (state.hasReachedMax && state.status!=NewsStatus.saved) return;
    try {
      if (state.status == NewsStatus.initial || state.status==NewsStatus.saved) {
        final News = await _fetchNews();
        return emit(state.copyWith(
          status: NewsStatus.success,
          news: News,
          hasReachedMax: false,
        ));
      }
      
      
      else {
        final News = await _fetchNews();
        emit(News.isEmpty
            ? state.copyWith(hasReachedMax: true)
            : state.copyWith(
                status: NewsStatus.success,
                news: List.of(state.news)..addAll(News),
                hasReachedMax: false,
              ));
      }
    } catch (_) {
      emit(state.copyWith(status: NewsStatus.failure));
    }
  }

  Future<void> _onSavedNewsFetch(
      SavedNewsFetched event, Emitter<NewsState> emit) async {
    
    final Box box = await Hive.openBox(event.id);
    final List<News> savedNews = [];
  
      for (int i = 0; i < box.length; i++) {
        savedNews.add(box.getAt(i));
        
      }
      return emit(state.copyWith(
          status: NewsStatus.saved, news: savedNews, hasReachedMax: true));
    
  }

  Future<List<News>> _fetchNews() async {
    await dotenv.load(fileName: ".env");
    final response = await httpClient.get(
      Uri.https(
        'newsapi.org',
        '/v2/top-headlines',
        <String, String>{
          'country': 'in',
          'apiKey': dotenv.get('API_KEY')
        },
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      
    
      List<News> result = [];
      for (int i = 0; i < body['articles'].length; i++) {
        if (body['articles'][i]['author'] != null &&
            body['articles'][i]['title'] != null &&
            body['articles'][i]['description'] != null) {
          result.add(News(
            author: body['articles'][i]['author'] as String,
            title: body['articles'][i]['title'] as String,
            body: body['articles'][i]['description'] as String,
          ));
          
        }
      }
      return result;
    }
    throw Exception('error fetching posts');
  }
}
