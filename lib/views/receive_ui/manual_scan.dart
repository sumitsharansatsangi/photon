import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/controllers/controllers.dart';
// import 'package:photon/components/components.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/file_services.dart';
import 'package:photon/views/receive_ui/progress_page.dart';
import 'package:refreshed/refreshed.dart';
// import 'package:unicons/unicons.dart';
import '../../components/constants.dart';
import '../../controllers/intents.dart';
import '../../services/photon_receiver.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  late Directory dir;

  Future<List<SenderModel>> _scan() async {
    dir = await FileMethods.getSaveDirectory();
    try {
      List<SenderModel> resp = await PhotonReceiver.scan();
      return resp;
    } catch (_) {}
    return [];
  }

  //to keep copy of stateful builder context
  //otherwise it will throw error
  late StateSetter sts;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isRequestSent = false;
    final photonController = Get.putOrFind(() => PhotonController());
    return Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.backspace): GoBackIntent()
        },
        child: Actions(
            actions: {
              GoBackIntent: CallbackAction<GoBackIntent>(onInvoke: (intent) {
                Navigator.of(context).pop();
                return null;
              })
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Scan'),
                leading: BackButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                flexibleSpace: photonController.isDarkTheme.value
                    ? null
                    : const DecoratedBox(
                        decoration: appBarGradient,
                      ),
              ),
              body: FutureBuilder(
                future: _scan(),
                builder: (context, AsyncSnapshot snap) {
                  if (snap.connectionState == ConnectionState.done) {
                    List<SenderModel> senderModels =
                        snap.data as List<SenderModel>;
                    return StatefulBuilder(builder: (context, StateSetter c) {
                      sts = c;
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: snap.data.length == 0
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (snap.data.length == 0) ...{
                                Lottie.asset(
                                  'assets/lottie/sender_not_found.json',
                                  width: 200,
                                  height: 200,
                                ),
                                Center(
                                  child: Focus(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Card(
                                          child: SizedBox(
                                            width: width > 720
                                                ? width / 2.4
                                                : width - 20,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.5,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Center(
                                                child: Text(
                                                  getErrorString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                720
                                                            ? 20
                                                            : 16,
                                                  ),
                                                  textAlign: TextAlign.justify,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      semanticLabel: 'Re-scan',
                                      size: 80,
                                    ),
                                    label: Text(
                                      'Re-Scan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    720
                                                ? 20
                                                : 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              } else if (isRequestSent) ...{
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2 -
                                          80,
                                ),
                                Center(
                                  child: Focus(
                                    child: Text(
                                      'Waiting for sender to approve,ask sender to approve !',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width >
                                                    720
                                                ? 18
                                                : 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  child: SizedBox(
                                      child: Text(
                                    '(Files will be saved at $dir)',
                                    textAlign: TextAlign.center,
                                  )),
                                )
                              } else ...{
                                const SizedBox(
                                  height: 28,
                                ),
                                const Center(
                                  child: Focus(
                                    child: Text(
                                        "Please select the 'sender' from the list"),
                                  ),
                                ),
                                ListView.builder(
                                  padding: width > 720
                                      ? const EdgeInsets.only(
                                          left: 120, right: 120)
                                      : const EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  itemCount: snap.data.length,
                                  itemBuilder: (c, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        clipBehavior: Clip.antiAlias,
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          elevation: 5,
                                          color:
                                              photonController.isDarkTheme.value
                                                  ? const Color.fromARGB(
                                                      255, 5, 6, 6)
                                                  : null,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              //only rebuild the column
                                              sts(() {
                                                isRequestSent = true;
                                              });

                                              final resp = await PhotonReceiver
                                                  .isRequestAccepted(
                                                snap.data[index] as SenderModel,
                                              );

                                              if (resp['accepted']) {
                                                if (context.mounted) {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return ProgressPage(
                                                          senderModel: snap
                                                                  .data[index]
                                                              as SenderModel,
                                                          secretCode:
                                                              resp['code'],
                                                          dataType:
                                                              resp['type'] ??
                                                                  "file",
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              } else {
                                                sts(() {
                                                  isRequestSent = false;
                                                });
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(const SnackBar(
                                                          content: Text(
                                                              'Access denied by the sender')));
                                                }
                                              }
                                            },
                                            child: Center(
                                              child: SizedBox(
                                                height: width > 720 ? 200 : 128,
                                                width: width > 720
                                                    ? width / 2
                                                    : width / 1.25,
                                                child: Center(
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: senderModels[
                                                                            index]
                                                                        .avatar !=
                                                                    null
                                                                ? Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Image.memory(
                                                                        senderModels[index]
                                                                            .avatar!),
                                                                  )
                                                                : Image.asset(
                                                                    'assets/avatars/1.png',
                                                                    height: 80,
                                                                  )),
                                                        Expanded(
                                                          flex: width > 720
                                                              ? 1
                                                              : 2,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: RichText(
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        '${senderModels[index].host}\n',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '${senderModels[index].ip} ◉\n',
                                                                  ),
                                                                  TextSpan(
                                                                      text:
                                                                          '${senderModels[index].os}\n'),
                                                                  if (senderModels[
                                                                              index]
                                                                          .type ==
                                                                      "raw_text") ...{
                                                                    const TextSpan(
                                                                      text:
                                                                          'Raw text',
                                                                    ),
                                                                  } else ...{
                                                                    TextSpan(
                                                                      text:
                                                                          '${senderModels[index].filesCount} file(s)',
                                                                    ),
                                                                  }
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              }
                            ],
                          ),
                        ),
                      );
                    });
                  } else {
                    return Center(
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Lottie.asset(
                                  'assets/lottie/searching.json',
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            )));
  }
}
