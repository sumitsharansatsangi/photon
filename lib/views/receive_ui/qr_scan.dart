import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/photon_receiver.dart';
import 'package:photon/views/receive_ui/progress_page.dart';

class QRScanScreen extends StatefulWidget {
  static const qrScanScreen = 'QRScanScreen';

  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController cameraController = MobileScannerController();
  late final ValueNotifier<TorchState> torchState;

  @override
  void initState() {
    super.initState();
    torchState = ValueNotifier<TorchState>(
        cameraController.value.torchState); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.grey);
                  case TorchState.unavailable:
                    return const Icon(Icons.no_flash_rounded,
                        color: Colors.grey);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: MobileScanner(
          controller: cameraController,
          onDetect: (barcodeCapture) {
            String? code = barcodeCapture.barcodes.first.displayValue;
            if (code == null) {
              Navigator.pop(context);
              _showDialog(context, 'Wrong QR code or \n Devices are not connected to same network.');
            } else {
             handleQrReceive(code);
            }
          }),
    );
  }

  void _showDialog(BuildContext context, String message ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
        if (mounted &&context.mounted) {
        _showDialog(context,"Sender denied,please retry");
        }
      }
    } catch (_) {
      if (mounted &&context.mounted) {
      _showDialog(context, "An Error occurred");
    }
    }
  }


}
