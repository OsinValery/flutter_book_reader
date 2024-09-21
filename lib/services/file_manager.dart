import "dart:io";
import "dart:typed_data";

import "package:flutter/foundation.dart" show debugPrint;
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import 'package:path/path.dart' show join, relative, extension;

void copyPathSync(String from, String to) {
  Directory(to).createSync(recursive: true);
  for (final file in Directory(from).listSync(recursive: true)) {
    final copyTo = join(to, relative(file.path, from: from));
    if (file is Directory) {
      Directory(copyTo).createSync(recursive: true);
    } else if (file is File) {
      File(file.path).copySync(copyTo);
    } else if (file is Link) {
      Link(copyTo).createSync(file.targetSync(), recursive: true);
    }
  }
}

class FileManager {
  FileManager._constructor();
  static final _instance = FileManager._constructor();
  factory FileManager() => _instance;

  static String appFolder = '';

  static Future initManager({bool log = true}) async {
    appFolder = (await getApplicationDocumentsDirectory()).path;
    if (log) debugPrint(appFolder);
    return;
  }

  String getFullPath(String path) =>
      path.startsWith('/') ? appFolder + path : "$appFolder/$path";

  String concatenate(String folder, String path) {
    path = path.startsWith('/') ? path.substring(1) : path;
    return join(folder, path);
  }

  List<String> getFolderContentSync(String path, {bool isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    Directory dir = Directory(fullPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    List<String> result = [];
    for (var entity in dir.listSync()) {
      if (entity is File) {
        String name = entity.path.split('/').last;
        if (name != '.DS_Store') result.add(name);
      }
    }
    return result;
  }

  Future writeFile(String path, String content, {bool isFull = false}) async {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!await file.exists()) await file.create(recursive: true);
    return await file.writeAsString(content);
  }

  void writeFileSync(String path, String content, {bool isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!file.existsSync()) file.createSync(recursive: true);
    return file.writeAsStringSync(content);
  }

  void writeFileBinSync(String path, Uint8List content, {bool isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!file.existsSync()) file.createSync(recursive: true);
    return file.writeAsBytesSync(content);
  }

  Future removeFile(String path, {bool isFull = false}) async {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (await file.exists()) await file.delete();
  }

  String? readFile(String path, {isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);

    File file = File(fullPath);
    if (!file.existsSync()) return null;
    return file.readAsStringSync();
  }

  Uint8List? readFileAsBytes(String path, {bool isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!file.existsSync()) return null;
    return file.readAsBytesSync();
  }

  bool haveFile(String path, {isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    return File(fullPath).existsSync();
  }

  void writeEndFile(String path, String data, {isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsString(data, mode: FileMode.append);
  }

  List<String>? readFileAsLinesSync(String path, {isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!file.existsSync()) return null;
    return file.readAsLinesSync();
  }

  void renameFile(String path, String newName, {isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    File file = File(fullPath);
    if (!file.existsSync()) file.createSync(recursive: true);
    var newPath = file.parent.path + Platform.pathSeparator + newName;
    file.renameSync(newPath);
  }

  void removeFolder(String path, {bool isFull = false, bool recursive = true}) {
    String fullPath = isFull ? path : getFullPath(path);
    Directory dir = Directory(fullPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: recursive);
      } catch (_) {}
    }
  }

  void createFolder(String path, {bool isFull = false}) {
    String fullPath = isFull ? path : getFullPath(path);
    Directory dir = Directory(fullPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);
  }

  /// [file] - path to file
  /// [dst] - path to destination folder, where should
  ///  be file with same name and content, as [file]
  /// returns path to result file
  String? copyFile(String file, String dst,
      {bool isFull1 = false, bool isFull2 = false}) {
    String fullPath1 = isFull1 ? file : getFullPath(file);
    String fullPath2 = isFull2 ? dst : getFullPath(dst);

    File srcFile = File(fullPath1);
    if (!srcFile.existsSync()) return null;

    String fileName = srcFile.path.split('/').last;
    var dstFile = join(fullPath2, fileName);
    return srcFile.copySync(dstFile).path;
  }

  /// [src] - path to source folder
  /// [dst] - path to folder, where pocy of [src] fill placed
  void copyFolder(String src, String dst,
      {bool isFull1 = false, bool isFull2 = false}) {
    String fullPath1 = isFull1 ? src : getFullPath(src);
    String fullPath2 = isFull2 ? dst : getFullPath(dst);

    var srcDir = Directory(fullPath1);
    if (!srcDir.existsSync()) return;

    var dirNames = srcDir.path.split(Platform.pathSeparator);
    dirNames.removeWhere((element) => element.isEmpty);
    var dirName = dirNames.last;
    var dstPath = join(fullPath2, dirName);

    copyPathSync(fullPath1, dstPath);
  }

  void clearTmpDir() {
    getTemporaryDirectory().then((value) {
      value.list(recursive: true).toList().then(
          (value) => value.map((element) => element.delete(recursive: true)));
    });
  }

  /// [file] - path to file
  /// [dst] - path to destination folder, where should
  ///  be file with same content, as [file]
  /// [newName] - new file name in [dst]
  /// returns path to result file
  String? copyFileWithRename(String file, String dst, String newName,
      {bool isFull1 = false, bool isFull2 = false}) {
    String fullPath1 = isFull1 ? file : getFullPath(file);
    String fullPath2 = isFull2 ? dst : getFullPath(dst);

    File srcFile = File(fullPath1);
    if (!srcFile.existsSync()) return null;

    var dstFile = join(fullPath2, newName);
    return srcFile.copySync(dstFile).path;
  }

  void renameFolder(
    String oldPath,
    String newPath, {
    bool isFull1 = false,
    bool isFull2 = false,
  }) {
    String fullPath1 = isFull1 ? oldPath : getFullPath(oldPath);
    String fullPath2 = isFull2 ? newPath : getFullPath(newPath);

    var dir = Directory(fullPath1);
    dir.renameSync(fullPath2);
  }

  Future<String> get tmpDir async => (await getTemporaryDirectory()).path;
  String getFileExtension(String path) => extension(path).replaceFirst('.', '');
}
