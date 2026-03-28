import 'package:flutter/material.dart';
import 'services/save_settings.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  bool isWeeklyGoal = true;
  final TextEditingController _timeController = TextEditingController();
  
  // Notification settings (Requirements 3 & 4)
  bool wantNotifications = false;
  String reminderFrequency = 'Daily'; // Default frequency

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
                keyboardType: TextInputType.number,
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
                  initialValue: reminderFrequency,
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
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => saveSettings(
                  context: context,
                  timeGoal: _timeController.text,
                  isWeeklyGoal: isWeeklyGoal,
                  wantNotifications: wantNotifications,
                  reminderFrequency: reminderFrequency,
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
