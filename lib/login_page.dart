import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'signup_page.dart';
import 'services/login_user.dart';

class LoginPage extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  final List<String>? initialPrompts;
  const LoginPage({super.key, this.auth, this.firestore, this.initialPrompts});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuth.instance;

    // Check for existing session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              auth: _auth,
              firestore: widget.firestore,
              initialPrompts: widget.initialPrompts,
            ),
          ),
        );
      }
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    //case for if the user did not enter their password
    // or if the user did not enter their email
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both your email and your password.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }//end of if statment for missing password/ missing email

//this chunk of code gets the user's user-credentials for firebase
    try {
      final userCredential = await loginUser(
        auth: _auth,
        email: email,
        password: password,
      );

      //if statment for if a uder does have the proper credential
      // for/through firebase authorization
      if (userCredential?.user != null) {
        debugPrint('Login successful for: ${userCredential?.user?.email}');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                auth: _auth,
                firestore: widget.firestore,
                initialPrompts: widget.initialPrompts,
              ),
            ),
          );
        }
      }
 else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please check your credentials.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Login failed for: $email - ${e.code}');
      String message = 'Invalid email or password.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('An error occurred during login: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }//end over overarching login function

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DrawingLog Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.brush, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(
                        auth: widget.auth,
                        firestore: widget.firestore,
                      ),
                    ),
                  );
                },
                child: const Text('Don\'t have an account? Create one'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
