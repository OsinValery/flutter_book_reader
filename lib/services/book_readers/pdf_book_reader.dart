import 'dart:async';

import 'package:flutter_book_reader/models/book.dart';
import 'package:pdfrx/pdfrx.dart';
import 'readers_mixins.dart';
import 'base_book_reader.dart';

final class PdfBookReader extends BookParser
    with BookReadingPreparator
    implements BookReader {
  PdfBookReader(super.manager);

  @override
  Future<Book> getBook(String path) async {
    var book = PdfBook();
    clearOldBook();

    int pages;
    var document = await PdfDocument.openFile(fileManager.getFullPath(path));
    book.content = document;
    pages = document.pages.length;

    return book..pages = pages;
  }
}
