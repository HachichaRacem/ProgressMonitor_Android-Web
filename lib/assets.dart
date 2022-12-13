import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_dart/firebase_dart.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_compression/image_compression.dart';
import 'package:progress_monitor/database.dart';

class Assets {
  static final TextStyle generalFont = GoogleFonts.inter(
    color: const Color.fromARGB(255, 255, 255, 255),
    fontSize: 14,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  static final TextStyle errorFont = GoogleFonts.inter(
    color: const Color.fromARGB(255, 221, 69, 69),
    fontSize: 14,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  static final TextStyle settingsCardFont = GoogleFonts.inter(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w200,
    decoration: TextDecoration.none,
  );

  static const Color primaryColor = Color.fromARGB(255, 37, 43, 48);
  static const Color secondColor = Color.fromARGB(255, 38, 42, 47);
  static const Color progressColor = Color.fromARGB(255, 74, 87, 109);
  static const Color titleBarColor = Color.fromARGB(255, 44, 49, 55);

  static bool isUploading = false;
  static int lastSelectedAction = -1;

  static Timer? actionTimer;

  static final ValueNotifier<int> actionTimerValue = ValueNotifier<int>(0)
    ..addListener(() {
      if (actionTimerValue.value == -1) {
        actionTimer?.cancel();
      } else {
        int time = actionTimerValue.value + 1;
        actionTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
          if (time != 0) {
            ActionInputField.controller.text = '${time - 1}';
            time--;
          } else {
            actionTimer?.cancel();
            UploadButton.timer?.cancel();
            UploadButton.isUploading.value = false;
            Assets.isUploading == false;
            switch (Checkboxes.selectedID) {
              case 0:
                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await Database.dbRef
                        ?.child('connection')
                        .update({'reason': 'PC set to shutdown'});
                  }
                } on SocketException catch (e) {
                  debugPrint('ERROR : $e');
                }
                await Process.run(runInShell: true, 'shutdown', ['/s']);
                break;
              case 1:
                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await Database.dbRef
                        ?.child('connection')
                        .update({'reason': 'PC set to hibernate'});
                  }
                } on SocketException catch (e) {
                  debugPrint('ERROR : $e');
                }
                await Process.run(runInShell: true, 'shutdown', ['/h']);
                break;
            }
          }
        });
      }
    });
}

class Controller extends GetxController {
  var currentIndex = 0.obs;
  increment(index) => currentIndex = index;
}

class WindowButtons extends StatelessWidget {
  WindowButtons({Key? key}) : super(key: key);

  onError() {
    throw '[ERROR] : Couldn\'t reach the database, closing the app instead.';
  }

  onClose() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await Database.dbRef
            ?.child('connection')
            .update({'reason': 'The application has been closed'});
      }
    } on SocketException catch (e) {
      debugPrint('ERROR : $e');
    } finally {
      appWindow.close();
    }
  }

  final buttonColor = WindowButtonColors(
      normal: Assets.titleBarColor,
      iconNormal: Colors.white,
      mouseOver: const Color.fromARGB(255, 68, 81, 95));

  final closeButtonColor = WindowButtonColors(
      normal: Assets.titleBarColor,
      iconNormal: Colors.white,
      mouseOver: const Color.fromARGB(255, 68, 81, 95),
      mouseDown: const Color.fromARGB(255, 219, 68, 68));

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColor),
        MaximizeWindowButton(colors: buttonColor),
        CloseWindowButton(colors: closeButtonColor, onPressed: onClose)
      ],
    );
  }
}

class Screeshot extends StatefulWidget {
  const Screeshot({Key? key}) : super(key: key);

  @override
  State<Screeshot> createState() => _ScreeshotState();
}

class _ScreeshotState extends State<Screeshot> {
  String value = '';

  getImage(String url) async {
    var task = await Database.storage?.refFromURL(url).getData();
    return task;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: StreamBuilder(
        stream: Database.dbRef?.child('images').limitToLast(1).onChildAdded,
        builder: (context, snap) {
          if (snap.hasData) {
            Event e = snap.data as Event;
            Map m = Map.from(e.snapshot.value);
            value = m.values
                .toString()
                .substring(1, m.values.toString().length - 1);
            return FutureBuilder(
              future: getImage(value),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  Uint8List img = snapshot.data as Uint8List;
                  return Image.memory(img);
                } else {
                  return const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                        color: Assets.progressColor, strokeWidth: 2.5),
                  );
                }
              }),
            );
          } else {
            return const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                  color: Assets.progressColor, strokeWidth: 2.5),
            );
          }
        },
      ),
    );
  }
}

class UploadButton extends StatefulWidget {
  const UploadButton({Key? key}) : super(key: key);

  static Timer? timer;
  static ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);

  @override
  State<UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<UploadButton> {
  capture() async {
    var task = await Process.run(runInShell: true, 'screenCap', ['test.png']);
    return task.exitCode;
  }

  updateTimer() async {
    var task = await Database.dbRef?.child('settings/timer').get();
    return task;
  }

  uploadToDB() async {
    if (UploadButton.isUploading.value == false) {
      UploadButton.isUploading.value = true;
      int? time = await updateTimer();
      if (time != null) {
        UploadButton.timer = Timer.periodic(
          Duration(seconds: time),
          (timer) async {
            if (await capture() == 0) {
              File f = File('test.png');
              final input =
                  ImageFile(filePath: f.path, rawBytes: f.readAsBytesSync());
              const config =
                  Configuration(pngCompression: PngCompression.bestCompression);
              final output = await compressInQueue(
                  ImageFileConfiguration(input: input, config: config));

              try {
                var task = await Database.storageRef
                    ?.child('ss.png')
                    .putData(output.rawBytes);
                if (task?.state == TaskState.success) {
                  var url = await task?.ref.getDownloadURL();
                  var ref =
                      Database.dbRef?.child('images').push().child('link');
                  await ref?.set(url);
                }
              } on Exception catch (e) {
                debugPrint(e.toString());
                return;
              }
            }
          },
        );
      }
    } else {
      UploadButton.isUploading.value = false;
      UploadButton.timer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    UploadButton.isUploading.addListener(() {
      setState((() {}));
    });
  }

  @override
  void dispose() {
    UploadButton.timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: IconButton(
          icon: const Icon(Icons.play_arrow, color: Colors.white, size: 17),
          onPressed: uploadToDB),
      secondChild: IconButton(
          icon: const Icon(Icons.pause, color: Colors.white, size: 17),
          onPressed: uploadToDB),
      crossFadeState: UploadButton.isUploading.value
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}

class InputField extends StatefulWidget {
  const InputField({Key? key}) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var task = await Database.dbRef?.child('settings/timer').get();
      if (task != null) {
        _controller.text = task.toString();
      } else {
        _controller.text = '0';
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 60,
        height: 30,
        child: TextField(
          inputFormatters: [LengthLimitingTextInputFormatter(5)],
          controller: _controller,
          onSubmitted: (value) async {
            await Database.dbRef?.child('settings').update(
              {'timer': int.parse(value)},
            );
          },
          cursorColor: const Color.fromARGB(255, 169, 176, 180),
          decoration: const InputDecoration(
            constraints: BoxConstraints(maxWidth: 50),
            border: InputBorder.none,
            filled: true,
            fillColor: Color.fromARGB(255, 55, 59, 65),
            //Color.fromARGB(255, 35, 38, 43)
            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 18),
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color.fromARGB(255, 205, 209, 210),
            //Color.fromARGB(255, 169, 176, 180)
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final Widget children;

  const SettingsCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 26, 27, 29),
            spreadRadius: 0,
            blurRadius: 10,
          )
        ],
        gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Assets.primaryColor, Color.fromARGB(255, 47, 55, 63)]),
      ),
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: children,
    );
  }
}

class ActionInputField extends StatefulWidget {
  const ActionInputField({Key? key}) : super(key: key);

  static final TextEditingController controller =
      TextEditingController(text: "0");

  @override
  State<ActionInputField> createState() => _ActionInputFieldState();
}

class _ActionInputFieldState extends State<ActionInputField> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 60,
        height: 30,
        child: TextField(
          inputFormatters: [LengthLimitingTextInputFormatter(5)],
          controller: ActionInputField.controller,
          onSubmitted: (value) {
            Assets.actionTimerValue.value = int.parse(value);
          },
          cursorColor: const Color.fromARGB(255, 169, 176, 180),
          decoration: const InputDecoration(
              constraints: BoxConstraints(maxWidth: 50),
              border: InputBorder.none,
              filled: true,
              fillColor: Color.fromARGB(255, 55, 59, 65),
              //Color.fromARGB(255, 35, 38, 43)
              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 18)),
          maxLines: 1,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color.fromARGB(255, 205, 209, 210),
            //Color.fromARGB(255, 169, 176, 180)
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class Checkboxes extends StatefulWidget {
  const Checkboxes({Key? key}) : super(key: key);

  static int selectedID = -1;

  @override
  State<Checkboxes> createState() => _CheckboxesState();
}

class _CheckboxesState extends State<Checkboxes> {
  List checkBoxes = [
    {"id": 0, "value": false, "title": "Shutdown"},
    {"id": 1, "value": false, "title": "Hibernate"}
  ];

  @override
  void initState() {
    super.initState();
    if (Assets.lastSelectedAction != -1) {
      checkBoxes[Assets.lastSelectedAction]["value"] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          checkBoxes.length,
          (index) => SizedBox(
            width: 150,
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Checkbox(
                        value: checkBoxes[index]["value"],
                        activeColor: Colors.blueGrey[700],
                        side: const BorderSide(
                            color: Color.fromARGB(255, 232, 229, 229),
                            width: 1.0),
                        onChanged: (value) {
                          setState(() {
                            for (var element in checkBoxes) {
                              element["value"] = false;
                            }
                          });
                          if (value!) {
                            Checkboxes.selectedID = index;
                            Assets.lastSelectedAction = index;
                          } else {
                            Checkboxes.selectedID = -1;
                          }
                          checkBoxes[index]["value"] = value;
                          ActionInputField.controller.text = "0";
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1.009),
                  child: Text(
                    checkBoxes[index]["title"],
                    style: GoogleFonts.inter(
                        color: const Color.fromARGB(255, 232, 229, 229),
                        fontWeight: FontWeight.w200,
                        fontSize: 13,
                        decoration: TextDecoration.none),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
