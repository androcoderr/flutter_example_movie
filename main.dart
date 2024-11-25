import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/model_movie.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  List<Movie> _movies = [];
  TextEditingController _movieController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInitialData(); // Yeni eklendi
  }

  // Yeni eklendi
  Future<void> _fetchInitialData() async {
    try {
      final movies = await _getMovies();
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      print('Error fetching initial movies: $e');
    }
  }

  Future<List<Movie>> _getMovies() async {
    final apiKey = '0971e824703fbd0eabf917b060127ef3';
    final response = await http.get(
        Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=${apiKey}&language=en-US&page=1')
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final movies = (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
      return movies;
    } else {
      throw Exception('Failed to fetch search results');
    }
  }

  Future<List<Movie>> fetchSearchResults(String searchTerm) async {
    final apiKey = '0971e824703fbd0eabf917b060127ef3';
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$searchTerm'));
    print("STATUS: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final movies = (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
      return movies;
    } else {
      throw Exception('Failed to fetch search results');
    }
  }

  void _searchMovies() async {
    if (_movieController.text.isEmpty) {
      await _fetchInitialData();
      return;
    }

    try {
      final movies = await fetchSearchResults(_movieController.text);
      setState(() {
        _movies = movies;
      });
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Movie Search'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _movieController, // Controller aktif edildi
                      decoration: const InputDecoration(
                        hintText: 'Search movies',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _searchMovies, // Search fonksiyonu aktif edildi
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _movies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return ListTile(
                    leading: movie.posterPath != null
                        ? Image.network(
                      'https://image.tmdb.org/t/p/w92/${movie.posterPath}',
                      fit: BoxFit.cover,
                    )
                        : const SizedBox(
                      width: 50,
                      height: 75,
                    ),
                    title: Text(movie.title),
                    subtitle: Text(movie.overview),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}