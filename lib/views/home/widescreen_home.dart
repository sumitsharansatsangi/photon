import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/methods/handle_share.dart';
import '../../services/photon_sender.dart';

class WidescreenHome extends StatefulWidget {
  const WidescreenHome({Key? key}) : super(key: key);

  @override
  State<WidescreenHome> createState() => _WidescreenHomeState();
}

class _WidescreenHomeState extends State<WidescreenHome> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isLoading) ...{
                  Card(
                    color: mode.isDark
                        ? const Color.fromARGB(255, 18, 23, 26)
                        : const Color.fromARGB(255, 241, 241, 241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (Platform.isAndroid) {
                          await showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        minWidth:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        color: mode.isDark
                                            ? const Color.fromARGB(
                                                205, 117, 255, 122)
                                            : Colors.blue,
                                        onPressed: () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await PhotonSender.handleSharing(
                                              context);
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Icon(
                                              Icons.file_open,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Files',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    MaterialButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      minWidth:
                                          MediaQuery.of(context).size.width / 2,
                                      color: mode.isDark
                                          ? const Color.fromARGB(
                                              205, 117, 255, 122)
                                          : Colors.blue,
                                      onPressed: () {},
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/android.svg',
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text(
                                            'Apps',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                    ),
                                  ],
                                );
                              });
                        } else {
                          setState(() {
                            isLoading = true;
                            Navigator.of(context).pop();
                          });
                          await PhotonSender.handleSharing(context);
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            'assets/lottie/rocket-send.json',
                            width: size.width / 4,
                            height: size.height / 4,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Share',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width / 10,
                  ),
                  Card(
                    color: mode.isDark
                        ? const Color.fromARGB(255, 18, 23, 26)
                        : const Color.fromARGB(255, 241, 241, 241),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    child: InkWell(
                      onTap: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Center(
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            HandleShare(context: context)
                                                .onNormalScanTap();
                                          },
                                          child: const Text('Normal mode'),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            HandleShare(context: context)
                                                .onQrScanTap();
                                          },
                                          child: const Text('QR Code mode'),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        } else {
                          Navigator.of(context).pushNamed('/receivepage');
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset('assets/lottie/receive-file.json',
                              width: size.width / 4, height: size.height / 4),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Receive',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                } else ...{
                  Center(
                    child: SizedBox(
                      width: size.width / 4,
                      height: size.height / 4,
                      child: Lottie.asset('assets/lottie/setting_up.json',
                          width: 40, height: 40),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Please wait, file(s) are being fetched',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                }
              ],
            ),
          );
        });
  }
}
