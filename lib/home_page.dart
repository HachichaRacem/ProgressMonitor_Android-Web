import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'database.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
            child: ConnectionsState(),
          ),
          Expanded(
            child: columnDraw(),
          ),
        ],
      ),
    );
  }

  Widget columnDraw() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: StreamBuilder(
            stream: Database.dbRef?.child('images').onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                DatabaseEvent e = snapshot.data as DatabaseEvent;
                if (e.snapshot.value != null) {
                  return const Screeshot();
                } else {
                  return const Center(
                      child: Text(
                    "It's lonely here..",
                    style: TextStyle(color: Colors.white),
                  ));
                }
              } else if (snapshot.hasError) {
                return const Text(
                  "Error",
                );
              } else {
                return const Center(
                  child: SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
        const Expanded(
          child: Settings(),
        )
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
  getImage() async {
    var task = await Database.storageRef?.child('ss.png').getDownloadURL();
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
            return FutureBuilder(
                future: getImage(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InteractiveViewer(
                        maxScale: 4.5,
                        child: Image.network(snapshot.data.toString()));
                  } else if (snapshot.hasError) {
                    debugPrint(snapshot.error.toString());
                    return const Center(
                        child: Text("getImage ended with an error."));
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.blue));
                  }
                });
          } else {
            return const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
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
  sendActions(int value) async {
    if (CheckBoxes.selectedID != -1) {
      await Database.dbRef?.child('actions').update({'time': value});
      debugPrint('${CheckBoxes.selectedID}');
      switch (CheckBoxes.selectedID) {
        case 0:
          await Database.dbRef?.child('actions/shutdown').set(true);
          break;
        case 1:
          debugPrint('hibernate has been selected');
          await Database.dbRef?.child('actions/hibernate').set(true);
          break;
      }
    }
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
            controller: ActionInputField.controller,
            onSubmitted: (value) {
              sendActions(int.parse(value));
            },
            cursorColor: const Color.fromARGB(255, 169, 176, 180),
            decoration: const InputDecoration(
              constraints: BoxConstraints(maxWidth: 50),
              border: InputBorder.none,
              filled: true,
              fillColor: Color.fromARGB(255, 55, 59, 65),
              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 18),
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class CheckBoxes extends StatefulWidget {
  const CheckBoxes({Key? key}) : super(key: key);

  static int selectedID = -1;

  @override
  State<CheckBoxes> createState() => _CheckBoxesState();
}

class _CheckBoxesState extends State<CheckBoxes> {
  List checkBoxes = [
    {"id": 0, "value": false, "title": "Shutdown"},
    {"id": 1, "value": false, "title": "Hibernate"}
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: rowCheckboxes(),
      ),
    );
  }

  Widget rowCheckboxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
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
                          CheckBoxes.selectedID = index;
                        } else {
                          CheckBoxes.selectedID = -1;
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
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text("Urgent Actions",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          Padding(
              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
              child: CheckBoxes()),
          ActionInputField()
        ],
      ),
    );
  }
}

class ConnectionsState extends StatelessWidget {
  const ConnectionsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Database.isPCConnected,
      builder: (context, value, child) {
        if (value == true) {
          return const Text('PC is connected',
              style: TextStyle(color: Colors.white));
        } else {
          return FutureBuilder(
            future: Database.dbRef?.child('connection').get(),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                DataSnapshot e = snapshot.data as DataSnapshot;
                Map m = Map.from(e.value as Map);
                var date = DateTime.fromMillisecondsSinceEpoch(m['lastSeen']);
                String pcLastSeen =
                    DateFormat('MM/dd/yyyy, hh:mm a').format(date);
                return Text(
                  '''
PC is disconnected, last seen on : $pcLastSeen 
(${m['reason']})''',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textAlign: TextAlign.center,
                );
              } else {
                return const Text('PC is disconnected.',
                    style: TextStyle(color: Colors.white));
              }
            }),
          );
        }
      },
    );
  }
}
