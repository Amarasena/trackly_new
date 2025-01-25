import 'package:flutter/material.dart';
import 'package:trackly/screens/auth/views/login_page.dart';

void main() {
  runApp(const TracklyApp());
}

class TracklyApp extends StatelessWidget {
  const TracklyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackly',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
