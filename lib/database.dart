// ignore_for_file: avoid_print

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:pm_web/firebase_options.dart';

class Database {
  static late FirebaseApp app;
  static FirebaseApp? test;
  static FirebaseAuth? auth;
  static FirebaseDatabase? db;
  static DatabaseReference? dbRef;
  static FirebaseStorage? storage;
  static Reference? storageRef;
  static ValueNotifier<bool> isPCConnected = ValueNotifier<bool>(false);

  static Future<bool> init() async {
    if (test == null) {
      try {
        Database.test =
            await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      } on Exception catch (e) {
        print(e);
        return false;
      }
    }
    app = test!;
    if (Database.auth == null) {
      Database.auth = FirebaseAuth.instanceFor(app: app);
      try {
        await Database.auth?.signInWithEmailAndPassword(
            email: 'hellohi@g.com', password: 'password123');
      } catch (error) {
        print(error);
        return false;
      }
    }
    if (Database.db == null) {
      try {
        Database.db = FirebaseDatabase.instance;
      } on Exception catch (e) {
        print(e);
        return false;
      }
    }
    if (Database.dbRef == null) {
      try {
        Database.dbRef = db?.ref();
      } on Exception catch (e) {
        print(e);
        return false;
      }
    }
    if (Database.storage == null) {
      try {
        Database.storage = FirebaseStorage.instanceFor(app: app);
      } on Exception catch (e) {
        print(e);
        return false;
      }
    }
    if (Database.storageRef == null) {
      try {
        Database.storageRef = Database.storage?.ref();
      } on Exception catch (e) {
        print(e);
        return false;
      }
    }
    Database.dbRef?.child('connection/connected').onValue.listen((event) async {
      if (event.snapshot.value == true) {
        Database.isPCConnected.value = true;
      } else {
        Database.isPCConnected.value = false;
      }
    });
    return true;
  }
}
