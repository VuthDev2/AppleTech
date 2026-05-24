class Review {
  Review({
    required this.id,
    required this.author,
    required this.rating,
    required this.title,
    required this.content,
    required this.date,
    required this.verified,
  });

  final String id;
  final String author;
  final int rating; // 1-5
  final String title;
  final String content;
  final DateTime date;
  final bool verified;
}
