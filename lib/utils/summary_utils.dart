import '../models/drawing.dart';

class WeeklySummary {
  final int drawingCount;
  final Duration averageTimeSpent;
  final int promptsUsedCount;
  final bool promptGeneratorUsed;

  WeeklySummary({
    required this.drawingCount,
    required this.averageTimeSpent,
    required this.promptsUsedCount,
    required this.promptGeneratorUsed,
  });

  @override
  String toString() {
    return 'Summary: $drawingCount drawings, Avg: ${averageTimeSpent.inMinutes}m, Prompts: $promptsUsedCount, Generator pressed: $promptGeneratorUsed';
  }
}

WeeklySummary calculateWeeklySummary(List<Drawing> drawings, {bool promptGeneratorPressed = false}) {
  if (drawings.isEmpty) {
    return WeeklySummary(
      drawingCount: 0,
      averageTimeSpent: Duration.zero,
      promptsUsedCount: 0,
      promptGeneratorUsed: promptGeneratorPressed,
    );
  }

  final totalTime = drawings.fold(Duration.zero, (prev, d) => prev + d.timeSpent);
  final avgTime = Duration(milliseconds: totalTime.inMilliseconds ~/ drawings.length);
  final promptsUsed = drawings.where((d) => d.wasPromptUsed).length;

  return WeeklySummary(
    drawingCount: drawings.length,
    averageTimeSpent: avgTime,
    promptsUsedCount: promptsUsed,
    promptGeneratorUsed: promptGeneratorPressed,
  );
}
