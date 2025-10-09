import 'package:flutter/material.dart';
import 'package:path_tracker_app/Pages/sign_in_services.dart';
import 'package:path_tracker_app/Texts/walke_tracker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_tracker_app/Pages/sign_in_services.dart'; // Import remains the same


class SignInPage extends StatefulWidget {
  // Callback to switch to the registration screen
  final VoidCallback onToggleSignUp;

  const SignInPage({super.key, required this.onToggleSignUp});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthS _signInServices = AuthS(); // <-- FIX!

  // Controllers for Email and Password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State for loading indicator
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Helper function to display error messages via a SnackBar
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Function to handle standard Email/Password Sign-In
  Future<void> _signInUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorMessage('Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Success is handled by the main app's StreamBuilder
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e.message ?? 'An unknown sign-in error occurred.');
    } catch (e) {
      _showErrorMessage('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Function to handle Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _signInServices.signInWithGoogle();

      if (userCredential == null && mounted) {
        // Sign-in was cancelled by the user or failed silently
        _showErrorMessage('Google Sign-In cancelled or failed.');
      }
      // Successful sign-in is handled by the main app's StreamBuilder
    } on Exception catch (e) {
      // Handle exceptions thrown by the service
      _showErrorMessage('Failed to sign in with Google: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Widget for social sign-in buttons
  Widget _socialSignInButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: color),
        elevation: 2,
      ),
      onPressed: _isLoading ? null : onPressed,
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Sign in here')),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Walk tracker title
              const WalkeTracker(),
              const SizedBox(height: 40),

              // Email textfield
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password text field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // Sign in button with loading indicator
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: _isLoading ? null : _signInUser,
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 20),

              // Login or register toggle
              TextButton(
                onPressed: _isLoading ? null : widget.onToggleSignUp,
                child: const Text(
                  'Don\'t have an account? Register now',
                  style: TextStyle(color: Colors.teal),
                ),
              ),

              const SizedBox(height: 30),

              const Divider(thickness: 1, color: Colors.teal),

              const SizedBox(height: 20),

              // Sign in with Google button
              _socialSignInButton(
                'Sign in with Google',
                Icons.g_translate,
                Colors.red.shade600,
                _signInWithGoogle,
              ),

              const SizedBox(height: 12),

              // Sign in with Facebook button
              _socialSignInButton(
                'Sign in with Facebook',
                Icons.facebook,
                Colors.blue.shade700,
                    () {
                  // Placeholder for Facebook sign-in logic
                  _showErrorMessage('Facebook Sign-In not yet implemented.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
