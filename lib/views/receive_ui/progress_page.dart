import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refreshed/refreshed.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photon/components/snackbar.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/constants.dart';
import '../../components/dashboard.dart';
import '../../components/dialogs.dart';
import '../../components/progress_line.dart';
import '../../methods/methods.dart';
import '../../models/sender_model.dart';
import '../../services/file_services.dart';

class ProgressPage extends StatefulWidget {
  final SenderModel? senderModel;
  final int secretCode;
  final String dataType;
  const ProgressPage({
    super.key,
    required this.senderModel,
    required this.secretCode,
    required this.dataType,
  });

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  StopWatchTimer stopWatchTimer = StopWatchTimer();
  bool willPop = false;
  bool isDownloaded = false;
  bool isLoading = false;
  TextEditingController fileNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    generatePercentageList(widget.senderModel!.filesCount);
    PhotonReceiver.receive(
        widget.senderModel!, widget.secretCode, widget.dataType);
    stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photonController = Get.putOrFind(() => PhotonController());
    var width = MediaQuery.of(context).size.width > 720
        ? MediaQuery.of(context).size.width / 1.8
        : MediaQuery.of(context).size.width / 1.4;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(
              widget.dataType == "raw_text"
                  ? photonController.rawText.value == ""
                      ? "Receiving"
                      : "Received"
                  : photonController.isFinished.value
                      ? "Received"
                      : ' Receiving',
            ),
          ),
          flexibleSpace: photonController.isDarkTheme.value
              ? null
              : const DecoratedBox(
                  decoration: appBarGradient,
                ),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              progressPageAlertDialog(context);
            },
          ),
        ),
        body: widget.dataType == "raw_text"
            ? Center(
                child: Obx(
                  () {
                    return photonController.rawText.value == ""
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: MediaQuery.of(context).size.width / 1.2,
                            height: MediaQuery.of(context).size.height / 1.4,
                            child: Center(
                              child: Flex(
                                direction: width > 720
                                    ? Axis.horizontal
                                    : Axis.vertical,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: 480,
                                      height: 480,
                                      child: Lottie.asset(
                                        'assets/lottie/text_received.json',
                                        width: 480,
                                        height: 480,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: width > 720 ? 1 : 2,
                                    child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Card(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    photonController
                                                        .rawText.value,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          width > 720 ? 15 : 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: photonController
                                                            .isDarkTheme.value
                                                        ? const Color.fromARGB(
                                                            255, 46, 46, 46)
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: IconButton(
                                                  color: const Color.fromARGB(
                                                      255, 61, 255, 155),
                                                  onPressed: () async {
                                                    await Clipboard.setData(
                                                        ClipboardData(
                                                            text:
                                                                photonController
                                                                    .rawText
                                                                    .value));
                                                    if (mounted &&
                                                        context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              "Copied to clipboard"),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                      Icons.copy_all_rounded),
                                                ),
                                              ),
                                            ),
                                            const Positioned(
                                              top: 10,
                                              child: Text(
                                                "Your text is here",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            ),
                          );
                  },
                ),
              )
            : FutureBuilder(
                future: FileMethods.getFileNames(widget.senderModel!),
                builder: (context, AsyncSnapshot snap) {
                  if (snap.connectionState == ConnectionState.done) {
                    return SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      child: Column(
                        children: [
                          Dashboard(
                            width: width,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snap.data.length,
                            itemBuilder: (context, item) {
                              return Focus(
                                child: Obx(
                                  () {
                                    double progressLineWidth = ((width - 80) *
                                        (photonController.percentage[item]
                                                as RxDouble)
                                            .value /
                                        100);

                                    return UnconstrainedBox(
                                        child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          openFile(snap.data[item],
                                              widget.senderModel!);
                                        },
                                        child: Card(
                                          // color: Colors.blue.shade100,
                                          elevation: 2,
                                          clipBehavior: Clip.antiAlias,
                                          child: SizedBox(
                                            width: width + 60,
                                            height: 100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                getFileIcon(snap.data[item]
                                                    .toString()
                                                    .split('.')
                                                    .last),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              top: 8.0),
                                                      child: SizedBox(
                                                        width: width / 1.4,
                                                        child: Text(
                                                          snap.data![item],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: width - 80,
                                                      child: CustomPaint(
                                                        painter: ProgressLine(
                                                          pos:
                                                              progressLineWidth,
                                                        ),
                                                        child: Container(),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 40,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 2.5),
                                                            child: getStatusWidget(
                                                                photonController
                                                                        .fileStatus[
                                                                    item],
                                                                item),
                                                          ),
                                                          if (photonController
                                                                  .fileStatus[
                                                                      item]
                                                                  .value ==
                                                              "downloading") ...{
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                              child: SizedBox(
                                                                width:
                                                                    width / 1.8,
                                                                child: Text(
                                                                  photonController
                                                                      .estimatedTime
                                                                      .value,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: MediaQuery.of(context).size.width >
                                                                            720
                                                                        ? 16
                                                                        : 12.5,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          }
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                if (photonController
                                                    .isCancelled[item]
                                                    .value) ...{
                                                  IconButton(
                                                    icon: const Padding(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      child: Icon(
                                                        Icons.refresh,
                                                        semanticLabel:
                                                            'Restart',
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      //restart download
                                                      photonController
                                                          .isCancelled[item]
                                                          .value = false;
                                                      PhotonReceiver.getFile(
                                                        snap.data[item],
                                                        item,
                                                        widget.senderModel!,
                                                      );
                                                    },
                                                  )
                                                } else if (!photonController
                                                    .isReceived[item]
                                                    .value) ...{
                                                  IconButton(
                                                    icon: const Padding(
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      child: Icon(
                                                        Icons.cancel,
                                                        semanticLabel:
                                                            'Cancel receive',
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      photonController
                                                          .isCancelled[item]
                                                          .value = true;
                                                      photonController
                                                          .cancelTokenList[item]
                                                          .cancel();
                                                    },
                                                  )
                                                } else ...{
                                                  const Padding(
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      child: Icon(
                                                          Icons.done_rounded))
                                                },
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ));
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  } else if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Card(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: const Text('Something went wrong'),
                        ),
                      ),
                    );
                  }
                },
              ),
        floatingActionButton: widget.dataType == "raw_text"
            ? FloatingActionButton.extended(
                label: const Text('Export',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Enter file name to save"),
                        content: TextField(
                          controller: fileNameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await FileMethods.saveTextFile(
                                  photonController.rawText.value,
                                  fileNameController.text);
                              if (mounted && context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "File is saved as ${await FileMethods.getTextFilePath(fileNameController.text)}")));
                              }
                            },
                            child: const Text(
                              "Save",
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.black,
                ),
                backgroundColor: photonController.isDarkTheme.value
                    ? const Color.fromARGB(230, 80, 255, 124)
                    : Colors.blue,
              )
            : null,
      ),
      onWillPop: () async {
        willPop = await progressPageWillPopDialog(context);
        return willPop;
      },
    );
  }

  openFile(String filepath, SenderModel senderModel) async {
    String path = (await FileMethods.getSavePath(filepath, senderModel))
        .replaceAll(r'\', '/');
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        OpenFilex.open(path);
      } catch (_) {
        // ignore: use_build_context_synchronously
        showSnackBar(context, 'No corresponding app found');
      }
    } else {
      try {
        launchUrl(
          Uri.parse(
            path,
          ),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open the file')));
      }
    }
  }
}
