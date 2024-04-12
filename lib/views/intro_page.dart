import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:refreshed/refreshed.dart';
// import 'package:photon/components/snackbar.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<bool> selected = List.generate(4, (index) => false);

  TextEditingController usernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final photonController = Get.putOrFind(() => PhotonController());
    return SafeArea(
        child: Scaffold(
            body: IntroductionScreen(
      globalBackgroundColor:
          photonController.isDarkTheme.value ? Colors.black : null,
      pages: getPages(),
      onDone: () async {
        if (usernameController.text.trim() != '') {
          photonController.box.put('username', usernameController.text.trim());
        }
        Navigator.of(context).pushReplacementNamed('/home');
        photonController.box.put('isIntroRead', true);
      },
      showSkipButton: false,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: true,
      back: const Icon(Icons.arrow_back_ios),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: photonController.isDarkTheme.value
            ? const Color(0xFFBDBDBD)
            : Colors.black,
        activeSize: const Size(22.0, 10.0),
        activeShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color:
            photonController.isDarkTheme.value ? Colors.black87 : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    )));
  }

  List<PageViewModel> getPages() {
    List<PageViewModel> pages = [
      PageViewModel(
        titleWidget: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Image.asset(
            'assets/images/icon.png',
            width: 128,
            height: 128,
          ),
        ),
        bodyWidget: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 72.0),
            child: Card(
              child: Container(
                height: 200,
                margin: const EdgeInsets.only(top: 60),
                width: MediaQuery.of(context).size.width / 1.2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_rounded, size: 60),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Welcome to Photon ,\n Transfer files seamlessly across your devices.\n(No internet connection is required)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width > 720
                                  ? 18
                                  : 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      PageViewModel(
        titleWidget: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Lottie.asset('assets/lottie/wifi_intro.json',
                width: 200, height: 200)),
        bodyWidget: Center(
          child: Card(
            child: Container(
              height: 200,
              margin: const EdgeInsets.only(top: 60),
              width: MediaQuery.of(context).size.width / 1.2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Before using make sure that,\nSender and receivers are connected to same wifi router \n OR \n Connected via mobile-hotspot\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 720 ? 18 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      PageViewModel(
        title: 'One last step, Select avatar',
        bodyWidget: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2.2,
                    width: MediaQuery.of(context).size.height / 2.4,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1.2, crossAxisCount: 2),
                      itemBuilder: ((context, index) => Card(
                              child: GestureDetector(
                            onTap: () {
                              final photonController =
                                  Get.putOrFind(() => PhotonController());
                              setState(() {
                                selected.fillRange(0, 4, false);
                                selected[index] = true;
                                photonController.box.put('avatarPath',
                                    'assets/avatars/${index + 1}.png');
                              });
                            },
                            child: Card(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                      'assets/avatars/${index + 1}.png'),
                                  if (selected[index]) ...{
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: SvgPicture.asset(
                                        'assets/icons/right_mark.svg',
                                        colorFilter: const ColorFilter.mode(
                                            Colors.white, BlendMode.srcIn),
                                        width: 30,
                                      ),
                                    )
                                  }
                                ],
                              ),
                            ),
                          ))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                            hintText: 'Set your username here'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      )
    ];
    return pages;
  }
}
