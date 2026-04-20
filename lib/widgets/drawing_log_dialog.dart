import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DrawingLogDialog extends StatefulWidget {
  final FirebaseDatabase? database;
  final FirebaseAuth? auth;

  const DrawingLogDialog({super.key, this.database, this.auth});

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

//function that controls if the the timer for a live drawing log entry
//is toggled on or off
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

//function for the date selector of the drawing entry
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

  void _clearFields() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _timeController.clear();
      _secondsElapsed = 0;
      _isTimerRunning = false;
      _timer?.cancel();
    });
  }

// function responsible for saving drawing log entries
// Drawing log entries are saved to Realtime Database and persist between sessions.
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) return;

    final timeInMinutes = double.tryParse(_timeController.text) ?? 0.0;

    try {
      final newDrawingRef = effectiveDatabase.ref('drawings').push();
      await newDrawingRef.set({
        'userId': user.uid,
        'title': _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        'description': _descriptionController.text,
        'timeSpentMinutes': timeInMinutes.toInt(),
        'effort': _effort,
        'timestamp': _selectedDate.millisecondsSinceEpoch,
        'createdAt': ServerValue.timestamp,
      });

//case of a drawing log being successfully saved
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drawing logged successfully!')),
        );
      }//end of succeess saving if statment
      //case of if there was an error saving a drawing log
    } //end of try/ end of case for successfully saving a log entry
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging drawing: $e')),
        );
      }//end of if statment for not properly saved case
    }
  }

//This is the widget for creating a drawing log entry
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Your Drawing'),
      content: SingleChildScrollView(
        //the form part of the drawing entry where all the info is entered
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //controls the title of the log entry
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title (Optional)'),
              ), //end of entry title field
              const SizedBox(height: 12), //space between fields of the form
              //where user enters the amount of time they spent of the drawing either manually
              //or by using the timer function 
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time Spent (Minutes)',
                  suffixIcon: IconButton(
                    icon: Icon(_isTimerRunning ? Icons.stop : Icons.play_arrow),
                    color: _isTimerRunning ? Colors.red : Colors.green,
                    onPressed: _toggleTimer,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ), //End of section of form for a log entry for time spent on the drawing

              //case of when the function for recording a drawing in realtime/ live
              if (_isTimerRunning)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  //shows the amount of time that has passed since the timer was started
                  child: Text(
                    'Timer active: ${(_secondsElapsed ~/ 60)}m ${(_secondsElapsed % 60)}s',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 12),
              ListTile(
                //where the date the drawing was complete can be entered
                //and the default date is the current date
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              //where user selects the amount of effort they put into what they drew
              DropdownButtonFormField<String>(
                value: _effort,
                decoration: const InputDecoration(labelText: 'Effort Level'),
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _effort = val!),
              ),
              const SizedBox(height: 12),
              //where user enters an optional description of what they drew
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),


      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      //buttons for saving a drawing entry or not saving the started
      //entry
      actions: [
        //discarding started entry button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        //saving entry button
        ElevatedButton(
          onPressed: _clearFields,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.orangeAccent,
          ), //end of style for save button
          child: const Text('Clear fields'),
        ),

        //saving entry button
        ElevatedButton(
          onPressed: _saveEntry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ), //end of style for save button
          child: const Text('Save'),
        ),
      ], //end of actions list
    );
  } //end of build widget

//essentially a clear button (I think)
  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  } //end of dispose function
}
