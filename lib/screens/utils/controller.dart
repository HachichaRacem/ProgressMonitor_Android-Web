import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

class Controller extends GetxController {
  late final FirebaseApp app;
  late final FirebaseDatabase database;

  late final StreamSubscription subscription;

  final TextEditingController textEditingController =
      TextEditingController(text: '0');

  final FocusNode textInputFocusNode = FocusNode();

  final status = "".obs;
  final connected = true.obs;
  final shutdown = false.obs;
  final hibernate = false.obs;

  @override
  void onInit() {
    super.onInit();
    database = FirebaseDatabase.instance;
    database.ref().child('updates/lastSeen').onValue.listen((event) {
      status.value = event.snapshot.value.toString();
    });
    subscription = ConnectivityChecker(interval: const Duration(seconds: 5))
        .stream
        .listen((event) {
      connected.value = event;
    });
  }

  void sendUrgentAction(int id) {
    int interval = int.parse(textEditingController.text);
    switch (id) {
      case 0:
        {
          //shutdown
          try {
            database
                .ref()
                .child('actions')
                .set({'actionTaken': 'shutdown', 'interval': interval});
          } catch (e) {
            Get.showSnackbar(
              GetSnackBar(
                dismissDirection: DismissDirection.down,
                isDismissible: true,
                duration: const Duration(seconds: 2),
                messageText: Center(
                  child: Text(
                    "Something went wrong while updating the database.",
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            );
          }
        }
      case 1:
        {
          //hibernate
          try {
            database
                .ref()
                .child('actions')
                .set({'actionTaken': 'hibernate', 'interval': interval});
          } catch (e) {
            Get.showSnackbar(
              GetSnackBar(
                dismissDirection: DismissDirection.down,
                isDismissible: true,
                duration: const Duration(seconds: 2),
                messageText: Center(
                  child: Text(
                    "Something went wrong while updating the database.",
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            );
          }
        }
    }
  }
}
