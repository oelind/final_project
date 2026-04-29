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
  final bool wasPromptUsed;

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
    this.wasPromptUsed = false,
  });

  factory Drawing.fromMap(Map<dynamic, dynamic> data) {
    DateTime parsedTimestamp;
    final timestampData = data['timestamp'];
    if (timestampData is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timestampData);
    } else if (timestampData is String) {
      parsedTimestamp = DateTime.tryParse(timestampData) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    // Helper to safely parse lists
    List<String> parseList(dynamic listData) {
      if (listData is List) {
        return listData.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Helper to safely parse int/num
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) {
        if (val.isInfinite || val.isNaN) return 0;
        return val.toInt();
      }
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return Drawing(
      userId: data['userId']?.toString(),
      title: data['title']?.toString() ?? 'Untitled',
      description: data['description']?.toString() ?? '',
      colors: parseList(data['colors']),
      mediums: parseList(data['mediums']),
      size: data['size']?.toString() ?? '',
      effort: data['effort']?.toString() ?? 'Medium',
      timestamp: parsedTimestamp,
      timeSpent: Duration(minutes: parseInt(data['timeSpentMinutes'])),
      wasPromptUsed: data['wasPromptUsed'] == true,
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
      'wasPromptUsed': wasPromptUsed,
    };
  }
}
