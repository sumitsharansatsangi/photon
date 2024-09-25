import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:photon/methods/methods.dart';
import 'package:photon/models/sender_model.dart';
import 'package:photon/services/file_services.dart';
import 'package:refreshed/instance_manager.dart';
import '../controllers/controllers.dart';
// import 'package:http/http.dart' as http;

class PhotonReceiver {
  static late int _secretCode;
  static late Map<String, dynamic> filePathMap;
  static final Box _box = Hive.box(name: 'appData');
  static late int id;
  static int totalTime = 0;

  ///to get network address [assumes class C address]
  static List<String> getNetAddress(List<String> ipList) {
    Set<String> netAdd = {};
    for (String ip in ipList) {
      final ipToList = ip.split('.');
      ipToList.removeLast();
      netAdd.add(ipToList.join('.'));
    }
    return netAdd.toList();
  }

  ///tries to establish socket connection
  static Future<Map<String, dynamic>> _connect(String host, int port) async {
    if (host != '192.168.1.1') {
      try {
        final socket = await Socket.connect(host, port)
            .timeout(const Duration(milliseconds: 2500));
        socket.destroy();
        return {"host": host, 'port': port};
      } catch (_) {
        return {};
      }
    } else {
      return {};
    }
  }

  ///check if ip & port pair represent photon-server
  static isPhotonServer(String ip, String port) async {
    final dio = Dio();
    try {
      final resp = await dio.get('http://$ip:$port/photon-server');
      Map<String, dynamic> senderInfo = jsonDecode(resp.data);
      return SenderModel.fromJson(senderInfo);
    } catch (_) {
      return null;
    }
  }

  ///scan presence of photon-server[driver func]
  static Future<List<SenderModel>> scan() async {
    List<Future<Map<String, dynamic>>> list = [];
    List<SenderModel> photonServers = [];
    List<String> netAddresses = getNetAddress(await getIP());
    for (int i = 1; i < 255; i++) {
      //scan all of the wireless interfaces available
      for (String netAddress in netAddresses) {
        Future<Map<String, dynamic>> res = _connect('$netAddress.$i', 4040);
        list.add(res);
      }
    }

    for (final ele in list) {
      Map<String, dynamic> item = await ele;
      if (item.containsKey('host')) {
        Future<dynamic> resp;
        if ((resp = (isPhotonServer(
                item['host'].toString(), item['port'].toString()))) !=
            null) {
          photonServers.add(await resp);
        }
      }
    }
    list.clear();
    return photonServers;
  }

  static isRequestAccepted(SenderModel senderModel) async {
    String username = _box.get('username');
    final avatar = await rootBundle.load(_box.get('avatarPath'));
    final resp = await Dio().getUri(
        Uri.parse('http://${senderModel.ip}:${senderModel.port}/get-code'),
        options: Options(headers: {
          'receiver-name': username,
          'os': Platform.operatingSystem,
          'avatar': avatar.buffer.asUint8List().toString()
        }));
    id = Random().nextInt(10000);
    final senderRespData = jsonDecode(resp.data);
    return senderRespData;
  }

  static sendBackReceiverRealtimeData(SenderModel senderModel,
      {fileIndex = -1, isCompleted = true}) {
    Dio().postUri(Uri.parse('http://${senderModel.ip}:4040/receiver-data'),
        options: Options(
          headers: {
            "receiverID": id.toString(),
            "os": Platform.operatingSystem,
            "hostName": _box.get('username'),
            "currentFile": '${fileIndex + 1}',
            "isCompleted": '$isCompleted',
          },
        ));
  }

  static receiveText(SenderModel senderModel, int secretCode) async {
    final photonController = Get.putOrFind(() => PhotonController());
    final resp =
        await Dio().get("http://${senderModel.ip}:4040/$secretCode/text");
    String text = jsonDecode(resp.data)['raw_text'];
    photonController.rawText.value = text;
  }

  static receiveFiles(SenderModel senderModel, int secretCode) async {
    final photonController = Get.putOrFind(() => PhotonController());
    String filePath = '';
    totalTime = 0;
    try {
      final resp = await Dio()
          .get('http://${senderModel.ip}:${senderModel.port}/getpaths');
      filePathMap = jsonDecode(resp.data);
      _secretCode = secretCode;

      for (int fileIndex = 0;
          fileIndex < filePathMap['paths']!.length;
          fileIndex++) {
        //if a file is cancelled once ,it should not be automatically fetched without user action
        if (photonController.isCancelled[fileIndex].value == false) {
          photonController.fileStatus[fileIndex].value =
              Status.downloading.name;
          if (filePathMap.containsKey('isApk')) {
            if (filePathMap['isApk']) {
              // when sender sends apk files
              // this case is not true when sender sends apk from generic file selection
              filePath =
                  '${filePathMap['paths'][fileIndex].toString().split("/")[4].split("-").first}.apk';
            } else {
              filePath = filePathMap['paths'][fileIndex];
            }
          } else {
            filePath = filePathMap['paths'][fileIndex];
          }

          await getFile(filePath, fileIndex, senderModel);
        }
      }
      // sends after last file is sent

      sendBackReceiverRealtimeData(senderModel);
      photonController.isFinished.value = true;
      photonController.totalTimeElapsed.value = totalTime;
    } catch (e) {
      debugPrint('$e');
    }
  }

  static receive(SenderModel senderModel, int secretCode, String type) async {
    if (type == "raw_text") {
      receiveText(senderModel, secretCode);
    } else {
      receiveFiles(senderModel, secretCode);
    }
  }

  static getFile(
    String filePath,
    int fileIndex,
    SenderModel senderModel,
  ) async {
    final dio = Dio();
    final percentageController = Get.putOrFind(() => PhotonController());
    //creates instance of cancelToken and inserts it to list
    percentageController.cancelTokenList.insert(fileIndex, CancelToken());
    String savePath = await FileMethods.getSavePath(filePath, senderModel);
    Stopwatch stopwatch = Stopwatch();
    int? prevBits;
    int? prevDuration;
    //for handling speed update frequency
    int count = 0;

    try {
      //sends post request every time receiver requests for a file
      sendBackReceiverRealtimeData(senderModel,
          fileIndex: fileIndex, isCompleted: false);
      stopwatch.start();
      percentageController.fileStatus[fileIndex].value = "downloading";
      await dio.download(
        'http://${senderModel.ip}:4040/$_secretCode/$fileIndex',
        savePath,
        deleteOnError: true,
        cancelToken: percentageController.cancelTokenList[fileIndex],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            count++;
            percentageController.percentage[fileIndex].value =
                (double.parse((received / total * 100).toStringAsFixed(0)));
            if (prevBits == null) {
              prevBits = received;
              prevDuration = stopwatch.elapsedMicroseconds;
              percentageController.minSpeed.value = percentageController
                  .maxSpeed.value = ((prevBits! * 8) / prevDuration!);
            } else {
              prevBits = received - prevBits!;
              prevDuration = stopwatch.elapsedMicroseconds - prevDuration!;
            }
          }
          //used for reducing speed update frequency
          if (count % 10 == 0) {
            percentageController.speed.value = (prevBits! * 8) / prevDuration!;
            //calculate min and max speeds
            if (percentageController.speed.value >
                percentageController.maxSpeed.value) {
              percentageController.maxSpeed.value =
                  percentageController.speed.value;
            } else if (percentageController.speed.value <
                percentageController.minSpeed.value) {
              percentageController.minSpeed.value =
                  percentageController.speed.value;
            }

            // update estimated time
            percentageController.estimatedTime.value = getEstimatedTime(
                received * 8, total * 8, percentageController.speed.value);
            //update time elapsed
          }
        },
      );
      totalTime = totalTime + stopwatch.elapsed.inSeconds;
      stopwatch.reset();
      percentageController.speed.value = 0.0;
      //after completion of download mark it as true
      percentageController.isReceived[fileIndex].value = true;
      storeHistory(_box, savePath);
      percentageController.fileStatus[fileIndex].value = "downloaded";
    } on PathNotFoundException catch (e) {
      debugPrint(e.toString());
    } on DioException catch (e) {
      percentageController.speed.value = 0;
      percentageController.fileStatus[fileIndex].value = "cancelled";
      percentageController.isCancelled[fileIndex].value = true;
      debugPrint(e.toString());
      if (!CancelToken.isCancel(e)) {
        debugPrint("Dio error");
      } else {
        debugPrint(e.toString());
      }
    }
  }
}
