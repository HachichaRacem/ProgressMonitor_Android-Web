// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';
import 'package:firebase_dart/firebase_dart.dart';
import 'assets.dart';

class Database {
  static late FirebaseApp app;
  static FirebaseApp? test;
  static FirebaseAuth? auth;
  static FirebaseDatabase? db;
  static DatabaseReference? dbRef;
  static FirebaseStorage? storage;
  static Reference? storageRef;

  static Timer? urgentTimer;

  static const options = FirebaseOptions(
    apiKey: 'AIzaSyA2wiWndvqD2i0noXnh-b-xP8grwGL1AWA',
    appId: '1:220469906162:web:59b2cbd79ea3ed0cd19e6b',
    messagingSenderId: '220469906162',
    authDomain: 'example-f1815.firebaseapp.com',
    databaseURL:
        'https://example-f1815-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'example-f1815.appspot.com',
    projectId: 'example-f1815',
  );

  static Future<bool> init() async {
    if (test == null) {
      try {
        Database.test = await Firebase.initializeApp(options: options);
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
        Database.db = FirebaseDatabase(app: app);
      } on Exception catch (e) {
        print(e);
        return false;
      }
    }
    if (Database.dbRef == null) {
      try {
        Database.dbRef = db?.reference();
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
    Database.dbRef?.child('actions').onChildChanged.listen((event) async {
      if (event.snapshot.value) {
        if (urgentTimer == null) {
          int tick = await Database.dbRef?.child('actions/time').get();
          urgentTimer =
              Timer.periodic(const Duration(seconds: 1), (timer) async {
            if (tick != 0) {
              tick--;
              print('TICK : $tick');
            } else {
              UploadButton.timer?.cancel();
              UploadButton.isUploading.value = false;
              Assets.actionTimer?.cancel();
              Assets.isUploading == false;
              if (event.snapshot.key == 'shutdown') {
                urgentTimer?.cancel();
                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await Database.dbRef
                        ?.child('connection')
                        .update({'reason': 'PC set to shutdown (urgent)'});
                    await Database.dbRef?.child('actions/shutdown').set(false);
                  }
                } on SocketException catch (e) {
                  print('ERROR : $e');
                }
                await Process.run(runInShell: true, 'shutdown', ['/s']);
              } else if (event.snapshot.key == 'hibernate') {
                urgentTimer?.cancel();
                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await Database.dbRef
                        ?.child('connection')
                        .update({'reason': 'PC set to hibernate (urgent)'});
                    await Database.dbRef?.child('actions/hibernate').set(false);
                  }
                } on SocketException catch (e) {
                  print('ERROR : $e');
                }
                await Process.run(runInShell: true, 'shutdown', ['/h']);
              } else {
                urgentTimer?.cancel();
              }
            }
          });
        }
      } else {
        urgentTimer?.cancel();
      }
    });
    Database.dbRef?.child('.info/connected').onValue.listen((event) async {
      if (event.snapshot.value) {
        Database.dbRef
            ?.child('connection')
            .onDisconnect()
            .update({'lastSeen': ServerValue.timestamp, 'connected': false});
        await Database.dbRef
            ?.child('connection')
            .update({'connected': true, 'reason': 'Connection issues'});
      }
    });
    return true;
  }
}
