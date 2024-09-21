import 'dart:io';

import '../../algoritms/parsers/xml_parser.dart';
import '../../models/book.dart';
import 'base_book_reader.dart';
import 'readers_mixins.dart';

final class EPubBookReader extends BookParser
    with BookReadingPreparator, ZipBasedBooks
    implements BookReader {
  EPubBookReader(super.manager);

  String get _tmpBookFolder => BookReadingPreparator.tmpBookFolder;

  @override
  Book getBook(String path) {
    var book = EpubBook();
    clearOldBook();
    String? bookPath = fileManager.copyFile(path, _tmpBookFolder);
    if (bookPath == null) throw ArgumentError("error with file $path");
    String zipPath = extractZip(bookPath, _tmpBookFolder, minimize: true);

    XmlParser xmlParser = XmlParser();
    String metaInfo = fileManager.concatenate("meta-inf", "container.xml");
    var containerTag = xmlParser.parse(
        fileManager.getFullPath(fileManager.concatenate(zipPath, metaInfo)));

    var rootFiles = containerTag?.findAllTagsInTree("rootfile");

    String opfPath = fileManager.concatenate(zipPath, "content.opf");
    if (rootFiles == null || rootFiles.isEmpty) {
    } else {
      String? opfDir = rootFiles.first.attr["full-path"];
      if (opfDir != null) {
        opfPath = fileManager.concatenate(zipPath, opfDir.toLowerCase());
      }
    }

    var contentRoot = File(opfPath).parent.path;
    var opfTag = xmlParser.parse(fileManager.getFullPath(opfPath));
    if (opfTag == null) throw Exception("cant read .opf file");

    var manifest = opfTag.findTagInTree("manifest");
    var spine = opfTag.findTagInTree("spine");
    var metadata = opfTag.findTagInTree("metadata");

    if (manifest == null || spine == null) {
      throw Exception("no important sections of book");
    }

    var mapIdAndSrc = manifest.findTagsWithId().map((key, value) =>
        MapEntry(key, (value.attr['href'] as String).toLowerCase()));

    for (var page in spine.findAllTagsInTree("itemref")) {
      String pageId = page.attr['idref'];
      String? pathInRoot = mapIdAndSrc[pageId];

      if (pathInRoot == null) {
      } else {
        var fullPath = fileManager.concatenate(contentRoot, pathInRoot);
        book.pagesList.add(fileManager.getFullPath(fullPath));
      }
    }

    return book..pages = book.pagesList.length;
  }
}
