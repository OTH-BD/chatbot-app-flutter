import 'package:chatbot_app/pages/chatbot.page.dart';
import 'package:chatbot_app/pages/login.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context)=>LoginPage(),
        "/chatbot": (context)=>ChatbotPage(),
      },
      theme: ThemeData(
        primaryColor: Colors.teal
      ),
    );
  }
}

