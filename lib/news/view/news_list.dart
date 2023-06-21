import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/news/news.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:authentication_repository/src/models/user.dart';

Box<String> savedNews = Hive.box('savedNews');

class NewsList extends StatefulWidget {
  const NewsList({super.key, required this.user});
  final User user;

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        switch (state.status) {
          case NewsStatus.failure:
            return Column(
              children: [
                ElevatedButton(
                  child: Text("saved"),
                  onPressed: () {
                    context
                        .read<NewsBloc>()
                        .add(SavedNewsFetched(widget.user.id));
                  },
                ),
                Center(child: Text('failed to fetch Newss')),
              ],
            );
          case NewsStatus.success:
            if (state.news.isEmpty) {
              return Column(
                children: [
                  ElevatedButton(
                    child: Text("saved"),
                    onPressed: () {
                      context
                          .read<NewsBloc>()
                          .add(SavedNewsFetched(widget.user.id));
                    },
                  ),
                  Center(child: Text('no news')),
                ],
              );
            }
            return Column(
              children: [
                ElevatedButton(
                  child: Text("saved"),
                  onPressed: () {
                    context
                        .read<NewsBloc>()
                        .add(SavedNewsFetched(widget.user.id));
                  },
                ),
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return index >= state.news.length
                        ? const BottomLoader()
                        : NewsListItem(
                            news: state.news[index], user: widget.user);
                  },
                  itemCount: state.hasReachedMax
                      ? state.news.length
                      : state.news.length + 1,
                  controller: _scrollController,
                )),
              ],
            );

          case NewsStatus.initial:
            return const Center(child: CircularProgressIndicator());
          case NewsStatus.saved:
            return Column(
              children: [
                AppBar(
                  title: Text("saved news"),
                ),
                Center(
                  child: ElevatedButton(
                    child: Text("Go back"),
                    onPressed: () {
                      
                      context.read<NewsBloc>().add(NewsFetched());
                     
                
                    },
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return NewsListItem(
                        news: state.news[index], user: widget.user);
                  },
                  itemCount: state.hasReachedMax
                      ? state.news.length
                      : state.news.length + 1,
                  controller: _scrollController,
                )),
              ],
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      if (context.read<NewsBloc>().state.status != NewsStatus.saved) {
       
        context.read<NewsBloc>().add(NewsFetched());
      }
    }
    ;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
