import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_book_reader/services/book_readers/base_book_reader.dart';

mixin BookReadingPreparator on BookParser {
  static const String tmpBookFolder = "tmpBook";
  static const int prefferedPageLength = 3000;

  void clearOldBook() {
    fileManager.removeFolder(tmpBookFolder);
    fileManager.createFolder(tmpBookFolder);
  }
}

mixin ZipBasedBooks on BookParser {
  static const String archiveName = "book";

  /// returns folder path with archive content [return]
  /// takes archive path [path] and folder [rootPath], where [return] will placed
  /// [minimize] = true, then need cast files names to lowerCase
  String extractZip(String path, String rootPath, {bool minimize = false}) {
    String zipPath = fileManager.concatenate(rootPath, archiveName);

    // unzip book
    var encoder = ZipDecoder();
    var fileContent = fileManager.readFileAsBytes(path, isFull: true);
    var result = encoder.decodeBytes(fileContent!.cast());

    // Extract the contents of the Zip archive to disk.
    for (final file in result) {
      String filename = file.name;
      if (minimize) filename = filename.toLowerCase();
      if (file.isFile) {
        fileManager.writeFileBinSync(
          fileManager.concatenate(zipPath, filename),
          file.content as Uint8List,
        );
      } else {
        fileManager.createFolder(fileManager.concatenate(zipPath, filename));
      }
    }
    return zipPath;
  }
}
