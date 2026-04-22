import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/drawing.dart';
import 'widgets/drawing_card.dart';
import 'widgets/goal_progress_widget.dart';
import 'widgets/drawing_log_dialog.dart';
import 'widgets/prompt_generator_widget.dart';
import 'services/signout_user.dart';
import 'goal_setup_screen.dart';
import 'login_page.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseDatabase? database;
  final FirebaseAuth? auth;
  final List<String>? initialPrompts;
  
  const HomeScreen({super.key, this.database, this.auth, this.initialPrompts});

  void _showLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DrawingLogDialog(
        database: database,
        auth: auth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAuth = auth ?? FirebaseAuth.instance;
    final effectiveDatabase = database ?? FirebaseDatabase.instance;
    final user = effectiveAuth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Log'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'signout') {
                await signoutUser(effectiveAuth);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        auth: auth,
                        database: database,
                      ),
                    ),
                    (route) => false,
                  );
                }
              } else if (value == 'goal' || value == 'notifications') {
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GoalSetupScreen(
                        auth: effectiveAuth,
                        database: effectiveDatabase,
                      ),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'goal',
                child: ListTile(
                  leading: Icon(Icons.track_changes),
                  title: Text('Edit Goal'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'notifications',
                child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notification Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Sign Out', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          GoalProgressWidget(auth: effectiveAuth, database: effectiveDatabase),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: effectiveDatabase.ref('drawings').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<Drawing> drawings = [];
                if (snapshot.data?.snapshot.value != null) {
                  final drawingsMap = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                  final allDrawings = drawingsMap.values
                      .map((data) => Drawing.fromMap(Map<dynamic, dynamic>.from(data as Map)));
                  
                  // Filter by userId in-memory
                  drawings.addAll(allDrawings.where((d) => d.userId == user?.uid));
                  
                  // Sort by timestamp descending
                  drawings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                }

                if (drawings.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No drawings logged yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showLogDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Record your first entry'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 20),
                          PromptGeneratorWidget(
                            initialPrompts: initialPrompts,
                            auth: effectiveAuth,
                            database: effectiveDatabase,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: drawings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == drawings.length) {
                      return PromptGeneratorWidget(
                        initialPrompts: initialPrompts,
                        auth: effectiveAuth,
                        database: effectiveDatabase,
                      );
                    }
                    return DrawingCard(drawing: drawings[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogDialog(context),
        tooltip: 'Log Drawing',
        child: const Icon(Icons.add),
      ),
    );
  }
}
