import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:photon/components/snackbar.dart';
import 'package:photon/db/fastdb.dart';
import 'package:photon/methods/methods.dart';
// import 'package:photon/models/share_history_model.dart';
import 'package:photon/services/file_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sentHistory = FastDB.getSentHistory() ?? [];
    final receivedHistory = FastDB.getReceivedHistory() ?? [];
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (_, AdaptiveThemeMode mode, __) {
        return Scaffold(
          backgroundColor: mode.isDark
              ? const Color.fromARGB(255, 27, 32, 35)
              : Colors.white,
          appBar: AppBar(
            backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('History'),
                  IconButton(
                      onPressed: () async {
                        var resp = await FileUtils.getSaveDirectory();
                        if (Platform.isAndroid || Platform.isIOS) {
                          OpenFile.open(resp.path);
                        } else {
                          launchUrl(
                            Uri.file(
                              resp.path,
                              windows: Platform.isWindows,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.outbond))
                ]),
            leading: BackButton(
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Tab(
                  text: "Sent history",
                ),
                Tab(
                  text: "Received history",
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              sentHistory.isEmpty
                  ? const Center(
                      child: Text('Sent files history will appear here'),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, i) {
                        return const Divider(
                          color: Color.fromARGB(255, 70, 69, 69),
                        );
                      },
                      itemCount: sentHistory.length,
                      itemBuilder: (context, item) {
                        var extn = sentHistory[item].filePath?.split('.').last;
                        var type = sentHistory[item].type;
                        if (type == "directory") {
                          extn = type;
                        }
                        return ListTile(
                          leading: getFileIcon(extn ?? ""),
                          onTap: () async {
                            String? path = sentHistory[item]
                                .filePath
                                ?.replaceAll(r"\", "/");
                            if (path == null) {
                              showSnackBar(context, 'File not found');
                              return;
                            } else if (Platform.isAndroid || Platform.isIOS) {
                              try {
                                OpenFile.open(path);
                              } catch (_) {
                                // ignore: use_build_context_synchronously
                                showSnackBar(
                                    context, 'No corresponding app found');
                              }
                            } else {
                              try {
                                launchUrl(
                                  Uri.file(
                                    path,
                                    windows: Platform.isWindows,
                                  ),
                                );
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Unable to open the file')));
                              }
                            }
                          },
                          title: Text(
                            basename(sentHistory[item].filePath ?? ''),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(sentHistory[item].date ?? ''),
                        );
                      }),
              receivedHistory.isEmpty
                  ? const Center(
                      child: Text('Received files history will appear here'),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, i) {
                        return const Divider(
                          color: Color.fromARGB(255, 70, 69, 69),
                        );
                      },
                      itemCount: receivedHistory.length,
                      itemBuilder: (context, item) {
                        return ListTile(
                          leading: getFileIcon(
                              receivedHistory[item].filePath?.split('.').last ??
                                  ""),
                          onTap: () async {
                            String path = receivedHistory[item]
                                    .filePath
                                    ?.replaceAll(r"\", "/") ??
                                "";
                            if (Platform.isAndroid || Platform.isIOS) {
                              try {
                                OpenFile.open(path);
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                showSnackBar(
                                    context, 'No corresponding app found');
                              }
                            } else {
                              try {
                                launchUrl(
                                  Uri.file(
                                    path,
                                    windows: Platform.isWindows,
                                  ),
                                );
                              } catch (e) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Unable to open the file')));
                              }
                            }
                          },
                          title: Text(
                            basename(receivedHistory[item].filePath ?? ""),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(receivedHistory[item].date ?? ""),
                          // subtitle: Text(getDateString(data[item].date)),
                        );
                      })
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                tabController.index == 0
                    ? clearSentHistory()
                    : clearReceivedHistory();
              });
              showSnackBar(context,
                  '${tabController.index == 0 ? "Sent" : "Received"} history cleared');
            },
            label: const Text("Clear"),
            icon: const Icon(Icons.clear),
          ),
        );
      },
    );
  }
}
