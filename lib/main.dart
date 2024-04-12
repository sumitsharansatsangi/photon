import 'dart:io';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photon/methods/share_intent.dart';
import 'package:photon/views/apps_list.dart';
import 'package:photon/views/handle_intent_ui.dart';
import 'package:photon/views/drawer/history.dart';
import 'package:photon/views/intro_page.dart';
import 'package:photon/views/receive_ui/manual_scan.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:refreshed/refreshed.dart';
import 'app.dart';

import 'views/share_ui/share_page.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

final nav = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;
  Box box = Hive.box(name: 'appData');
  box.get('avatarPath') ?? box.put('avatarPath', 'assets/avatars/1.png');
  box.get('username') ?? box.put('username', '${Platform.localHostname} user');
  box.get('queryPackages') ?? box.put('queryPackages', false);
  box.get('isIntroRead') ?? box.put('isIntroRead', false);
  box.get('isDarkTheme') ?? box.put('isDarkTheme', true);
  final photonController = Get.put<PhotonController>(PhotonController());
  bool externalIntent = false;
  String type = "";
  if (Platform.isAndroid) {
    (externalIntent, type) = await handleSharingIntent();
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
    navigatorKey: nav,
    debugShowCheckedModeBanner: false,
    themeMode:
        photonController.isDarkTheme.value ? ThemeMode.dark : ThemeMode.light,
    theme: FlexThemeData.light(
        scheme: FlexScheme.deepPurple,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        appBarOpacity: 0.95,
        scaffoldBackground: Colors.white,
        swapColors: true,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
        ),
        background: Colors.white,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: 'questrial'),
    darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.hippieBlue,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.background,
        appBarOpacity: 0.90,
        appBarBackground: Colors.blueGrey.shade900,
        scaffoldBackground: const Color.fromARGB(255, 27, 32, 35),
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: 'questrial'),
    initialRoute: '/',    
    routes: {
      '/': (context) => AnimatedSplashScreen(
            splash: 'assets/images/splash.png',
            nextScreen: box.get('isIntroRead') == true
                ? (externalIntent
                    ? HandleIntentUI(
                        isRawText: type == "raw_text",
                      )
                    : const App())
                : const IntroPage(),
            duration: 1000,
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.fade,
            backgroundColor: const Color.fromARGB(255, 0, 4, 7),
          ),
      '/home': (context) => const App(),
      '/sharepage': (context) => const SharePage(),
      '/receivepage': (context) => const ReceivePage(),
      '/history': (context) => const HistoryPage(),
      '/apps': ((context) => const AppsList()),
    },
  ));
}
