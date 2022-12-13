import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';
import 'package:progress_monitor/assets.dart';
import 'package:progress_monitor/home_page.dart';
import 'package:get/get.dart';
import 'package:progress_monitor/settings_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'database.dart';

void main() {
  FirebaseDart.setup();
  runApp(MyApp());
  doWhenWindowReady(() {
    appWindow.size = const Size(1024, 600);
    appWindow.minSize = const Size(800, 600);
    appWindow.title = "Progress Monitor";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Controller c = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Assets.primaryColor,
        body: Column(
          children: [
            WindowTitleBarBox(
              child: Row(children: [
                Expanded(
                    child: Container(
                        color: Assets.titleBarColor, child: MoveWindow())),
                WindowButtons()
              ]),
            ),
            Expanded(
              child: Center(
                child: FutureBuilder(
                  future: Database.init(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == true) {
                        return Obx(() {
                          switch (c.currentIndex.value) {
                            case 0:
                              return const HomePage();
                            case 1:
                              return const SettingsPage();
                            default:
                              return const HomePage();
                          }
                        });
                      } else {
                        return Text(
                            "Couldn't initialize the database properly.",
                            style: Assets.errorFont);
                      }
                    } else {
                      return const CircularProgressIndicator(
                        color: Assets.progressColor,
                        strokeWidth: 2.5,
                      );
                    }
                  },
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: NavBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late FToast fToast;
  final Controller c = Get.put(Controller());

  showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 211, 240, 105),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.info_outline_rounded),
          SizedBox(
            width: 12.0,
          ),
          Text("Stop the upload to access the settings"),
        ],
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 6, top: 3),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10)
          ]),
      width: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          backgroundColor: Assets.primaryColor,
          type: BottomNavigationBarType.shifting,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
                tooltip: "",
                backgroundColor: Assets.primaryColor),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
                tooltip: "",
                backgroundColor: Assets.primaryColor)
          ],
          currentIndex: c.currentIndex.value,
          onTap: (index) {
            if (index == 1 && Assets.isUploading) {
              showToast();
              index = 0;
            }
            setState(() {
              c.currentIndex.value = index;
            });
          },
          selectedItemColor: Colors.white,
          landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
          showUnselectedLabels: false,
          unselectedItemColor: const Color.fromARGB(44, 224, 224, 224),
        ),
      ),
    );
  }
}
