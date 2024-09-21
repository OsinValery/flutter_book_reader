// ignore_for_file: avoid_print
import '../../models/xml_based_tags.dart';
import 'xml_parser_with_ignored_tags.dart';
import 'xml_parser.dart';

class FB2BookParser extends XmlParserWithIgnoredTags {
  @override
  get ignoreTags => ['description', 'binary', 'image'];

  @override
  FB2Tag createTag() => FB2Tag();

  @override
  (FB2Tag, int) parseString(String string, int pos) {
    var result = super.parseString(string, pos);
    return (result.$1 as FB2Tag, result.$2);
  }
}

class Person {
  String name = '';
  String surname = '';
  String patronimic = '';
  List<String> emails = [];
  String nickname = '';
  //  Pages in the internet
  List<String> cites = [];
  String id = '';

  void parse(String text) {
    var pos = 0;
    while (pos < text.length) {
      var tagStart = text.indexOf('<', pos);
      if (tagStart == -1) {
        pos = text.length + 2;
      } else {
        var tagEnd = text.indexOf('>', tagStart);
        var tagText = text.substring(tagStart + 1, tagEnd);
        if (tagText.endsWith('/')) {
          pos = tagEnd + 1;
          continue;
        }
        var infoEnd = text.indexOf('</', tagStart + 1);
        var closeEnd = text.indexOf('>', infoEnd);
        pos = closeEnd + 1;
        var information = text.substring(tagEnd + 1, infoEnd);
        switch (tagText) {
          case 'first-name':
            name = information;
          case 'last-name':
            surname = information;
          case 'middle-name':
            patronimic = information;
          case 'email':
            emails.add(information);
          case 'id':
            id = information;
          case 'nickname':
            nickname = information;
          case 'home-page':
            cites.add(information);
          default:
            print(
                'unknown info about person: $tagText \n content: $information');
            print(text);
        }
      }
    }
  }

  @override
  String toString() {
    return """
      $surname $name $patronimic <br/>
      ${emails.join('<br/>')} ${emails.isEmpty ? "" : "<br/>"}
      ${nickname.isEmpty ? "" : "nick: $nickname <br/>"} 
      ${cites.isEmpty ? "" : "pages\n ${cites.join("<br/>")} <br/>"}
      ${id.isEmpty ? "" : "id: $id"}
    """;
  }
}

class Date {
  String value = '';
  String text = '';

  void parse(String text, String tag) {
    var attr = XmlParser().getTagArguments(tag).$2;
    if (attr.containsKey("value")) {
      value = attr['value']!;
    }
    text = text.trim();
  }

  @override
  String toString() {
    if (text.isEmpty) {
      return value.isEmpty ? "-" : value;
    } else {
      return text + (value.isEmpty ? "" : "($value)");
    }
  }
}

class TitleInfo {
  List<String> ganres = [];
  List<Person> authors = [];
  List<Person> translators = [];
  List<Map<String, dynamic>> sequence = [];
  String name = '';
  String keyWords = '';
  FB2Tag? annotation;
  Date date = Date();

  FB2Tag? image;
  String lang = 'unknown';
  String srcLang = 'unknown';

  void parse(String text) {
    int pos = 0;
    while (pos < text.length) {
      var startTag = text.indexOf('<', pos);
      if (startTag == -1) {
        pos = text.length + 10;
      } else {
        var endTag = text.indexOf('>', startTag);
        var tagContent = text.substring(startTag + 1, endTag);
        if (tagContent.contains('sequence')) {
          var attr = XmlParser().getTagArguments(tagContent);
          sequence.add(attr.$2);
          pos = endTag + 1;
        } else {
          var closetagText = (!tagContent.contains('date'))
              ? XmlParser().getCloseTag(tagContent)
              : '</date>';
          var close = text.indexOf(closetagText, endTag);
          if (close == -1) {
            pos = endTag + 1;
            print('no close tag for: $tagContent');
            print('!' * 20);
            print(text);
            continue;
          }
          pos = close + closetagText.length;
          var content = text.substring(endTag + 1, close);
          switch (tagContent) {
            case 'genre':
              ganres.add(content);
            case 'author':
              var person = Person();
              person.parse(content);
              authors.add(person);
            case 'book-title':
              name = content;
            case 'annotation':
              var annText = text.substring(startTag, pos);
              annotation = FB2BookParser().parseString(annText, 0).$1;
            case 'coverpage':
              image = FB2BookParser()
                  .parseString(text.substring(startTag, pos), 0)
                  .$1;
              image = (image?.findTagInTree("image") as FB2Tag?) ?? image;
              image?.addAttribut("class", "cover");

            case 'keywords':
              keyWords = content;
            case 'translator':
              var person = Person();
              person.parse(content);
              translators.add(person);
            default:
              if (tagContent.contains('date')) {
                date = Date();
                date.parse(content, tagContent);
              } else if (tagContent.contains('src-lang')) {
                srcLang = content;
              } else if (tagContent.contains('lang')) {
                lang = content;
              } else {
                print('unknown tag in title-info $tagContent');
                print(content);
              }
          }
        }
      }
    }
  }

  XmlTag? getCover() => image;

  @override
  String toString() {
    return """
      <table>
        <tr><td style="width:40%;"> Name </td> <td> $name </td></tr>
        <tr><td> Authors </td> <td> ${authors.join("\n")} </td></tr>
        <tr><td> Date </td> <td> $date </td></tr>
        <tr><td> Genres </td> <td> ${ganres.join(',')} </td></tr>
        <tr><td> Sequences </td> <td> ${sequence.join(',')} </td></tr>
        <tr><td> key words </td> <td> $keyWords </td></tr>
        <tr><td> text language </td> <td> $lang </td></tr>
        <tr><td> Translaters </td> <td> ${translators.join("\n")} </td></tr>
        <tr><td> Original language </td> <td> $srcLang </td></tr>
      </table>
      ${annotation != null ? '<b class="book_description"> Annotation </b>' : ""}
      ${annotation?.getHtml() ?? ""}
    """;
  }
}

class DocumentInfo {
  List<Person> documentAuthors = [];
  List<Person> publishers = [];
  String programUsed = '';
  String programUsedId = '';
  Date documentDate = Date();
  String srcUrl = '';
  String srcScannerPerson = '';
  String id = '';
  String version = '';

  FB2Tag? history;

  void parse(String text) {
    var pos = 0;
    while (pos < text.length) {
      var startTag = text.indexOf('<', pos);
      if (startTag == -1) {
        pos = text.length + 10;
      } else {
        var endTag = text.indexOf('>', startTag);
        var tagContent = text.substring(startTag + 1, endTag);

        var closetagText = (!tagContent.contains('date'))
            ? XmlParser().getCloseTag(tagContent)
            : '</date>';

        var closeTag = text.indexOf(closetagText, endTag);
        if (closeTag == -1) {
          pos = endTag + 1;
          print('no close tag for: $tagContent');
          print('!' * 20);
          print(text);
          continue;
        }
        var content = text.substring(endTag + 1, closeTag);
        pos = closeTag + closetagText.length;

        switch (tagContent) {
          case 'author':
            var person = Person();
            person.parse(content);
            documentAuthors.add(person);
          case 'publisher':
            var person = Person();
            person.parse(content);
            publishers.add(person);
          case 'program-used':
            programUsed = content;
          case 'program-id':
            programUsedId = content;
          case 'src-url':
            srcUrl = content;
          case 'src-ocr':
            srcScannerPerson = content;
          case 'id':
            id = content;

          case 'version':
            version = content;
          case 'history':
            history = FB2BookParser()
                .parseString(text.substring(startTag, pos), 0)
                .$1;
          default:
            if (tagContent.contains('date')) {
              documentDate = Date();
              documentDate.parse(content, tagContent);
            } else {
              print('unknown tag in document-info: $tagContent');
              print(content);
            }
        }
      }
    }
  }

  @override
  String toString() {
    return '''<table>
      <tr><td style="width:40%;"> Created </td> <td> $programUsed ${programUsedId.isNotEmpty ? '($programUsedId)' : ''} </td></tr>
      <tr><td> Publishers </td> <td> ${publishers.join("\n")} </td></tr>
      <tr><td> Date </td> <td> $documentDate </td></tr>
      <tr><td> Source </td> <td> $srcUrl </td></tr>
      <tr><td> Id </th> <td> $id </td></tr>
      <tr><td> Version </td> <td> $version </td></tr>
      <tr><td> Document editors </td> <td> ${documentAuthors.join("\n")} </td></tr>
      <tr><td> changes </td> <td> ${history?.getHtml() ?? "no info"} </td></tr>
      </table>
    ''';
  }
}

class PublishInfo {
  String bookName = '';
  String publisher = '';
  String publicationCity = '';
  String publicationTime = '';
  //  have in sceme
  List sequences = [];
  String isbn = '';

  void parse(String text) {
    int pos = 0;
    while (pos < text.length) {
      var startTag = text.indexOf('<', pos);
      if (startTag == -1) {
        pos = text.length + 10;
      } else {
        var endTag = text.indexOf('>', startTag);
        var tagContent = text.substring(startTag + 1, endTag);
        if (tagContent.contains('sequence')) {
          var attr = XmlParser().getTagArguments(tagContent);
          sequences.add(attr.$1);
          pos = endTag + 1;
        } else {
          // others have close tag
          var closetagText = XmlParser().getCloseTag(tagContent);
          var closeTag = text.indexOf(closetagText, endTag);
          if (closeTag == -1) {
            pos = endTag + 1;
            print('no close tag for: $tagContent');
            print('!' * 20);
            print(text);
            continue;
          }
          var content = text.substring(endTag + 1, closeTag);
          pos = closeTag + closetagText.length;
          switch (tagContent) {
            case 'book-name':
              bookName = content;
            case 'publisher':
              publisher = content;
            case 'city':
              publicationCity = content;
            case 'year':
              publicationTime = content;
            case 'isbn':
              isbn = content;
            default:
              print('unknown data in publish-info: $tagContent');
          }
        }
      }
    }
  }

  @override
  String toString() {
    return '''
    <table>
      <tr><td style="width:40%;"> Name </td> <td> $bookName </td></tr>
      <tr><td> Date </td> <td> $publicationTime </td></tr>
      <tr><td> Publisher </td> <td> $publisher </td></tr>
      <tr><td> City </td> <td> $publicationCity </td></tr>
      <tr><td> Sequebces </td> <td> ${sequences.join(", ")} </td></tr>
      <tr><td> ISBN </td> <td> $isbn </td></tr>
      </table>
    ''';
  }
}

class OriginalInfo extends TitleInfo {
  OriginalInfo() {
    lang = 'unknown';
    srcLang = 'unknown';
  }
}

class FB2BookDeskription {
  var titleInfo = TitleInfo();
  var documentInfo = DocumentInfo();
  var publishInfo = PublishInfo();
  var originalInfo = OriginalInfo();
  var customInfo = '';
  var customInfoType = '';

  void parse(String text) {
    int pos = 0;
    while (pos < text.length) {
      var tagStart = text.indexOf('<', pos);
      if (tagStart == -1) {
        pos = text.length + 10;
      } else {
        var tagEnd = text.indexOf('>', tagStart);
        var tagText = text.substring(tagStart + 1, tagEnd);

        if (tagText == 'title-info') {
          titleInfo = TitleInfo();
          var closeTag = text.indexOf('</title-info>', tagEnd);
          pos = closeTag + 13;
          var content = text.substring(tagEnd + 1, closeTag);
          titleInfo.parse(content);
        } else if (tagText == 'document-info') {
          documentInfo = DocumentInfo();
          var closeTag = text.indexOf('</document-info>', tagEnd);
          pos = closeTag + 16;
          var content = text.substring(tagEnd + 1, closeTag);
          documentInfo.parse(content);
        } else if (tagText == 'publish-info') {
          publishInfo = PublishInfo();
          var closeTag = text.indexOf('</publish-info>', tagEnd);
          pos = closeTag + 15;
          var content = text.substring(tagEnd + 1, closeTag);
          publishInfo.parse(content);
        } else if (tagText == 'src-title-info') {
          originalInfo = OriginalInfo();
          var closeTag = text.indexOf('</src-title-info>', tagEnd);
          pos = closeTag + 17;
          var content = text.substring(tagEnd + 1, closeTag);
          originalInfo.parse(content);
        } else if (tagText == 'output') {
          var closeTag = text.indexOf('</output>', tagEnd);
          pos = closeTag + 10;
          print(
              'found output tag in fb2 document. It must contain instruction for distributor. Likely, illegal access to document');
        } else if (tagText.contains('custom-info')) {
          var attr = XmlParser().getTagArguments(tagText).$2;
          if (attr.containsKey('into-type')) {
            customInfoType = attr['into-type']!;
          }
          var closeTag = text.indexOf('</custom-info>', tagEnd);
          pos = closeTag + '</custom-info>'.length;
          customInfo = text.substring(tagEnd + 1, closeTag);
        } else {
          if (tagText.endsWith('/')) {
            pos = tagEnd + 1;
            continue;
          }
          print('unknown tag: $tagText');
          var arg = XmlParser().getTagArguments(tagText);
          var close = '</${arg.$1}>';
          var closeTag = text.indexOf(close, tagEnd);
          if (closeTag == -1) {
            pos = tagEnd + 1;
          } else {
            pos = closeTag + (close).length;
          }
        }
      }
    }
  }

  getCover() => titleInfo.getCover();

  getForeignCover() => originalInfo.getCover();

  @override
  String toString() {
    return '''
      <b class="book_description"> Title Info </b>
      $titleInfo
      <b class="book_description"> Original Info </b>
      $originalInfo
      <b class="book_description"> Publication </b>
      $publishInfo
      <b class="book_description"> Document Info </b>
      $documentInfo
    ${(customInfoType.length + customInfoType.length > 0) ? """
    <b class="book_description"> Additional information </b>
      $customInfoType
      $customInfo
    """ : ""}''';
  }
}
