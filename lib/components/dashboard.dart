import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';
import 'package:lottie/lottie.dart';

import 'package:photon/controllers/controllers.dart';

import '../methods/methods.dart';

class Dashboard extends StatelessWidget {
  final double width;
  const Dashboard({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final PhotonController photonController =
        Get.putOrFind(() => PhotonController());
    return Focus(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Card(
          elevation: photonController.isDarkTheme.value ? 5 : 10,
          color: photonController.isDarkTheme.value
              ? const Color.fromARGB(255, 25, 24, 24)
              : const Color.fromARGB(255, 255, 255, 255),
          child: SizedBox(
            height: 180,
            width: width + 60,
            child: Obx(() {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (photonController.isFinished.isFalse) ...{
                      const Text(
                        "Current speed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 102, 245, 107),
                          ),
                          children: [
                            TextSpan(
                              text: photonController.speed.value
                                  .toStringAsFixed(2),
                            ),
                            const TextSpan(
                              text: ' mbps',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Min ${(photonController.minSpeed.value).toStringAsFixed(2)} mbps",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Max ${(photonController.maxSpeed.value).toStringAsFixed(2)}  mbps",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    } else ...{
                      Expanded(
                        flex: 2,
                        child: Lottie.asset('assets/lottie/fire.json'),
                      ),
                      Expanded(
                          flex: 1,
                          child: Text(
                            'Time taken, ${formatTime(photonController.totalTimeElapsed.value)}',
                          ))
                    }
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
