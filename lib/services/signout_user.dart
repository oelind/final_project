import 'package:firebase_auth/firebase_auth.dart';

Future<void> signoutUser(FirebaseAuth auth) async {
  await auth.signOut();
}
