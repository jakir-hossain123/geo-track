import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  bool isLogin = true;

  // IMPORTANT: Dispose controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ইউজার ইন্টারফেস ডিজাইন (এখনও লগইন লজিক যুক্ত করা হয়নি)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(isLogin ? 'Sign in page' : 'Register page')),
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
              // অ্যাপ লোগো বা টাইটেল
              const Text(
                'Walk Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 40),

              // ইমেল ইনপুট
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

              // পাসওয়ার্ড ইনপুট
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),

              if (!isLogin) ...[
                const SizedBox(height: 16),
                // confirm pass TextField
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 30),

              // প্রধান বাটন (সাইন ইন / সাইন আপ)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () {
                  // TODO: ধাপ ৩ এ Firebase Auth লজিক যুক্ত করা হবে
                  print('Email: ${_emailController.text}, '
                      'Password: ${_passwordController.text}'
                  );
                },
                child: Text(
                  isLogin ? 'Sign in' : 'Register',
                  style: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 20),

              // লগইন/রেজিস্টার টগল
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin; // স্টেট টগল করুন

                    // --- Fix: Clear text fields when switching modes ---
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    // --------------------------------------------------

                  });
                },
                child: Text(
                  isLogin ? 'Dont have account ? Register now' : 'Already have an account ? Login now',
                  style: const TextStyle(color: Colors.teal),
                ),
              ),

              const SizedBox(height: 30),

              const Divider(thickness: 1,color: Colors.teal,),

              const SizedBox(height: 20),

              // সোশাল মিডিয়া সাইন-ইন অপশন (স্থানধারক)
              _socialSignInButton(
                'Sign in with Google',
                Icons.g_translate,
                Colors.red.shade600,
                    () {
                  // TODO: ধাপ ৩ এ Google Sign-in লজিক যুক্ত করা হবে
                },
              ),
              const SizedBox(height: 12),
              _socialSignInButton(
                'Sign in with Facebook',
                Icons.facebook,
                Colors.blue.shade700,
                    () {
                  // TODO: ধাপ ৩ এ Facebook Sign-in লজিক যুক্ত করা হবে
                  print('Facebook Sign-in clicked');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // সোশাল সাইন-ইন বাটনের জন্য একটি উইজেট ফাংশন
  Widget _socialSignInButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      style: OutlinedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: color),
      ),
      onPressed: onPressed,
    );
  }
}
