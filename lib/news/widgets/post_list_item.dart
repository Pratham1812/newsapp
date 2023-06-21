import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../news.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:authentication_repository/src/models/user.dart';

class NewsListItem extends StatefulWidget {
  const NewsListItem({super.key, required this.news, required this.user});
  final User user;
  final News news;

  @override
  State<NewsListItem> createState() => _NewsListItemState();
}

class _NewsListItemState extends State<NewsListItem> {
  var enabled = true;
  String dyn_text = "Save";

  @override
  Widget build(BuildContext context) {
    if (context.read<NewsBloc>().state.status == NewsStatus.saved)
      enabled = false;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.news.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.news.author,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.news.body,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            ElevatedButton(
              child: Text(dyn_text),
              onPressed: enabled
                  ? () async {
                      if (context.read<NewsBloc>().state.status !=
                          NewsStatus.saved) {
                        print("mai aagya");

                        final Box savedNews =
                            await Hive.openBox(widget.user.id);

                        for (int i = 0; i < savedNews.length; i++) {
                          if (savedNews.getAt(i) == widget.news) {
                            setState(() {
                              if (enabled) {
                                dyn_text = "Already saved";

                                enabled = false;
                              }
                            });
                            break;
                          }
                        }
                        if (dyn_text != "Already saved") {
                          savedNews.add(widget.news);
                          await savedNews.close();
                          setState(() {
                            if (enabled) {
                              enabled = false;
                            }
                          });
                        }
                      }
                    }
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
