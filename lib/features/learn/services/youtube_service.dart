import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  static const String _apiKey = 'AIzaSyBumnazBxXZpcNt2rYih1RJoqG9TaQYm2E';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // Search for educational videos
  Future<List<YouTubeVideo>> searchVideos({
    required String query,
    int maxResults = 20,
    String order = 'relevance',
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?part=snippet&type=video&q=$query&maxResults=$maxResults&order=$order&key=$_apiKey'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => YouTubeVideo.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching videos: $e');
      throw Exception('Failed to search videos: $e');
    }
  }

  // Get popular educational channels
  Future<List<YouTubeVideo>> getEducationalVideos() async {
    const educationalQueries = [
      'programming tutorial',
      'computer science',
      'web development',
      'data structures',
      'algorithms',
      'machine learning',
      'software engineering',
      'coding interview',
    ];

    try {
      final allVideos = <YouTubeVideo>[];
      
      for (final query in educationalQueries.take(3)) {
        final videos = await searchVideos(
          query: query,
          maxResults: 5,
          order: 'viewCount',
        );
        allVideos.addAll(videos);
      }

      // Remove duplicates and return top 20
      final uniqueVideos = <String, YouTubeVideo>{};
      for (final video in allVideos) {
        uniqueVideos[video.videoId] = video;
      }

      return uniqueVideos.values.take(20).toList();
    } catch (e) {
      print('Error getting educational videos: $e');
      return [];
    }
  }

  // Get video details including duration and statistics
  Future<YouTubeVideoDetails?> getVideoDetails(String videoId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/videos?part=contentDetails,statistics&id=$videoId&key=$_apiKey'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        if (items.isNotEmpty) {
          return YouTubeVideoDetails.fromJson(items.first);
        }
      }
      return null;
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }

  // Get trending educational videos
  Future<List<YouTubeVideo>> getTrendingEducationalVideos() async {
    try {
      final url = Uri.parse(
        '$_baseUrl/videos?part=snippet&chart=mostPopular&regionCode=US&videoCategoryId=27&maxResults=15&key=$_apiKey'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        
        return items.map((item) => YouTubeVideo.fromVideoJson(item)).toList();
      } else {
        return await getEducationalVideos(); // Fallback
      }
    } catch (e) {
      print('Error getting trending videos: $e');
      return await getEducationalVideos(); // Fallback
    }
  }
}

class YouTubeVideo {
  final String id;
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String url;
  final String channelTitle;
  final DateTime publishedAt;
  final String channelId;
  final Duration duration;

  YouTubeVideo({
    required this.id,
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.url,
    required this.channelTitle,
    required this.publishedAt,
    required this.channelId,
    required this.duration,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};
    final medium = thumbnails['medium'] ?? thumbnails['default'] ?? {};

    final videoId = json['id']['videoId'] ?? '';
    return YouTubeVideo(
      id: videoId,
      videoId: videoId,
      title: snippet['title'] ?? 'No Title',
      description: snippet['description'] ?? '',
      thumbnailUrl: medium['url'] ?? '',
      url: 'https://www.youtube.com/watch?v=$videoId',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
      publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
      channelId: snippet['channelId'] ?? '',
      duration: Duration.zero, // Default duration, can be fetched separately
    );
  }

  factory YouTubeVideo.fromVideoJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};
    final medium = thumbnails['medium'] ?? thumbnails['default'] ?? {};

    final videoId = json['id'] ?? '';
    return YouTubeVideo(
      id: videoId,
      videoId: videoId,
      title: snippet['title'] ?? 'No Title',
      description: snippet['description'] ?? '',
      thumbnailUrl: medium['url'] ?? '',
      url: 'https://www.youtube.com/watch?v=$videoId',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
      publishedAt: DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
      channelId: snippet['channelId'] ?? '',
      duration: Duration.zero,
    );
  }
}

class YouTubeVideoDetails {
  final String duration;
  final String viewCount;
  final String likeCount;

  YouTubeVideoDetails({
    required this.duration,
    required this.viewCount,
    required this.likeCount,
  });

  factory YouTubeVideoDetails.fromJson(Map<String, dynamic> json) {
    final contentDetails = json['contentDetails'] ?? {};
    final statistics = json['statistics'] ?? {};

    return YouTubeVideoDetails(
      duration: contentDetails['duration'] ?? '',
      viewCount: statistics['viewCount'] ?? '0',
      likeCount: statistics['likeCount'] ?? '0',
    );
  }

  String get formattedDuration {
    final duration = this.duration;
    if (duration.isEmpty) return '';
    
    // Parse ISO 8601 duration (PT4M13S -> 4:13)
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(duration);
    
    if (match != null) {
      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
      
      if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      }
    }
    
    return '';
  }

  String get formattedViewCount {
    final count = int.tryParse(viewCount) ?? 0;
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M views';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$count views';
    }
  }
}
