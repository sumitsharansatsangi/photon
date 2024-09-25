import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/views/receive_ui/progress_page.dart';
import 'package:refreshed/refreshed.dart';
import '../../components/constants.dart';
import '../../services/photon_receiver.dart';

class QrReceivePage extends StatefulWidget {
  const QrReceivePage({
    super.key,
  });

  @override
  State<QrReceivePage> createState() => _QrReceivePageState();
}

class _QrReceivePageState extends State<QrReceivePage> {
  final scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  Future<String?> _scan() async {
    await Permission.camera.request();
    String? resp;
    if (mounted && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AiBarcodeScanner(
            onDispose: () {
              debugPrint("Barcode scanner disposed!");
            },
            hideGalleryButton: false,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (BarcodeCapture capture) {
              resp = capture.barcodes.first.rawValue;
              debugPrint("Barcode scanned: $resp");
              Navigator.pop(context);
            },
          ),
        ),
      );
    }
    return resp;
  }

  bool isDenied = false;
  bool hasErr = false;
  late StateSetter innerState;
  @override
  Widget build(BuildContext context) {
    final photonController = Get.putOrFind(() => PhotonController());
    return Scaffold(
        appBar: AppBar(
          title: const Text(" QR - receive"),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
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
              handleQrReceive(snap.data);
              return StatefulBuilder(
                builder: (BuildContext context, sts) {
                  innerState = sts;
                  return hasErr
                      ? const Center(
                          child: Text(
                            'Wrong QR code or \n Devices are not connected to same network',
                            textAlign: TextAlign.justify,
                          ),
                        )
                      : isDenied
                          ? const Center(
                              child: Text('Sender denied,please retry'),
                            )
                          : const Center(
                              child: Text("Waiting for sender to approve"),
                            );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: photonController.isDarkTheme.value
              ? Colors.blueGrey.shade900
              : null,
          onPressed: () async {
            setState(() {
              hasErr = isDenied = false;
            });
          },
          label: const Text('Retry'),
          icon: const Icon(
            Icons.refresh,
            color: Color.fromARGB(255, 75, 231, 81),
          ),
        ));
  }

  handleQrReceive(link) async {
    try {
      String host = Uri.parse(link).host;
      int port = Uri.parse(link).port;
      SenderModel senderModel =
          await PhotonReceiver.isPhotonServer(host, port.toString());

      final resp = await PhotonReceiver.isRequestAccepted(
        senderModel,
      );
      if (resp['accepted']) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ProgressPage(
                  senderModel: senderModel,
                  secretCode: resp['code'],
                  dataType: resp['type'],
                );
              },
            ),
          );
        }
      } else {
        if (context.mounted) {
          innerState(() {
            isDenied = true;
          });
        }
      }
    } catch (_) {
      hasErr = true;
    }
  }
}
