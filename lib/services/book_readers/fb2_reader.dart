import 'dart:convert';

import '../../algoritms/parsers/fb2_parser.dart';

import '../../models/book.dart';
import '../../models/xml_based_tags.dart';
import 'base_book_reader.dart';
import 'readers_mixins.dart';

final class Fb2BookReaderV2 extends Fb2BookReader {
  Fb2BookReaderV2(super.manager);

  @override
  Book getBook(String path) {
    var encoder = FB2BookParser();
    clearOldBook();
    String? bookPath = fileManager.copyFile(path, _tmpBookFolder);
    var fb2Tag = encoder.parse(bookPath!);
    if (fb2Tag == null) throw Exception();
    var tag = fb2Tag as FB2Tag;
    List<FB2Tag> bodies = tag.findAllTagsInTree("body").cast();
    var binaries = tag.findAllTagsInTree("binary");
    var description = tag.findTagInTree("description");
    var descriptionTag = FB2BookDeskription();
    if (description?.text != null) descriptionTag.parse(description!.text!);

    _unpackBinaries(binaries);

    List<String> pages = [];
    var book = Fb2Book()..content = "";
    int curPage = 1;

    pages.add(_getHtmlFromTemplate('''
      ${descriptionTag.getCover()?.getHtml() ?? ""}
      ${descriptionTag.getForeignCover()?.getHtml() ?? ""}
      <br/><br/><br/><br/><br/><br/>
      $descriptionTag
      <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
    '''));

    if (bodies.isNotEmpty) {
      var body = bodies.first;
      var sections = body.findAllTagsInTree("section",
          includeThisWhenChildrenIsName: false);
      var chapters = sections.isEmpty ? [body] : sections;

      // notes
      if (bodies.length > 1) {
        if (!bodies[1].isEmpty) chapters.add(bodies[1]);
      }

      // split chapters on pages
      for (var chapter in chapters) {
        var (chapterPages, _) =
            chapter.splitTagOnPages(BookReadingPreparator.prefferedPageLength);
        for (FB2Tag chapterPage in chapterPages.cast()) {
          pages.add(_getHtmlFromTemplate(chapterPage.getHtml()));

          // work links
          chapterPage
              .findTagsWithId()
              .keys
              .forEach((id) => book.addLink(curPage, id));

          curPage += 1;
        }
      }
    }

    for (int i = 0; i < pages.length; i++) {
      var encoded = utf8.encode(pages[i]);
      var fileName = "chapter$i.html";
      var pathHtml = fileManager.concatenate(_tmpBookFolder, fileName);
      pathHtml = fileManager.getFullPath(pathHtml);
      fileManager.writeFileBinSync(pathHtml, encoded, isFull: true);
      book.addPage(pathHtml);
      if (i == 0) book.content = pathHtml;
    }

    book.pages = pages.length;
    return book;
  }
}

final class Fb2BookReader extends BookParser
    with BookReadingPreparator
    implements BookReader {
  final String _fileName = "book.html";

  Fb2BookReader(super.manager);
  String get _tmpBookFolder => BookReadingPreparator.tmpBookFolder;

  void _unpackBinaries(List<XmlTag> binaries) {
    for (var binary in binaries) {
      try {
        var binaryName = binary.attr['id'] ?? "undefined.txt";
        if (binary.text != null) {
          fileManager.writeFileBinSync(
            fileManager.concatenate(_tmpBookFolder, binaryName),
            base64.decode(
              binary.text!
                  .replaceAll(String.fromCharCode(10), "")
                  .replaceAll(String.fromCharCode(13), ""),
            ),
          );
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    }
  }

  String _getHtmlFromTemplate(String content) {
    return '''
    <head>
        <meta http-equiv='Content-Type' content='text/html; charset=utf8;'>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          $bookCss
        </style>
      </head>
      <body>
      $content
      </body>
    ''';
  }

  @override
  Book getBook(String path) {
    var encoder = FB2BookParser();
    clearOldBook();
    String? bookPath = fileManager.copyFile(path, _tmpBookFolder);
    var fb2Tag = encoder.parse(bookPath!);
    if (fb2Tag == null) throw Exception();
    var tag = fb2Tag as FB2Tag;
    List<FB2Tag> bodies = tag.findAllTagsInTree("body").cast();
    var binaries = tag.findAllTagsInTree("binary");
    var description = tag.findTagInTree("description");
    var descriptionTag = FB2BookDeskription();
    if (description?.text != null) descriptionTag.parse(description!.text!);

    _unpackBinaries(binaries);

    var html = '''
      ${descriptionTag.getCover()?.getHtml() ?? ""}
      ${descriptionTag.getForeignCover()?.getHtml() ?? ""}
      $descriptionTag
      <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
    ''';
    if (bodies.isNotEmpty) {
      html += bodies.first.getHtml();
    }
    // notes
    if (bodies.length > 1) {
      var notes = bodies[1].getHtml();
      html = '$html <hr color="green" width="50%"/> $notes';
    }
    var encoded = utf8.encode(_getHtmlFromTemplate(html));

    var pathHtml = fileManager.concatenate(_tmpBookFolder, _fileName);
    pathHtml = fileManager.getFullPath(pathHtml);
    fileManager.writeFileBinSync(pathHtml, encoded, isFull: true);

    return Fb2Book()
      ..content = pathHtml
      ..pages = 1;
  }
}

const bookCss = '''
.poem {
  display: table;
  margin: 0 auto;
  white-space: pre-line; 
  word-wrap: break-word;
}
body {
  font-size: 22px;
}

.cover {
  width: 98%;
}

table {
  border: 2px solid black;
  width: 98%;
  border-collapse: collapse;
  font-size: 22px;
}

td {
  overflow-wrap: break-word;
  word-break: break-word;
}

tr td:not(:last-child),tr th:not(:last-child) {
  border-right: 2px dotted black;
}
tr:not(:first-child) td,tr:not(:first-child) th {
  border-top: 2px dotted black;
}
tr:not(:last-child) td,tr:not(:last-child) th {
  border-bottom: 2px dotted black;
}
tr td:not(:first-child),tr th:not(:first-child) {
  border-left: 2px dotted black;
}

b.book_description {
  font-size: 1.2em;
  line-height: 1.8em; 
}

''';
