import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photon/db/fastdb.dart';
import 'package:photon/methods/share_intent.dart';
import 'package:photon/views/apps_list.dart';
import 'package:photon/views/handle_intent_ui.dart';
import 'package:photon/views/drawer/history.dart';
import 'package:photon/views/intro_page.dart';
import 'package:photon/views/receive_ui/manual_scan.dart';
import 'package:photon/controllers/controllers.dart';
import 'app.dart';

import 'views/share_ui/share_page.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

final nav = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FastDB.init();
  FastDB.getAvatarPath() ?? FastDB.putAvatarPath('assets/avatars/1.png');
  FastDB.getUsername() ?? FastDB.putUsername('${Platform.localHostname} user');
  FastDB.getQueryPackages() ?? FastDB.putQueryPackages(false);
  
  FastDB.getIsIntroRead() ?? FastDB.putIsIntroRead(false);
  FastDB.getIsDarkTheme() ?? FastDB.putIsDarkTheme(true);
  await FastDB.flush();
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<PercentageController>(PercentageController());
  getIt.registerSingleton<ReceiverDataController>(ReceiverDataController());
  getIt.registerSingleton<RawTextController>(RawTextController());
  bool externalIntent = false;
  String type = "";
  if (Platform.isAndroid) {
    (externalIntent, type) = await handleSharingIntent();
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(AdaptiveTheme(
      light: FlexThemeData.light(
          scheme: FlexScheme.deepPurple,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          appBarOpacity: 0.95,
          swapColors: true,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 30,
          ),
          surface: Colors.white,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          fontFamily: 'questrial'),
      dark: FlexThemeData.dark(
          scheme: FlexScheme.hippieBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          appBarStyle: FlexAppBarStyle.background,
          appBarOpacity: 0.90,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 30,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          fontFamily: 'questrial'),
      initial: FastDB.getIsDarkTheme() == true
          ? AdaptiveThemeMode.dark
          : AdaptiveThemeMode.light,
      builder: (theme, dark) {
        return MaterialApp(
          navigatorKey: nav,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: dark,
          routes: {
            '/': (context) => AnimatedSplashScreen(
                  splash: 'assets/images/splash.png',
                  nextScreen: FastDB.getIsIntroRead() == true
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
        );
      }));
}
