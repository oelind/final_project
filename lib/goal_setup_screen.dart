import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'services/save_settings.dart';

class GoalSetupScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseDatabase? database;

  const GoalSetupScreen({super.key, this.auth, this.database});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  bool isWeeklyGoal = true;
  final TextEditingController _timeController = TextEditingController();
  
  // Notification settings (Requirements 3 & 4)
  bool wantNotifications = false;
  String reminderFrequency = 'Daily';
  TimeOfDay reminderStartTime = const TimeOfDay(hour: 12, minute: 0); // Default Noon
  TimeOfDay reminderEndTime = const TimeOfDay(hour: 0, minute: 0); // Default Midnight

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? reminderStartTime : reminderEndTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          reminderStartTime = picked;
        } else {
          reminderEndTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

//case of user not being signed in and trying to set a goal
    if (user == null){
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in. Please log in to be able to save your goal')),
    );
     return;
     }//end if if statment for case of user not logged in

    try {
      final snapshot = await effectiveDatabase.ref('users/${user.uid}/settings').get();
      if (snapshot.exists && snapshot.value != null) {
        final settings = Map<dynamic, dynamic>.from(snapshot.value as Map);

        setState(() {
          _timeController.text = (settings['timeGoal'] as num?)?.toString() ?? '';
          isWeeklyGoal = settings['isWeeklyGoal'] ?? true;
          wantNotifications = settings['wantNotifications'] ?? false;
          reminderFrequency = settings['reminderFrequency'] ?? 'Daily';
          
          // Parse time strings back to TimeOfDay if possible
          if (settings['reminderStartTime'] != null) {
            reminderStartTime = _parseTimeOfDay(settings['reminderStartTime']);
          }
          if (settings['reminderEndTime'] != null) {
            reminderEndTime = _parseTimeOfDay(settings['reminderEndTime']);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1].toUpperCase() == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal & Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Drawing Goal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'How much time do you want to spend drawing?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Weekly'),
                      selected: isWeeklyGoal,
                      onSelected: (selected) {
                        setState(() => isWeeklyGoal = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Daily'),
                      selected: !isWeeklyGoal,
                      onSelected: (selected) {
                        setState(() => isWeeklyGoal = false);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: isWeeklyGoal ? 'Hours per week' : 'Hours per day',
                  border: const OutlineInputBorder(),
                  suffixText: 'hours',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Enable Reminders'),
                subtitle: const Text('Get notified to work towards your goal'),
                value: wantNotifications,
                onChanged: (value) {
                  setState(() => wantNotifications = value);
                },
                contentPadding: EdgeInsets.zero,
              ),
              if (wantNotifications) ...[
                const SizedBox(height: 16),
                const Text('Reminder Frequency:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: reminderFrequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: ['Every 2 hours', 'Daily', 'Every 2 days']
                      .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => reminderFrequency = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Time:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _selectTime(context, true),
                            child: Text(_formatTime(reminderStartTime)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latest Time:', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => _selectTime(context, false),
                            child: Text(_formatTime(reminderEndTime)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => saveSettings(
                  context: context,
                  timeGoal: _timeController.text,
                  isWeeklyGoal: isWeeklyGoal,
                  wantNotifications: wantNotifications,
                  reminderFrequency: reminderFrequency,
                  reminderStartTime: _formatTime(reminderStartTime),
                  reminderEndTime: _formatTime(reminderEndTime),
                  auth: widget.auth,
                  database: widget.database,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save & Continue', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }
}
