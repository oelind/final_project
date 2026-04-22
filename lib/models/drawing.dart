class Drawing {
  final String? userId;
  final String title;
  final String description;
  final List<String> colors;
  final List<String> mediums;
  final String size;
  final String effort;
  final DateTime timestamp;
  final Duration timeSpent;

  const Drawing({
    this.userId,
    required this.title,
    required this.description,
    required this.colors,
    required this.mediums,
    required this.size,
    required this.effort,
    required this.timestamp,
    required this.timeSpent,
  });

  factory Drawing.fromMap(Map<dynamic, dynamic> data) {
    DateTime parsedTimestamp;
    final timestampData = data['timestamp'];
    if (timestampData is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timestampData);
    } else if (timestampData is String) {
      parsedTimestamp = DateTime.parse(timestampData);
    } else {
      parsedTimestamp = DateTime.now();
    }

    return Drawing(
      userId: data['userId'],
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      colors: List<String>.from(data['colors'] ?? []),
      mediums: List<String>.from(data['mediums'] ?? []),
      size: data['size'] ?? '',
      effort: data['effort'] ?? 'Medium',
      timestamp: parsedTimestamp,
      timeSpent: Duration(minutes: data['timeSpentMinutes'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'colors': colors,
      'mediums': mediums,
      'size': size,
      'effort': effort,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'timeSpentMinutes': timeSpent.inMinutes,
    };
  }
}
