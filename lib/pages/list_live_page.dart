import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListLivePage extends StatefulWidget {
  const ListLivePage({Key? key}) : super(key: key);

  @override
  _ListLiveState createState() => _ListLiveState();
}

class _ListLiveState extends State<ListLivePage> {
  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  int _page = 0;
  int _limit = 20;

  bool _hasNextPage = true;

  bool _isFirstLoadRunning = false;

  bool _isLoadMoreRunning = false;

  List _posts = [];

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      final res =
          await http.get(Uri.parse('$_baseUrl?_page=$_page&_limit=$_limit'));
      setState(() {
        _posts = json.decode(res.body);
      });
    } catch (err) {
      print(err);
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page += 1;
      try {
        final res =
            await http.get(Uri.parse('$_baseUrl?_page=$_page&_limit=$_limit'));
        final List fetchedPosts = json.decode(res.body);
        if (fetchedPosts.length > 0) {
          setState(() {
            _posts.addAll(fetchedPosts);
          });
        } else {
          _hasNextPage = false;
        }
      } catch (err) {
        print(err);
      }
      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _firstLoad();
    _controller = new ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  late ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Live'),
      ),
      body: _isFirstLoadRunning
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: _posts.length,
                    itemBuilder: (_, index) => Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(_posts[index]['title']),
                        subtitle: Text(_posts[index]['body']),
                      ),
                    ),
                  ),
                ),
                if (_isLoadMoreRunning == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // When nothing else to load
                if (_hasNextPage == false)
                  Container(
                    padding: EdgeInsets.only(top: 40, bottom: 40),
                    color: Colors.amber,
                    child: Center(
                      child: Text('No more posts to load'),
                    ),
                  ),
              ],
            ),
    );
  }
}
