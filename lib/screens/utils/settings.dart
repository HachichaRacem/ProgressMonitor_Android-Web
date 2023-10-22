import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controller.dart';

class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);

  final Controller controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 25.0),
          child: Text('Settings'),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          decoration: BoxDecoration(
              color: const Color(0xFF2b2d31),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Shutdown"),
                  Obx(
                    () => Switch(
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[900],
                      activeTrackColor: Colors.white60,
                      onChanged: (value) {
                        if (controller.connected.value) {
                          if (!controller.hibernate.value) {
                            if ((controller.textEditingController.text == '0' ||
                                    controller
                                        .textEditingController.text.isEmpty) &&
                                !controller.shutdown.value) {
                              Get.showSnackbar(GetSnackBar(
                                dismissDirection: DismissDirection.down,
                                isDismissible: true,
                                duration: const Duration(seconds: 2),
                                messageText: Center(
                                  child: Text(
                                    "You need to fill the timer first.",
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ));
                            } else {
                              controller.shutdown.value = value;
                              if (value) {
                                controller.sendUrgentAction(0);
                              }
                            }
                          }
                        }
                      },
                      value: controller.shutdown.value,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("Hibernate"),
                  Obx(
                    () => Switch(
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[900],
                      activeTrackColor: Colors.white60,
                      onChanged: (value) {
                        if (controller.connected.value) {
                          if (!controller.shutdown.value) {
                            if ((controller.textEditingController.text == '0' ||
                                    controller
                                        .textEditingController.text.isEmpty) &&
                                !controller.hibernate.value) {
                              Get.showSnackbar(GetSnackBar(
                                dismissDirection: DismissDirection.down,
                                isDismissible: true,
                                duration: const Duration(seconds: 2),
                                messageText: Center(
                                  child: Text(
                                    "You need to fill the timer first.",
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                              ));
                            } else {
                              controller.hibernate.value = value;
                              if (value) {
                                controller.sendUrgentAction(1);
                              }
                            }
                          }
                        }
                      },
                      value: controller.hibernate.value,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 35,
                    child: TextFormField(
                      focusNode: controller.textInputFocusNode,
                      onTapOutside: (event) =>
                          controller.textInputFocusNode.unfocus(),
                      controller: controller.textEditingController,
                      cursorColor: const Color.fromARGB(255, 169, 169, 169),
                      maxLength: 5,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      enableSuggestions: false,
                      onTap: () {
                        if (controller.textEditingController.text == '0') {
                          controller.textEditingController.text = '';
                        }
                      },
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 12),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "seconds",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300, fontSize: 10),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
