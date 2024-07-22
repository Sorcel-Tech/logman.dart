import 'package:dio/dio.dart';
import 'package:example/debug_page.dart';
import 'package:example/logman_dio_interceptor.dart';
import 'package:example/second_page.dart';
import 'package:flutter/material.dart';
import 'package:logman/logman.dart';
import 'package:path_provider/path_provider.dart';

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
      logman.error(e.toString());
    }
    await dio.get(
      'https://jsonplaceholder.typicode.com/posts/1',
    );
  }

  Future<void> mockFormDataRequest() async {
    try {
      var tempDir = await getTemporaryDirectory();
      String savePath = '${tempDir.path}/downloaded_file.txt';

      await dio.download(
        'https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png',
        savePath,
      );
      logman.info('File downloaded to $savePath');

      final formData = FormData.fromMap({
        'title': 'foo',
        'body': 'bar',
        'userId': 1,
        // Add file to the form data
        'profile_picture': await MultipartFile.fromFile(
          savePath,
          filename: 'FlutterLogo.png',
        ),
      });

      final response = await dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      posts.add(PostModel.fromJson(response.data));
    } catch (e) {
      logman.error(e.toString());
    }
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
    mockFormDataRequest();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logman.attachOverlay(
        context: context,
        debugPage: const DebugPage(),
        button: FloatingActionButton.small(
          key: const Key('logman-button'),
          onPressed: () {},
          child: const Icon(Icons.bug_report),
        ),
        printLogs: true,
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
          : RefreshIndicator(
              onRefresh: () async {
                await getItems();
                mockNetworkCallFailure();
                mockFormDataRequest();
              },
              child: ListView.separated(
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
