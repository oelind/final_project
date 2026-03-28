import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/drawing.dart';
import '../utils/color_utils.dart';
import '../utils/duration_formatter.dart';
import 'drawing_detail_row.dart';

class DrawingCard extends StatelessWidget {
  final Drawing drawing;

  const DrawingCard({super.key, required this.drawing});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(drawing.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  drawing.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Effort: ${drawing.effort}',
                  style: TextStyle(
                    color: getEffortColor(drawing.effort),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              drawing.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Divider(height: 24),
            DrawingDetailRow(label: 'Colors:', value: drawing.colors.join(', ')),
            DrawingDetailRow(label: 'Mediums:', value: drawing.mediums.join(', ')),
            DrawingDetailRow(label: 'Size:', value: drawing.size),
            DrawingDetailRow(label: 'Time Spent:', value: formatDuration(drawing.timeSpent)),
            const Divider(height: 24),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Logged on: $formattedDate',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
