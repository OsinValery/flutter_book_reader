import 'dart:async';

import '../../models/book.dart';
import '../file_manager.dart';

// see other files, classes implements this class

abstract class BookParser {
  late FileManager fileManager;
  BookParser(FileManager manager) {
    fileManager = manager;
  }
}

abstract class BookReader extends BookParser {
  BookReader(FileManager manager) : super(manager);

  FutureOr<Book> getBook(String path);
}
