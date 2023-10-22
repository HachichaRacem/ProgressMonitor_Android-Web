import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_android/screens/utils/controller.dart';
import 'package:pm_android/screens/utils/screenshot.dart';
import 'package:pm_android/screens/utils/settings.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final Controller controller = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232428),
      extendBody: false,
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                child: Center(
                  child: Obx(
                    () => Text(
                      controller.connected.value
                          ? "${controller.status}"
                          : "Waiting for a stable internet connection..",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 2, child: SizedBox(child: Center(child: Screenshot()))),
            Expanded(flex: 2, child: SizedBox(child: Center(child: Settings())))
          ],
        ),
      ),
    );
  }
}
