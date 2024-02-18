import 'package:dio/dio.dart';
import 'package:example/debug_page.dart';
import 'package:example/logman_dio_interceptor.dart';
import 'package:example/second_page.dart';
import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio dio = Dio()..interceptors.add(LogmanDioInterceptor());
  List<PostModel> posts = [];
  final logman = Logman.instance;

  Future<void> mockNetworkCallFailure() async {
    try {
      await dio.get(
          'https://jobs.github.com/positions.json?description=api&location=new+york');
    } catch (e) {
      logman.recordErrorLog(e.toString());
    }
    await dio.get(
      'https://jsonplaceholder.typicode.com/posts/1',
    );
  }

  Future<void> getItems() async {
    final response = await dio.get(
      'https://jsonplaceholder.typicode.com/posts',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer 1234567890'
        },
      ),
    );
    final items = response.data as List<dynamic>;
    posts = items.map((element) => PostModel.fromJson(element)).toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getItems();
    mockNetworkCallFailure();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logman.attachOverlay(
        context: context,
        debugPage: const DebugPage(),
        button: FloatingActionButton.small(
          key: const Key('logman-button'),
          onPressed: () {},
          child: const Icon(Icons.bug_report),
        ),
        printLogs: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(post.body),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SecondPage(),
                        settings: const RouteSettings(name: '/second-page'),
                      ),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
    );
  }
}

class PostModel {
  final int id;
  final String title;
  final String body;
  final int userId;

  PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
    );
  }
}
