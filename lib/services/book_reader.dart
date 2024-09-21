import 'package:flutter_book_reader/services/book_readers/pdf_book_reader.dart';

import 'file_manager.dart';

import 'book_readers/base_book_reader.dart';
import 'book_readers/epub_reader.dart';
import 'book_readers/fb2_reader.dart';
import 'book_readers/html_reader.dart';
import 'book_readers/txt_reader.dart';

final class BookReaderFactory {
  static BookReader getReader(String fileExtension, FileManager fileManager) {
    late BookReader reader;
    switch (fileExtension) {
      case "html":
      case "xhtml":
      case "htm":
        reader = HtmlBookReader(fileManager);
      case "fb2":
        reader = Fb2BookReaderV2(fileManager);
      case "txt":
        reader = TxtBookReader(fileManager);
      case "epub":
        reader = EPubBookReader(fileManager);
      case "pdf":
        reader = PdfBookReader(fileManager);
      default:
        throw ArgumentError("unsupported file extension found: $fileExtension",
            "fileExtension");
    }
    return reader;
  }
}
