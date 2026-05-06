import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/color_utils.dart';

class ComplexPromptGeneratorWidget extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseDatabase? database;

  const ComplexPromptGeneratorWidget({
    super.key,
    this.auth,
    this.database,
  });

  @override
  State<ComplexPromptGeneratorWidget> createState() => _ComplexPromptGeneratorWidgetState();
}

class _ComplexPromptGeneratorWidgetState extends State<ComplexPromptGeneratorWidget> {
  final Random _random = Random();

  final List<String> _subTopics = ['Nature', 'Buildings', 'Animals', 'People', 'Fantasy', 'Space', 'Underwater'];
  final List<String> _adjectives = ['Giant', 'Tiny', 'Glowing', 'Ancient', 'Mechanical', 'Floating', 'Colorful', 'Mysterious', 'Spooky', 'Elegant'];
  final List<String> _nouns = ['Trees', 'Skyscrapers', 'Dragons', 'Warriors', 'Planets', 'Coral Reefs', 'Ancient Ruins', 'Robots'];
  final List<String> _styles = ['Realism', 'Minimalism', 'Cartoonish', 'Impressionism', 'Cyberpunk', 'Sketchy', 'Watercolor', 'Pop Art'];

  String _selectedSubTopic = '...';
  String _selectedAdjective = '...';
  String _selectedNoun = '...';
  String _selectedStyle = '...';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStateFromDatabase();
  }

  Future<void> _loadStateFromDatabase() async {
    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await effectiveDatabase.ref('users/${user.uid}/state/complexPrompt').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        setState(() {
          _selectedSubTopic = data['subTopic'] ?? '...';
          _selectedAdjective = data['adjective'] ?? '...';
          _selectedNoun = data['noun'] ?? '...';
          _selectedStyle = data['style'] ?? '...';
        });
      }
    } catch (e) {
      debugPrint('Error loading complex prompt state: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveStateToDatabase() async {
    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) return;

    try {
      await effectiveDatabase.ref('users/${user.uid}/state/complexPrompt').set({
        'subTopic': _selectedSubTopic,
        'adjective': _selectedAdjective,
        'noun': _selectedNoun,
        'style': _selectedStyle,
        'updatedAt': ServerValue.timestamp,
      });
      await effectiveDatabase.ref('users/${user.uid}/prompt_presses').push().set(ServerValue.timestamp);
    } catch (e) {
      debugPrint('Error saving complex prompt state: $e');
    }
  }

  void _randomizeSubTopic() {
    setState(() {
      _selectedSubTopic = _subTopics[_random.nextInt(_subTopics.length)];
    });
    _saveStateToDatabase();
  }

  void _randomizeAdjective() {
    setState(() {
      _selectedAdjective = _adjectives[_random.nextInt(_adjectives.length)];
    });
    _saveStateToDatabase();
  }

  void _randomizeNoun() {
    setState(() {
      _selectedNoun = _nouns[_random.nextInt(_nouns.length)];
    });
    _saveStateToDatabase();
  }

  void _randomizeStyle() {
    setState(() {
      _selectedStyle = _styles[_random.nextInt(_styles.length)];
    });
    _saveStateToDatabase();
  }

  void _randomizeAll() {
    setState(() {
      _selectedSubTopic = _subTopics[_random.nextInt(_subTopics.length)];
      _selectedAdjective = _adjectives[_random.nextInt(_adjectives.length)];
      _selectedNoun = _nouns[_random.nextInt(_nouns.length)];
      _selectedStyle = _styles[_random.nextInt(_styles.length)];
    });
    _saveStateToDatabase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(16.0),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Mad Libs Drawing Prompt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightAqua.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkTeal.withOpacity(0.3)),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: AppColors.deepPlum, height: 1.5),
                  children: [
                    const TextSpan(text: 'Draw a '),
                    TextSpan(
                      text: _selectedSubTopic,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: ' with '),
                    TextSpan(
                      text: _selectedAdjective,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: _selectedNoun,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: ' in the style of '),
                    TextSpan(
                      text: _selectedStyle,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _randomizeSubTopic,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Sub-topic'),
                ),
                ElevatedButton(
                  onPressed: _randomizeAdjective,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Adjective'),
                ),
                ElevatedButton(
                  onPressed: _randomizeNoun,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Noun'),
                ),
                ElevatedButton(
                  onPressed: _randomizeStyle,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Style'),
                ),
                ElevatedButton.icon(
                  onPressed: _randomizeAll,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
