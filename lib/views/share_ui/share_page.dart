import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/components/constants.dart';
import 'package:photon/components/dialogs.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/photon_sender.dart';
import 'package:photon/db/fastdb.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../components/components.dart';

class SharePage extends StatefulWidget {
  final bool? isRawText;
  final bool? isFolder;
  const SharePage({super.key, this.isRawText, this.isFolder});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  SenderModel senderModel = PhotonSender.getServerInfo();
  PhotonSender photonSender = PhotonSender();
  late double width;
  late double height;
  bool willPop = false;
  var receiverDataInst = GetIt.I.get<ReceiverDataController>();
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If already popped, do nothing.

        bool willPop = await sharePageWillPopDialog(context);
        if (willPop) {
          GetIt.I.get<ReceiverDataController>().receiverMap.clear();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: ValueListenableBuilder(
          valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
          builder: (_, AdaptiveThemeMode mode, __) {
            return Scaffold(
                backgroundColor: mode.isDark
                    ? const Color.fromARGB(255, 27, 32, 35)
                    : Colors.white,
                appBar: AppBar(
                  backgroundColor:
                      mode.isDark ? Colors.blueGrey.shade900 : null,
                  title: const Text('Share'),
                  leading: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        sharePageAlertDialog(context);
                      }),
                  flexibleSpace: mode.isLight
                      ? DecoratedBox(
                          decoration: appBarGradient,
                        )
                      : null,
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (width > 720) ...{
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/lottie/share.json',
                                width: 240,
                              ),
                              SizedBox(
                                width: width / 8,
                              ),
                              SizedBox(
                                width: width > 720 ? 200 : 100,
                                height: width > 720 ? 200 : 100,
                                child: QrImageViewWidget(
                                  data: PhotonSender.getPhotonLink,
                                ),
                              )
                            ],
                          )
                        } else ...{
                          Lottie.asset('assets/lottie/share.json', width: 240),
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: QrImageViewWidget(
                              data: PhotonSender.getPhotonLink,
                            ),
                          )
                        },
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FastDB.getEnableHttps() == true
                              ? Text(
                                  "You are using HTTPS. Please make sure receiver also has photon version 3.0.0 or Above\nAsk receiver to tap on receive button",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width > 720 ? 18 : 14,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  widget.isRawText == true
                                      ? "Your text is ready to be shared\nReceiver should be using Photon v2.0 or above in order to receive text"
                                      : '${photonSender.hasMultipleFiles ? 'Your files are ready to be shared' : 'Your file is ready to be shared'}\nAsk receiver to tap on receive button',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width > 720 ? 18 : 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        //receiver data
                        Obx((() => GetIt.I
                                .get<ReceiverDataController>()
                                .receiverMap
                                .isEmpty
                            ? Card(
                                color: mode.isDark
                                    ? const Color.fromARGB(255, 29, 32, 34)
                                    : const Color.fromARGB(255, 241, 241, 241),
                                clipBehavior: Clip.antiAlias,
                                elevation: 8,
                                // color: Platform.isWindows ? Colors.grey.shade300 : null,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                child: SizedBox(
                                  height: width > 720 ? 200 : 128,
                                  width: width > 720 ? width / 2 : width / 1.25,
                                  child: Center(
                                    child: Wrap(
                                      direction: Axis.vertical,
                                      children: infoList(
                                          senderModel,
                                          width,
                                          height,
                                          true,
                                          mode.isDark ? "dark" : "bright"),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: width / 1.2,
                                child: Card(
                                  color: mode.isDark
                                      ? const Color.fromARGB(255, 45, 56, 63)
                                      : const Color.fromARGB(
                                          255, 241, 241, 241),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        receiverDataInst.receiverMap.length,
                                    itemBuilder: (context, item) {
                                      var keys = receiverDataInst
                                          .receiverMap.keys
                                          .toList();

                                      var data = receiverDataInst.receiverMap;

                                      return ListTile(
                                        title: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (item == 0) ...{
                                                const Center(
                                                  child: Text("Sharing status"),
                                                ),
                                              },
                                              const Divider(
                                                thickness: 2.4,
                                                indent: 20,
                                                endIndent: 20,
                                                color: Color.fromARGB(
                                                    255, 109, 228, 113),
                                              ),
                                              Center(
                                                child: Text(
                                                  "Receiver name : ${data[keys[item]]['hostName']}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              data[keys[item]]['isCompleted'] ==
                                                      'true'
                                                  ? Center(
                                                      child: Text(
                                                        widget.isRawText!
                                                            ? 'Text is received'
                                                            : 'All files sent',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Text(
                                                          "Sending '${data[keys[item]]['currentFileName']}' (${data[keys[item]]['currentFileNumber']} out of ${data[keys[item]]['filesCount']} files)"),
                                                    )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ))),
                      ],
                    ),
                  ),
                ));
          }),
    );
  }
}

class QrImageViewWidget extends StatelessWidget {
  final String data;

  const QrImageViewWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      dataModuleStyle: QrDataModuleStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 214, 255, 248)
              : const Color.fromARGB(255, 1, 29, 17)),
      embeddedImageStyle: const QrEmbeddedImageStyle(
          safeArea: true, embeddedImageShape: EmbeddedImageShape.circle),
      size: 180,
      eyeStyle: const QrEyeStyle(color: Color.fromARGB(255, 10, 205, 219)),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color.fromARGB(115, 10, 55, 139)
          : const Color.fromARGB(136, 165, 220, 230),
    );
  }
}
