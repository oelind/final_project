import '../models/drawing.dart';

class WeeklySummary {
  final int drawingCount;
  final Duration averageTimeSpent;
  final int promptGeneratorsPressedCount;
  final String averageEffort;
  final double averageDrawingsPerDay;

  WeeklySummary({
    required this.drawingCount,
    required this.averageTimeSpent,
    required this.promptGeneratorsPressedCount,
    required this.averageEffort,
    required this.averageDrawingsPerDay,
  });

  @override
  String toString() {
    return 'Summary: $drawingCount drawings, Avg: ${averageTimeSpent.inMinutes}m, Prompts pressed: $promptGeneratorsPressedCount, Avg Effort: $averageEffort, Avg drawings/day: ${averageDrawingsPerDay.toStringAsFixed(1)}';
  }
}

WeeklySummary calculateWeeklySummary(List<Drawing> drawings, int promptPressCount) {
  if (drawings.isEmpty) {
    return WeeklySummary(
      drawingCount: 0,
      averageTimeSpent: Duration.zero,
      promptGeneratorsPressedCount: promptPressCount,
      averageEffort: 'None',
      averageDrawingsPerDay: 0.0,
    );
  }

  final totalTime = drawings.fold(Duration.zero, (prev, d) => prev + d.timeSpent);
  final avgTime = Duration(milliseconds: totalTime.inMilliseconds ~/ drawings.length);
  
  final effortValues = {'Low': 1, 'Medium': 2, 'High': 3};
  final effortStrings = {1: 'Low', 2: 'Medium', 3: 'High'};
  
  double totalEffort = 0;
  for (var d in drawings) {
    totalEffort += effortValues[d.effort] ?? 2;
  }
  
  int avgEffortVal = (totalEffort / drawings.length).round();
  if (avgEffortVal < 1) avgEffortVal = 1;
  if (avgEffortVal > 3) avgEffortVal = 3;
  
  final avgEffort = effortStrings[avgEffortVal] ?? 'Medium';
  
  final avgDrawingsPerDay = drawings.length / 7.0;

  return WeeklySummary(
    drawingCount: drawings.length,
    averageTimeSpent: avgTime,
    promptGeneratorsPressedCount: promptPressCount,
    averageEffort: avgEffort,
    averageDrawingsPerDay: avgDrawingsPerDay,
  );
}
