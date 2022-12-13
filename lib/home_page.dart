import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';
import 'package:progress_monitor/assets.dart';
import 'package:progress_monitor/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController fadeInController;
  late final AnimationController slideInController;

  late final Animation<double> fadeInAnimation;
  late final Animation<Offset> slideInAnimation;

  @override
  void initState() {
    super.initState();
    fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    slideInController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeInController, curve: Curves.ease),
    );

    slideInAnimation =
        Tween<Offset>(begin: const Offset(-0.1, 0.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: slideInController,
                curve: Curves.fastLinearToSlowEaseIn));

    fadeInController.forward();
    slideInController.forward();
  }

  @override
  void dispose() {
    fadeInController.dispose();
    slideInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeInAnimation,
      child: SlideTransition(
        position: slideInAnimation,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const UploadButton(),
              Expanded(
                child: StreamBuilder(
                  stream: Database.dbRef?.child('images').onValue,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Event e = snapshot.data as Event;
                      if (e.snapshot.value != null) {
                        return const Screeshot();
                      } else {
                        return Center(
                            child: Text("It's lonely here..",
                                style: Assets.generalFont));
                      }
                    } else if (snapshot.hasError) {
                      return Text("Error", style: Assets.errorFont);
                    } else {
                      return const Center(
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                              color: Assets.progressColor, strokeWidth: 1.5),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
