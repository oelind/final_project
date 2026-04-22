import 'package:flutter_test/flutter_test.dart';
import 'package:final_project/models/drawing.dart';
import 'package:final_project/utils/summary_utils.dart';

void main() {
  group('Requirement 12: End of Week Summary', () {
    test('calculateWeeklySummary should correctly aggregate drawing data', () {
      final drawings = [
        Drawing(
          title: 'Drawing 1',
          description: 'Desc 1',
          colors: [],
          mediums: [],
          size: 'Small',
          effort: 'Low',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 30),
          wasPromptUsed: true,
        ),
        Drawing(
          title: 'Drawing 2',
          description: 'Desc 2',
          colors: [],
          mediums: [],
          size: 'Medium',
          effort: 'Medium',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 60),
          wasPromptUsed: false,
        ),
        Drawing(
          title: 'Drawing 3',
          description: 'Desc 3',
          colors: [],
          mediums: [],
          size: 'Large',
          effort: 'High',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 90),
          wasPromptUsed: true,
        ),
      ];

      final summary = calculateWeeklySummary(drawings, promptGeneratorPressed: true);

      expect(summary.drawingCount, 3);
      expect(summary.averageTimeSpent.inMinutes, 60); // (30+60+90)/3 = 60
      expect(summary.promptsUsedCount, 2);
      expect(summary.promptGeneratorUsed, true);
    });

    test('calculateWeeklySummary should handle empty list', () {
      final summary = calculateWeeklySummary([]);

      expect(summary.drawingCount, 0);
      expect(summary.averageTimeSpent, Duration.zero);
      expect(summary.promptsUsedCount, 0);
      expect(summary.promptGeneratorUsed, false);
    });
  });
}
