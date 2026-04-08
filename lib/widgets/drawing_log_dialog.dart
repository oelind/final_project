import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DrawingLogDialog extends StatefulWidget {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  const DrawingLogDialog({super.key, this.firestore, this.auth});

  @override
  State<DrawingLogDialog> createState() => _DrawingLogDialogState();
}

class _DrawingLogDialogState extends State<DrawingLogDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _effort = 'Medium';
  
  // Timer state
  bool _isTimerRunning = false;
  int _secondsElapsed = 0;
  Timer? _timer;

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
      if (_isTimerRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _secondsElapsed++;
            _timeController.text = (_secondsElapsed / 60.0).toStringAsFixed(1);
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveFirestore = widget.firestore ?? FirebaseFirestore.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) return;

    final timeInMinutes = (double.tryParse(_timeController.text) ?? 0.0) * 60;

    try {
      await effectiveFirestore.collection('drawings').add({
        'userId': user.uid,
        'title': _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        'description': _descriptionController.text,
        'timeSpentMinutes': timeInMinutes.toInt(),
        'effort': _effort,
        'timestamp': Timestamp.fromDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drawing logged successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging drawing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Your Drawing'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title (Optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time Spent (Hours)',
                  suffixIcon: IconButton(
                    icon: Icon(_isTimerRunning ? Icons.stop : Icons.play_arrow),
                    color: _isTimerRunning ? Colors.red : Colors.green,
                    onPressed: _toggleTimer,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              if (_isTimerRunning)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Timer active: ${(_secondsElapsed ~/ 60)}m ${(_secondsElapsed % 60)}s',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _effort,
                decoration: const InputDecoration(labelText: 'Effort Level'),
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _effort = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEntry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Finished'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
