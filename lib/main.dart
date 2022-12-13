import 'package:flutter/material.dart';
import 'database.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 37, 43, 48),
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: FutureBuilder(
              future: Database.init(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const HomePage();
                } else if (snapshot.hasError) {
                  return const Text(
                      "Something went wrong with connecting to the database.",
                      style: TextStyle(color: Colors.white));
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
