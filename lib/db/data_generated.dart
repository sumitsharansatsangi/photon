// automatically generated by the FlatBuffers compiler, do not modify
// ignore_for_file: unused_import, unused_field, unused_element, unused_local_variable

import 'dart:typed_data' show Uint8List;
import 'flat_buffers.dart' as fb;

class Info {
  Info._(this._bc, this._bcOffset);
  factory Info(List<int> bytes) {
    final rootRef = fb.BufferContext.fromBytes(bytes);
    return reader.read(rootRef, 0);
  }

  static const fb.Reader<Info> reader = _InfoReader();

  final fb.BufferContext _bc;
  final int _bcOffset;

  String? get filePath =>
      const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 4);
  String? get date =>
      const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 6);

  @override
  String toString() {
    return 'Info{filePath: $filePath, date: $date}';
  }
}

class _InfoReader extends fb.TableReader<Info> {
  const _InfoReader();

  @override
  Info createObject(fb.BufferContext bc, int offset) => Info._(bc, offset);
}

class InfoObjectBuilder extends fb.ObjectBuilder {
  final String? _filePath;
  final String? _date;

  InfoObjectBuilder({
    String? filePath,
    String? date,
  })  : _filePath = filePath,
        _date = date;

  /// Finish building, and store into the [fbBuilder].
  @override
  int finish(fb.Builder fbBuilder) {
    final int? filePathOffset =
        _filePath == null ? null : fbBuilder.writeString(_filePath);
    final int? dateOffset = _date == null ? null : fbBuilder.writeString(_date);
    fbBuilder.startTable(2);
    fbBuilder.addOffset(0, filePathOffset);
    fbBuilder.addOffset(1, dateOffset);
    return fbBuilder.endTable();
  }

  /// Convenience method to serialize to byte list.
  @override
  Uint8List toBytes([String? fileIdentifier]) {
    final fbBuilder = fb.Builder(deduplicateTables: false);
    fbBuilder.finish(finish(fbBuilder), fileIdentifier);
    return fbBuilder.buffer;
  }
}

class User {
  User._(this._bc, this._bcOffset);
  factory User(List<int> bytes) {
    final rootRef = fb.BufferContext.fromBytes(bytes);
    return reader.read(rootRef, 0);
  }

  static const fb.Reader<User> reader = _UserReader();

  final fb.BufferContext _bc;
  final int _bcOffset;

  String? get username =>
      const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 4);
  String? get avatarPath =>
      const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 6);
  List<Info>? get sentHistory => const fb.ListReader<Info>(Info.reader)
      .vTableGetNullable(_bc, _bcOffset, 8);
  List<Info>? get fileInfo => const fb.ListReader<Info>(Info.reader)
      .vTableGetNullable(_bc, _bcOffset, 10);
  bool get isIntroRead =>
      const fb.BoolReader().vTableGet(_bc, _bcOffset, 12, false);
  bool get queryPackages =>
      const fb.BoolReader().vTableGet(_bc, _bcOffset, 14, false);
  bool get isDarkTheme =>
      const fb.BoolReader().vTableGet(_bc, _bcOffset, 16, false);
  String? get directoryPath =>
      const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 18);
  bool get enableHttps =>
      const fb.BoolReader().vTableGet(_bc, _bcOffset, 20, false);
  String? get protocol =>
      const fb.StringReader().vTableGetNullable(_bc, _bcOffset, 22);

  @override
  String toString() {
    return 'User{username: $username, avatarPath: $avatarPath,sentHistory: $sentHistory, fileInfo: $fileInfo, isIntroRead: $isIntroRead,queryPackages: $queryPackages, isDarkTheme: $isDarkTheme, directoryPath: $directoryPath, enableHttps: $enableHttps, protocol : $protocol}';
  }
}

class _UserReader extends fb.TableReader<User> {
  const _UserReader();

  @override
  User createObject(fb.BufferContext bc, int offset) => User._(bc, offset);
}

class UserObjectBuilder extends fb.ObjectBuilder {
  String? username;
  String? avatarPath;
  List<InfoObjectBuilder>? sentHistory;
  List<InfoObjectBuilder>? fileInfo;
  bool? isIntroRead;
  bool? queryPackages;
  bool? isDarkTheme;
  String? directoryPath;
  bool? enableHttps;
  String? protocol;

  UserObjectBuilder({
    this.username,
    this.avatarPath,
    this.sentHistory,
    this.fileInfo,
    this.isIntroRead,
    this.queryPackages,
    this.isDarkTheme,
    this.directoryPath,
    this.enableHttps,
    this.protocol,
  });

  /// Finish building, and store into the [fbBuilder].
  @override
  int finish(fb.Builder fbBuilder) {
    final int? usernameOffset =
        username == null ? null : fbBuilder.writeString(username ?? "");
    final int? avatarPathOffset =
        avatarPath == null ? null : fbBuilder.writeString(avatarPath ?? "");
    final int? fileInfoOffset = fileInfo == null
        ? null
        : fbBuilder.writeList(
            fileInfo!.map((b) => b.getOrCreateOffset(fbBuilder)).toList());
    final int? sentHistoryOffset = sentHistory == null
        ? null
        : fbBuilder.writeList(
            sentHistory!.map((b) => b.getOrCreateOffset(fbBuilder)).toList());
    final int? directoryPathOffset =
        directoryPath == null ? null : fbBuilder.writeString(directoryPath!);
    final int? protocolOffset =
        protocol == null ? null : fbBuilder.writeString(protocol!);

    fbBuilder.startTable(10);
    fbBuilder.addOffset(0, usernameOffset);
    fbBuilder.addOffset(1, avatarPathOffset);
    fbBuilder.addOffset(2, sentHistoryOffset);
    fbBuilder.addOffset(3, fileInfoOffset);
    fbBuilder.addBool(4, isIntroRead);
    fbBuilder.addBool(5, queryPackages);
    fbBuilder.addBool(6, isDarkTheme);
    fbBuilder.addOffset(7, directoryPathOffset);
    fbBuilder.addBool(8, enableHttps);
    fbBuilder.addOffset(9, protocolOffset);
    return fbBuilder.endTable();
  }

  /// Convenience method to serialize to byte list.
  @override
  Uint8List toBytes([String? fileIdentifier]) {
    final fbBuilder = fb.Builder(deduplicateTables: false);
    fbBuilder.finish(finish(fbBuilder), fileIdentifier);
    return fbBuilder.buffer;
  }
}
