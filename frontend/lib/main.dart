import 'package:flutter/material.dart';
import 'package:frontend/screen/add_group_screen.dart';
import 'package:frontend/screen/home_page.dart';
import 'package:frontend/screen/login.dart';
import 'package:frontend/screen/register.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: LoginPage.id,
      routes: {
        LoginPage.id: (context) => LoginPage(),
        RegisterPage.id: (context) => RegisterPage(),
        HomePage.id: (context) => HomePage(),
        AddGroupScreen.id: (context) => AddGroupScreen(),
      },
    );
  }
}
