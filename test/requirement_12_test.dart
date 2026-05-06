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

      final summary = calculateWeeklySummary(drawings, 1);

      expect(summary.drawingCount, 3);
      expect(summary.averageTimeSpent.inMinutes, 60); // (30+60+90)/3 = 60
      expect(summary.promptGeneratorsPressedCount, 1);
    });

    test('calculateWeeklySummary should handle empty list', () {
      final summary = calculateWeeklySummary([], 0);

      expect(summary.drawingCount, 0);
      expect(summary.averageTimeSpent, Duration.zero);
      expect(summary.promptGeneratorsPressedCount, 0);
    });

    test('Regression Test: calculateWeeklySummary with mixed effort levels', () {
       final drawings = <Drawing>[
        Drawing(
          title: 'A',
          description: '',
          colors: [],
          mediums: [],
          size: '',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 10),
          effort: 'Very High',
        ),
        Drawing(
          title: 'B',
          description: '',
          colors: [],
          mediums: [],
          size: '',
          timestamp: DateTime.now(),
          timeSpent: const Duration(minutes: 20),
          effort: 'Non-existent', // Test unknown effort
        ),
      ];
      final summary = calculateWeeklySummary(drawings, 0);
      expect(summary.drawingCount, 2);
      expect(summary.averageTimeSpent.inMinutes, 15);
    });
  });
}
