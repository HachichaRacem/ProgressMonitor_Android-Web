import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class Screenshot extends StatelessWidget {
  Screenshot({Key? key}) : super(key: key);

  final Controller controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.database.ref().child('images').limitToLast(1).onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final snap = snapshot.data?.snapshot.value as Map<Object?, Object?>?;
          if (snap != null) {
            final data = snap.values.elementAt(0) as Map;
            final link = data['link'];
            return InteractiveViewer(
              child: Image.network(
                link,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) {
                    num total = loadingProgress.expectedTotalBytes as num;
                    final value = loadingProgress.cumulativeBytesLoaded / total;
                    if (value < 1.0) {
                      return SizedBox(
                        height: 25,
                        width: 25,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CircularProgressIndicator(
                            value: value,
                            color: Colors.white24,
                            strokeWidth: 2.0,
                          ),
                        ),
                      );
                    }
                  }
                  return child;
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeIn,
                  child: child,
                ),
                errorBuilder: (context, error, stackTrace) {
                  String output =
                      "Something went wrong while downloading the image";
                  if (error.toString().contains('11001')) {
                    output = "Please verify your connection.";
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_rounded, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          output,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  );
                },
              ),
            );
          } else {
            return const Text("Seems lonely here..");
          }
        } else if (snapshot.hasError) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_rounded, color: Colors.red[400]),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  "Connecting to the database took too long, please verify your connection.",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          );
        } else {
          return const Center(
            child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: Colors.white24,
                strokeWidth: 1.0,
              ),
            ),
          );
        }
      },
    );
  }
}
