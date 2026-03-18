import 'package:flutter/material.dart';
import 'models/drawing.dart';
import 'services/mock_data.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: MockData.drawings.length,
        itemBuilder: (context, index) {
          final drawing = MockData.drawings[index];
          return DrawingCard(drawing: drawing);
        },
      ),
    );
  }
}

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
                    color: _getEffortColor(drawing.effort),
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
            _buildDetailRow('Colors:', drawing.colors.join(', ')),
            _buildDetailRow('Mediums:', drawing.mediums.join(', ')),
            _buildDetailRow('Size:', drawing.size),
            _buildDetailRow('Time Spent:', _formatDuration(drawing.timeSpent)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEffortColor(String effort) {
    switch (effort.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.greenAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _formatDuration(Duration duration) {
    String hours = duration.inHours > 0 ? '${duration.inHours}h ' : '';
    String minutes = '${duration.inMinutes.remainder(60)}m';
    return hours + minutes;
  }
}
