import '../../models/book.dart';
import 'base_book_reader.dart';
import 'readers_mixins.dart';

class TxtBookReader extends BookParser
    with BookReadingPreparator
    implements BookReader {
  TxtBookReader(super.manager);

  @override
  Book getBook(String path) {
    clearOldBook();
    String? bookPath =
        fileManager.copyFile(path, BookReadingPreparator.tmpBookFolder);

    return HtmlBook(bookPath!);
  }
}
