import 'package:flutter/material.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:photon/methods/methods.dart';
import '../components/snackbar.dart';
import '../views/receive_ui/qr_scan.dart';

class HandleShare {
  BuildContext context;
  HandleShare({required this.context});
  onNormalScanTap() async {
    getIP().then((value) async {
      if (value.isNotEmpty && context.mounted) {
        Navigator.of(context).pushNamed('/receivepage');
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
          showSnackBar(context,
              'Please connect to wifi / hotspot same as that of sender');
          await Future.delayed(
            const Duration(seconds: 2),
          );
          const OpenSettingsPlusAndroid().wifi();
        }
      }
    });
  }

  onQrScanTap() {
    getIP().then((value) async {
      if (value.isNotEmpty) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const QRScanScreen(),
            ),
          );
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
          showSnackBar(context,
              'Please connect to wifi / hotspot same as that of sender');
          await Future.delayed(
            const Duration(seconds: 2),
          );
          const OpenSettingsPlusAndroid().wifi();
        }
      }
    });
  }
}
