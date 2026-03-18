class Drawing {
  final String title;
  final String description;
  final List<String> colors;
  final List<String> mediums;
  final String size;
  final String effort;
  final DateTime timestamp;
  final Duration timeSpent;

  const Drawing({
    required this.title,
    required this.description,
    required this.colors,
    required this.mediums,
    required this.size,
    required this.effort,
    required this.timestamp,
    required this.timeSpent,
  });
}
