import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class News {
  final String title;
  final String description;
  final String imageUrl;

  News({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewsListScreen(),
    );
  }
}

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final String apiKey = '7ca172eebb914f1c91ff486d178a0d98';
  final String apiUrl = 'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=';

  Future<List<News>> fetchBusinessHeadlines() async {
    final response = await http.get(Uri.parse('$apiUrl$apiKey'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['articles'];
      List<News> news = data.map((item) {
        return News(
          title: item['title'] ?? 'No Title',
          description: item['description'] ?? 'No Description',
          imageUrl: item['urlToImage'] ?? '', // Assumindo que a API fornece URL da imagem
        );
      }).toList();

      return news;
    } else {
      throw Exception('Failed to load business headlines: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Business Headlines'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<News>>(
        future: fetchBusinessHeadlines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return NewsListView(news: snapshot.data!);
          }
        },
      ),
    );
  }
}

class NewsListView extends StatelessWidget {
  final List<News> news;

  NewsListView({required this.news});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.all(16.0),
          title: Text(
            news[index].title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          subtitle: Text(
            news[index].description,
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          leading: news[index].imageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(news[index].imageUrl),
                )
              : null,
        );
      },
    );
  }
}
