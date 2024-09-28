import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBEz_2pRGk0JtqP9yOshcLSBv0YfTIlDFs",
      authDomain: "backend-forms-afde8.firebaseapp.com",
      projectId: "backend-forms-afde8",
      storageBucket: "backend-forms-afde8.appspot.com",
      messagingSenderId: "479619835811",
      appId: "1:479619835811:web:d8eaf0147a2a5d14361c16",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
