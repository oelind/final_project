import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/drawing.dart';
import '../utils/summary_utils.dart';
import '../utils/color_utils.dart';

class WeeklySummaryDialog extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseDatabase? database;

  const WeeklySummaryDialog({super.key, this.auth, this.database});

  @override
  State<WeeklySummaryDialog> createState() => _WeeklySummaryDialogState();
}

class _WeeklySummaryDialogState extends State<WeeklySummaryDialog> {
  bool _isLoading = true;
  WeeklySummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  Future<void> _loadSummaryData() async {
    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    try {
      // 1. Fetch Drawings
      final drawingsSnapshot = await effectiveDatabase.ref('users/${user.uid}/drawings').get();
      List<Drawing> recentDrawings = [];
      if (drawingsSnapshot.exists && drawingsSnapshot.value != null) {
        final data = drawingsSnapshot.value;
        Map<dynamic, dynamic> drawingsMap;
        if (data is Map) {
          drawingsMap = Map<dynamic, dynamic>.from(data);
        } else if (data is List) {
          drawingsMap = {};
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null) drawingsMap[i.toString()] = data[i];
          }
        } else {
          drawingsMap = {};
        }

        final allDrawings = drawingsMap.values.map((d) => Drawing.fromMap(Map<dynamic, dynamic>.from(d as Map))).toList();
        recentDrawings = allDrawings.where((d) => d.timestamp.millisecondsSinceEpoch >= oneWeekAgo).toList();
      }

      // 2. Fetch Prompt Presses
      final pressesSnapshot = await effectiveDatabase.ref('users/${user.uid}/prompt_presses').get();
      int pressCount = 0;
      if (pressesSnapshot.exists && pressesSnapshot.value != null) {
        final data = pressesSnapshot.value;
        Map<dynamic, dynamic> pressesMap;
        if (data is Map) {
          pressesMap = Map<dynamic, dynamic>.from(data);
        } else if (data is List) {
          pressesMap = {};
          for (int i = 0; i < data.length; i++) {
            if (data[i] != null) pressesMap[i.toString()] = data[i];
          }
        } else {
          pressesMap = {};
        }
        
        for (var val in pressesMap.values) {
          if (val is int && val >= oneWeekAgo) {
            pressCount++;
          } else if (val is Map && val['timestamp'] != null) {
             if (val['timestamp'] is int && val['timestamp'] >= oneWeekAgo) {
               pressCount++;
             }
          }
        }
      }

      final summary = calculateWeeklySummary(recentDrawings, pressCount);
      
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('Error loading weekly summary: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Weekly Summary', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
      content: _isLoading 
        ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
        : _summary == null 
          ? const Text('Could not load summary.')
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(Icons.draw, 'Drawings Completed:', '${_summary!.drawingCount}'),
                  const SizedBox(height: 10),
                  _buildStatRow(Icons.timer, 'Average Time Spent:', '${_summary!.averageTimeSpent.inMinutes} minutes'),
                  const SizedBox(height: 10),
                  _buildStatRow(Icons.touch_app, 'Prompt Generators Pressed:', '${_summary!.promptGeneratorsPressedCount} times'),
                  const SizedBox(height: 10),
                  _buildStatRow(Icons.fitness_center, 'Average Effort:', _summary!.averageEffort),
                  const SizedBox(height: 10),
                  _buildStatRow(Icons.calendar_today, 'Average Drawings/Day:', _summary!.averageDrawingsPerDay.toStringAsFixed(1)),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.darkTeal),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(value, style: const TextStyle(fontSize: 14, color: AppColors.deepPlum)),
            ],
          ),
        ),
      ],
    );
  }
}
