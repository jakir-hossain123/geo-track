import 'package:flutter/material.dart';
import 'package:path_tracker_app/Pages/sign_in_page.dart';
import 'package:path_tracker_app/Pages/sign_up_page.dart';

// This new AuthFlowPage manages the state that determines whether to show the
// login screen or the registration screen. It replaces the original AuthPage.
class AuthFlowPage extends StatefulWidget {
  const AuthFlowPage({super.key});

  @override
  State<AuthFlowPage> createState() => _AuthFlowPageState();
}

class _AuthFlowPageState extends State<AuthFlowPage> {
  // State to toggle between login and register
  bool isLogin = true;

  // Function to toggle the state and rebuild the widget tree
  void _toggleAuthScreen() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      // Show the SignIn page, passing the callback to switch to SignUp
      return SignInPage(onToggleSignUp: _toggleAuthScreen);
    } else {
      // Show the SignUp page, passing the callback to switch to SignIn
      return SignUpPage(onToggleSignIn: _toggleAuthScreen);
    }
  }
}
