import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_tracker_app/Pages/auth_flow_page.dart';
import 'package:path_tracker_app/Pages/map_page.dart';
class AuthServices extends StatelessWidget {
  const AuthServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder:  (context, snapshot) {

            //user id logged in

            if (snapshot.hasData){
              return MapPage();
            }

            //user is not logged in
            else {
              return AuthFlowPage();
            }

          },
      ),
    );
  }
}
