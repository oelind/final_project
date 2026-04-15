import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  final List<String>? initialPrompts;
  
  const HomeScreen({super.key, this.firestore, this.auth, this.initialPrompts});

  void _showLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DrawingLogDialog(
        firestore: firestore,
        auth: auth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveAuth = auth ?? FirebaseAuth.instance;
    final effectiveFirestore = firestore ?? FirebaseFirestore.instance;
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
                        firestore: firestore,
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
                        firestore: effectiveFirestore,
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
          GoalProgressWidget(auth: effectiveAuth, firestore: effectiveFirestore),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: effectiveFirestore
                  .collection('drawings')
                  .where('userId', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];
                if (documents.isEmpty) {
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
                          PromptGeneratorWidget(initialPrompts: initialPrompts),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: documents.length + 1,
                  itemBuilder: (context, index) {
                    if (index == documents.length) {
                      return PromptGeneratorWidget(initialPrompts: initialPrompts);
                    }
                    final data = documents[index].data() as Map<String, dynamic>;
                    final drawing = Drawing.fromFirestore(data);
                    return DrawingCard(drawing: drawing);
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
