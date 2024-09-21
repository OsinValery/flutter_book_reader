import '../../algoritms/parsers/html_parser.dart';
import '../../models/book.dart';
import '../../models/xml_based_tags.dart';
import 'base_book_reader.dart';
import 'readers_mixins.dart';

final class HtmlBookReader extends BookParser
    with BookReadingPreparator
    implements BookReader {
  HtmlBookReader(super.manager);

  @override
  Book getBook(String path) {
    clearOldBook();
    String? bookPath =
        fileManager.copyFile(path, BookReadingPreparator.tmpBookFolder);
    var htmlParser = HtmlParser();
    var htmlTag = htmlParser.parse(bookPath!);
    if (htmlTag == null) return HtmlBook(bookPath);
    var pages =
        htmlTag.splitTagOnPages(BookReadingPreparator.prefferedPageLength).$1;
    String fileExt = fileManager.getFileExtension(path);

    fileManager.removeFile(bookPath, isFull: true);
    var i = 0;
    var book = SplittedHtmlBook();

    for (HtmlTag page in pages.cast()) {
      var pagePath = fileManager.concatenate(
          BookReadingPreparator.tmpBookFolder, "page$i.$fileExt");
      book.addPage(fileManager.getFullPath(pagePath));
      fileManager.writeFileSync(pagePath, page.getHtml());

      var ids = page.findTagsWithId();
      for (var id in ids.keys) {
        book.addLink(i, id);
      }
      i += 1;
    }

    return book;
  }
}
