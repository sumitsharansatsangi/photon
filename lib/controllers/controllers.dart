import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:refreshed/refreshed.dart';

enum Status { waiting, downloaded, cancelled, downloading, error }

class PhotonController extends GetxController {
  RxList percentage = [].obs;
  RxList isCancelled = [].obs;
  RxList isReceived = [].obs;
  final speed = 0.0.obs;
  final minSpeed = 0.0.obs;
  final maxSpeed = 0.0.obs;
  final estimatedTime = ''.obs;
  final totalTimeElapsed = 0.obs;
  RxList fileStatus = [].obs;
  final isFinished = false.obs;
  List<CancelToken> cancelTokenList = [];
  final receiverMap = {}.obs;
  final rawText = "".obs;
  Box box = Hive.box(name: 'appData');
  final isDarkTheme = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkTheme.value = box.get("isDarkTheme");
  }
}
