import 'package:flutter/material.dart';

class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({super.key});

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  bool isWeeklyGoal = true;
  final TextEditingController _timeController = TextEditingController();

  void _saveGoal() {
    if (_timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a time goal')),
      );
      return;
    }

    final goalType = isWeeklyGoal ? 'weekly' : 'daily';
    debugPrint('Goal set: ${_timeController.text} hours per $goalType');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal saved: ${_timeController.text} hours/$goalType')),
    );
    
    // In a real app, navigate to home or notification settings
    Navigator.of(context).pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Your Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How much time do you want to spend drawing?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Weekly Goal'),
                    selected: isWeeklyGoal,
                    onSelected: (selected) {
                      setState(() => isWeeklyGoal = true);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Daily Goal'),
                    selected: !isWeeklyGoal,
                    onSelected: (selected) {
                      setState(() => isWeeklyGoal = false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: isWeeklyGoal ? 'Hours per week' : 'Hours per day',
                border: const OutlineInputBorder(),
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Goal', style: TextStyle(fontSize: 18)),
            ),
          ],
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
