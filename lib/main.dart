import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supachat_v1/constants/constants.dart';
import 'package:supachat_v1/pages/redirect_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // TODO: url i anonkey su u konstantama
    url: 'https://ipabxnypzmbcqkqadoqp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwYWJ4bnlwem1iY3FrcWFkb3FwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTM5NDUxNTYsImV4cCI6MjAyOTUyMTE1Nn0.JcF6I8_0fhXmPFBCZhzE-6tEB5I9-M1nnxNjb2xXySY',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: chatAppTheme,
      home: const RedirectPage(),
    );
  }
}
//TODO: 