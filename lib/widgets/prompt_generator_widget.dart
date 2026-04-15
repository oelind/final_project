import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PromptGeneratorWidget extends StatefulWidget {
  final List<String>? initialPrompts;
  const PromptGeneratorWidget({super.key, this.initialPrompts});

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
    if (widget.initialPrompts != null) {
      _prompts = widget.initialPrompts!;
      _isLoading = false;
    } else {
      _loadPrompts();
    }
  }

  Future<void> _loadPrompts() async {
    try {
      final String content = await rootBundle.loadString('assets/object_prompts.txt');
      final List<String> lines = content.split('\n');
      
      // Filter out empty lines, category headers (not starting with -), and dashes
      final List<String> filteredPrompts = lines
          .map((line) => line.replaceAll('-', '').trim())
          .where((line) => line.isNotEmpty)
          .toList();

      setState(() {
        _prompts = filteredPrompts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading prompts: $e');
      setState(() {
        _currentPrompt = 'Error loading prompts.';
        _isLoading = false;
      });
    }
  }

  void _generatePrompt() {
    if (_prompts.isEmpty) return;
    
    final random = Random();
    setState(() {
      _currentPrompt = _prompts[random.nextInt(_prompts.length)];
    });
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
