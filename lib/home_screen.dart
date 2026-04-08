import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/drawing.dart';
import 'widgets/drawing_card.dart';
import 'widgets/goal_progress_widget.dart';
import 'widgets/drawing_log_dialog.dart';
import 'services/signout_user.dart';
import 'goal_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  
  const HomeScreen({super.key, this.firestore, this.auth});

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
          //pop up menu for signing out, editing goal (will try to add a new page
          //to have a page to edit goal instead of just having the initial setting up
          //page), or editing the notifications settings
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'signout') {
                await signoutUser(effectiveAuth);
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
                //will create seperate statments for the goal and notifications
              //currently when goal or notifications are selected the app goes to the initial goal
              //set up screen
              } else if (value == 'goal' || value == 'notifications') {
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GoalSetupScreen()),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //currently default is no drawing logged yet state
                        //and seems hardcoded
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
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
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
