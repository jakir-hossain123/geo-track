import 'package:flutter/material.dart';
import 'package:path_tracker_app/Texts/walke_tracker.dart';

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

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(isLogin ? 'Sign in here' : 'Register here')),
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
              //  Walk tracker
              WalkeTracker(),
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

              // password text field
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

              // sign in/register button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () {
                  // Auth logic
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

              // login or register toggle
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;

                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();

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

              // Sign in with google and facebook
              _socialSignInButton(
                'Sign in with Google',
                Icons.g_translate,
                Colors.red.shade600,
                    () {
                  // sign in logic  google
                },
              ),
              const SizedBox(height: 12),
              _socialSignInButton(
                'Sign in with Facebook',
                Icons.facebook,
                Colors.blue.shade700,
                    () {
                  // sign in logic for facebook

                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
