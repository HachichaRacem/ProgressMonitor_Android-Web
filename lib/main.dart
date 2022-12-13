import 'package:flutter/material.dart';
import 'package:pm_web/home_page.dart';
import 'database.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(
            const Color.fromARGB(255, 83, 88, 95),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 37, 43, 48),
        body: Container(
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
    );
  }
}
