import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/news/news.dart';
import 'package:http/http.dart' as http;

import 'package:authentication_repository/src/models/user.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: BlocProvider(
          create: (_) =>
              NewsBloc(httpClient: http.Client())..add(NewsFetched()),
          child:  Column(
            children: [
              
             Expanded(child: NewsList(user: user)) ,
            ],
          )),
    );
  }
}
