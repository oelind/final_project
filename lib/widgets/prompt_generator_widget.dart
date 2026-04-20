import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PromptGeneratorWidget extends StatefulWidget {
  final List<String>? initialPrompts;
  final FirebaseAuth? auth;
  final FirebaseDatabase? database;

  const PromptGeneratorWidget({
    super.key, 
    this.initialPrompts,
    this.auth,
    this.database,
  });

  @override
  State<PromptGeneratorWidget> createState() => _PromptGeneratorWidgetState();
}

class _PromptGeneratorWidgetState extends State<PromptGeneratorWidget> {
  String _currentPrompt = 'Tap the button to generate a prompt!';
  List<String> _prompts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWidget();
  }

  Future<void> _initWidget() async {
    if (widget.initialPrompts != null) {
      _prompts = widget.initialPrompts!;
    } else {
      await _loadPromptsFromAssets();
    }
    await _loadLastPromptFromDatabase();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPromptsFromAssets() async {
    try {
      final String content = await rootBundle.loadString('assets/object_prompts.txt');
      final List<String> lines = content.split('\n');
      
      final List<String> filteredPrompts = lines
          .map((line) => line.replaceAll('-', '').trim())
          .where((line) => line.isNotEmpty)
          .toList();

      _prompts = filteredPrompts;
    } catch (e) {
      debugPrint('Error loading prompts from assets: $e');
    }
  }

  Future<void> _loadLastPromptFromDatabase() async {
    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user == null) return;

    try {
      final snapshot = await effectiveDatabase.ref('users/${user.uid}/state/lastPrompt').get();
      if (snapshot.exists && snapshot.value != null) {
        setState(() {
          _currentPrompt = snapshot.value as String;
        });
      }
    } catch (e) {
      debugPrint('Error loading last prompt: $e');
    }
  }

  Future<void> _generatePrompt() async {
    if (_prompts.isEmpty) return;
    
    final random = Random();
    final newPrompt = _prompts[random.nextInt(_prompts.length)];
    
    setState(() {
      _currentPrompt = newPrompt;
    });

    // Save to Database
    final effectiveAuth = widget.auth ?? FirebaseAuth.instance;
    final effectiveDatabase = widget.database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    if (user != null) {
      try {
        await effectiveDatabase.ref('users/${user.uid}/state').update({
          'lastPrompt': newPrompt,
        });
      } catch (e) {
        debugPrint('Error saving last prompt: $e');
      }
    }
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Drawing Prompt Generator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _currentPrompt,
                style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _generatePrompt,
              icon: const Icon(Icons.refresh),
              label: const Text('Generate Random Prompt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
