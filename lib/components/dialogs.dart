import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/db/fastdb.dart';
import 'package:photon/main.dart';
import 'package:url_launcher/url_launcher.dart' as ulaunch;

import '../app.dart';
import '../controllers/controllers.dart';
import '../services/photon_sender.dart';

void privacyPolicyDialog(BuildContext context, String data) async {
  if (context.mounted) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: FastDB.getIsDarkTheme() == true
                ? const Color.fromARGB(255, 27, 32, 35)
                : Colors.white,
            title: const Text('Privacy policy'),
            content: SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.height / 1.2,
                child: Markdown(
                    listItemCrossAxisAlignment:
                        MarkdownListItemCrossAxisAlignment.start,
                    data: data)),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    await ulaunch.launchUrl(Uri.parse(
                        'https://github.com/abhi16180/photon-file-transfer'));
                  },
                  child: const Text('Source-code')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Okay'))
            ],
          );
        });
  }
}

progressPageAlertDialog(BuildContext context) async {
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FastDB.getIsDarkTheme()==true
              ? const Color.fromARGB(255, 27, 32, 35)
              : Colors.white,
          title: const Text('Alert'),
          content: const Text('Make sure that transfer is completed !'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Stay')),
            ElevatedButton(
              onPressed: () async {
                // ignore: use_build_context_synchronously
                GetIt.I.get<PercentageController>().totalTimeElapsed.value = 0;
                GetIt.I.get<PercentageController>().isFinished.value = false;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
              child: const Text('Go back'),
            )
          ],
        );
      },
    );
  }
}

progressPageWillPopDialog(context) async {
  bool willPop = false;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: FastDB.getIsDarkTheme() == true
            ? const Color.fromARGB(255, 27, 32, 35)
            : Colors.white,
        title: const Text('Alert'),
        content: const Text('Make sure that download is completed !'),
        actions: [
          ElevatedButton(
              onPressed: () {
                willPop = false;
                Navigator.of(context).pop();
              },
              child: const Text('Stay')),
          ElevatedButton(
            onPressed: () {
              willPop = true;
              GetIt.I.get<PercentageController>().totalTimeElapsed.value = 0;
              GetIt.I.get<PercentageController>().isFinished.value = false;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (Route<dynamic> route) => false);
            },
            child: const Text('Go back'),
          )
        ],
      );
    },
  );
  return willPop;
}

sharePageAlertDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: FastDB.getIsDarkTheme() == true
            ? const Color.fromARGB(255, 27, 32, 35)
            : Colors.white,
        title: const Text('Server alert'),
        content: const Text('Would you like to terminate the current session'),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay')),
          ElevatedButton(
            onPressed: () async {
              await PhotonSender.closeServer(context);
              GetIt.I.get<ReceiverDataController>().receiverMap.clear();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const App()),
                    (route) => false);
              }
            },
            child: const Text('Terminate'),
          )
        ],
      );
    },
  );
}

sharePageWillPopDialog(context) async {
  bool willPop = false;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: FastDB.getIsDarkTheme() == true
            ? const Color.fromARGB(255, 27, 32, 35)
            : Colors.white,
        title: const Text('Server alert'),
        content:
            const Text('Would you like to terminate the current session ?'),
        actions: [
          ElevatedButton(
              onPressed: () {
                willPop = false;
                Navigator.of(context).pop();
              },
              child: const Text('Stay')),
          ElevatedButton(
            onPressed: () async {
              await PhotonSender.closeServer(context);
              willPop = true;
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Terminate'),
          )
        ],
      );
    },
  );
  return willPop;
}

senderRequestDialog(
  String username,
  String os,
) async {
  bool allowRequest = false;

  await showDialog(
      context: nav.currentContext!,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FastDB.getIsDarkTheme() == true
              ? const Color.fromARGB(255, 27, 32, 35)
              : Colors.white,
          title: const Text('Request from receiver'),
          content: Text(
              "$username ($os) is requesting for files. Would you like to share with them ?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                allowRequest = false;
                Navigator.of(context).pop();
              },
              child: const Text('Deny'),
            ),
            ElevatedButton(
              onPressed: () {
                allowRequest = true;
                Navigator.of(context).pop();
              },
              child: const Text('Accept'),
            )
          ],
        );
      });

  return allowRequest;
}
