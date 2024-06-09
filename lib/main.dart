import 'package:flutter/material.dart';
import 'package:taskly/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter("hive_boxes");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskly',
      theme: ThemeData(
          primarySwatch: Colors.red, // Sets the primary swatch to red
          useMaterial3: true, // Enables Material 3 design
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
