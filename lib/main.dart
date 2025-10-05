import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'Pages/auth_page.dart';

void main () async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase successfully initialized');

  }
  catch (e){
    print("Firebase initializing  failed : $e");
  }

  // initialize hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(Myapp());
}
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Tracker',
      theme: ThemeData(
        colorScheme:ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

     home: const AuthPage(),
    );
  }
}
