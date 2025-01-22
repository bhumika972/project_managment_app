import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'project_provider.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization for both web and other platforms
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDEIHPCGJ03in_OIV3cNEbpElliNE9C-CA",
          authDomain: "projectmanagement-bfd58.firebaseapp.com",
          projectId: "projectmanagement-bfd58",
          storageBucket: "projectmanagement-bfd58.firebasestorage.app",
          messagingSenderId: "841829796229",
          appId: "1:841829796229:web:c6da02ce46ea1bfff9dcec"),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Project Management App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
      ),
    );
  }
}
