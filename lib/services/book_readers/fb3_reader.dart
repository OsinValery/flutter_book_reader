import 'package:flutter_book_reader/algoritms/parsers/fb2_parser.dart';
import 'package:flutter_book_reader/models/book.dart';
import 'package:flutter_book_reader/services/book_readers/readers_mixins.dart';

import 'base_book_reader.dart';

class Fb3Reader extends BookParser
    with BookReadingPreparator, ZipBasedBooks
    implements BookReader {
  Fb3Reader(super.manager);

  String get _tmpBookFolder => BookReadingPreparator.tmpBookFolder;

  @override
  Book getBook(String path) {
    var book = Fb3Book();
    clearOldBook();
    String? bookPath = fileManager.copyFile(path, _tmpBookFolder);
    if (bookPath == null) throw ArgumentError("error with file $path");
    String zipPath = extractZip(bookPath, _tmpBookFolder, minimize: false);

    var parser = FB2BookParser();

    return book;
  }
}
