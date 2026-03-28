import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/drawing.dart';
import 'widgets/drawing_card.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  
  const HomeScreen({super.key, this.firestore, this.auth});

  @override
  Widget build(BuildContext context) {
    final effectiveAuth = auth ?? FirebaseAuth.instance;
    final effectiveFirestore = firestore ?? FirebaseFirestore.instance;
    final user = effectiveAuth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await effectiveAuth.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: effectiveFirestore
            .collection('drawings')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data?.docs ?? [];
          if (documents.isEmpty) {
            return const Center(
              child: Text(
                'No drawings logged yet.\nStart your creative journey!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;
              final drawing = Drawing.fromFirestore(data);
              return DrawingCard(drawing: drawing);
            },
          );
        },
      ),
    );
  }
}
