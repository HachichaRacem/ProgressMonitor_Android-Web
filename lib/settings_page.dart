import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_monitor/assets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late final AnimationController fadeInController;
  late final AnimationController slideInController;

  late final Animation<double> fadeInAnimation;
  late final Animation<Offset> slideInAnimation;

  @override
  void initState() {
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
        Tween<Offset>(begin: const Offset(0.1, 0.0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: slideInController,
                curve: Curves.fastLinearToSlowEaseIn));

    fadeInController.forward();
    slideInController.forward();
    super.initState();
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
              SettingsCard(
                children: Row(
                  children: [
                    Text("Capture every", style: Assets.settingsCardFont),
                    const Spacer(),
                    const InputField()
                  ],
                ),
              ),
              SettingsCard(
                children: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Actions', style: Assets.generalFont),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Checkboxes(),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 13.0),
                        child: Text("after",
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w200,
                                decoration: TextDecoration.none)),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 16.0),
                        child: ActionInputField(),
                      ),
                      Text("seconds",
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w200,
                              decoration: TextDecoration.none)),
                    ])
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
