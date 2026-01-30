import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/project_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://defpyeebacdhfbwbbyxh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlZnB5ZWViYWNkaGZid2JieXhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2MDc1OTksImV4cCI6MjA4NDE4MzU5OX0.y-wDo0N3_Wx_y7sFfDKigd0rVhPLhEfzI42C5tg4tLQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: 'Daily Life Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Tajawal',
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: Colors.blue,
          fontFamily: 'Tajawal',
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
