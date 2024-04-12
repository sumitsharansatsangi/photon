import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:refreshed/refreshed.dart';

enum Status { waiting, downloaded, cancelled, downloading, error }

class PhotonController extends GetxController {
  var percentage = [].obs;
  var isCancelled = [].obs;
  var isReceived = [].obs;
  var speed = 0.0.obs;
  var minSpeed = 0.0.obs;
  var maxSpeed = 0.0.obs;
  var estimatedTime = ''.obs;
  var totalTimeElapsed = 0.obs;
  var fileStatus = [].obs;
  var isFinished = false.obs;
  List<CancelToken> cancelTokenList = [];
  var receiverMap = {}.obs;
  var rawText = "".obs;
  Box box = Hive.box(name: 'appData');
  var isDarkTheme = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkTheme.value = box.get("isDarkTheme");
  }
}
