import 'package:firebase_auth/firebase_auth.dart';
//This file allows the user to sign out of their account
Future<void> signoutUser(FirebaseAuth auth) async {
  await auth.signOut();
}
