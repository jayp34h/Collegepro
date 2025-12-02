class ResearchPaper {
  final String id;
  final String title;
  final List<String> authors;
  final String summary;
  final List<String> categories;
  final DateTime publishedDate;
  final DateTime updatedDate;
  final String pdfUrl;
  final String abstractUrl;

  ResearchPaper({
    required this.id,
    required this.title,
    required this.authors,
    required this.summary,
    required this.categories,
    required this.publishedDate,
    required this.updatedDate,
    required this.pdfUrl,
    required this.abstractUrl,
  });

  String get formattedAuthors {
    if (authors.isEmpty) return 'Unknown';
    if (authors.length == 1) return authors.first;
    if (authors.length == 2) return '${authors[0]} and ${authors[1]}';
    return '${authors[0]} et al.';
  }

  String get primaryCategory {
    return categories.isNotEmpty ? categories.first : 'Unknown';
  }

  String get arxivId {
    // Extract arXiv ID from the full URL
    final uri = Uri.parse(id);
    return uri.pathSegments.last;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'summary': summary,
      'categories': categories,
      'publishedDate': publishedDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'pdfUrl': pdfUrl,
      'abstractUrl': abstractUrl,
    };
  }

  factory ResearchPaper.fromJson(Map<String, dynamic> json) {
    return ResearchPaper(
      id: json['id'],
      title: json['title'],
      authors: List<String>.from(json['authors']),
      summary: json['summary'],
      categories: List<String>.from(json['categories']),
      publishedDate: DateTime.parse(json['publishedDate']),
      updatedDate: DateTime.parse(json['updatedDate']),
      pdfUrl: json['pdfUrl'],
      abstractUrl: json['abstractUrl'],
    );
  }
}
