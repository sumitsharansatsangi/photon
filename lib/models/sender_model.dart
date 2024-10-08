import 'package:flutter/foundation.dart';

class SenderModel {
  String? ip;
  int? port;
  int? filesCount;
  dynamic host;
  dynamic os;
  dynamic version;
  Uint8List? avatar;
  String? type;
  SenderModel({
    this.ip,
    this.port,
    this.filesCount,
    this.host,
    this.os,
    this.version,
    this.avatar,
    this.type,
  });
  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      ip: json['ip'],
      port: json['port'],
      filesCount: json['files-count'],
      host: json['host'],
      os: json['os'],
      version: json['version'],
      avatar: json.containsKey('avatar')
          ? Uint8List.fromList(
              List<int>.from(json['avatar']),
            )
          : null,
      type: json['type'] ?? 'file',
    );
  }
}
