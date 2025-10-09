import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_tracker_app/Pages/auth_services.dart';
import 'package:path_tracker_app/firebase_options.dart';
import 'package:path_tracker_app/models/walk_data.dart';



void main () async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hive Initialization and Setup
  await Hive.initFlutter();

  // LatLngAdapterAdapter
  Hive.registerAdapter<LatLngAdapter>(LatLngAdapterAdapter());

  // WalkData adaptor register
  Hive.registerAdapter<WalkData>(WalkDataAdapter());

  // hu=ive box open
  await Hive.openBox<WalkData>('walks');

  runApp(const Myapp());
}
class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walking Path Tracker',
      theme: ThemeData(
        colorScheme:ColorScheme.fromSeed(seedColor: Colors.teal),
      ),

      home: const AuthServices(),
    );
  }
}
