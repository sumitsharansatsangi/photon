import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photon/components/constants.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/file_services.dart';
import 'package:photon/views/drawer/edit_profile.dart';
import 'package:refreshed/refreshed.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _future() async {
    return await FileMethods.getSaveDirectory();
  }

  @override
  Widget build(BuildContext context) {
    final photonController = Get.putOrFind(() => PhotonController());
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: photonController.isDarkTheme.value
              ? null
              : const DecoratedBox(decoration: appBarGradient),
        ),
        body: FutureBuilder(
          future: _future(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done) {
              return Center(
                child: Container(
                  color: w > 720
                      ? photonController.isDarkTheme.value
                          ? Colors.grey.shade900
                          : null
                      : null,
                  width: w > 720 ? w / 1.4 : w,
                  child: Center(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text("Save path"),
                          subtitle: Text(snap.data.toString()),
                          trailing: IconButton(
                            onPressed: () async {
                              var resp =
                                  await FilePicker.platform.getDirectoryPath();
                              if (mounted) {
                                setState(() {
                                  if (resp != null) {
                                    FileMethods.editDirectoryPath(resp);
                                  }
                                });
                              }
                            },
                            icon: Icon(
                              Icons.edit_rounded,
                              size: w > 720 ? 38 : 24,
                              semanticLabel: 'Edit path',
                            ),
                          ),
                        ),
                        ListTile(
                          title: const Text('Toggle theme'),
                          trailing: Switch(
                            value: photonController.isDarkTheme.value,
                            onChanged: (val) {
                              if (photonController.isDarkTheme.value) {
                                Get.changeTheme(ThemeData.dark());
                                photonController.box.put('isDarkTheme', true);
                                photonController.isDarkTheme.value = true;
                              } else {
                                Get.changeTheme(ThemeData.light());
                                photonController.box.put('isDarkTheme', false);
                                photonController.isDarkTheme.value = false;
                              }
                            },
                          ),
                        ),
                        ListTile(
                          trailing: IconButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const EditProfilePage();
                              }));
                            },
                            icon: SvgPicture.asset(
                              'assets/icons/profile_edit.svg',
                              colorFilter: ColorFilter.mode(
                                  photonController.isDarkTheme.value
                                      ? Colors.white
                                      : Colors.black,
                                  BlendMode.srcIn),
                            ),
                          ),
                          title: const Text('Edit profile'),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
