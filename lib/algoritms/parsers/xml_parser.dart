import 'dart:convert';
import 'dart:io';
import 'package:flutter_book_reader/algoritms/encodings.dart';

import '../../models/xml_based_tags.dart';

class XmlParser {
  String _determineEncoding(String path) {
    File file = File(path);
    // works with utf8 and windows1251
    // another not tested
    var raFile = file.openSync();
    var data = raFile.readSync(80);
    raFile.closeSync();
    String line = utf8.decode(data as List<int>, allowMalformed: true);
    //String line = file.readAsLinesSync().first;
    var pos = line.indexOf("encoding=");
    if (pos == -1) return "utf-8";
    pos += 10;
    var end = line.indexOf('"', pos);
    return line.substring(pos, end).toLowerCase();
  }

  String getCloseTag(String name) => "</$name>";

  /// returns position of any simbol in [text], given in [sims], starting with position [pos]
  int findSimbols(List<String> sims, String text, int pos) {
    while ((pos < text.length) && (!sims.contains(text[pos]))) {
      pos += 1;
    }
    return pos;
  }

  (String, Map<String, String>) getTagArguments(String tag) {
    Map<String, String> attr = {};
    var spacePos = tag.indexOf(' ');
    if (spacePos == -1) {
      return (tag.endsWith('/') ? tag.substring(0, tag.length - 1) : tag, attr);
    }
    String realTag = tag[spacePos - 1] == '/'
        ? tag.substring(0, spacePos - 1)
        : tag.substring(0, spacePos);

    var pos = spacePos + 1;
    while (pos < tag.length) {
      var eqPos = pos;
      while ((eqPos < tag.length) && (tag[eqPos] != '=')) {
        eqPos += 1;
      }
      if (eqPos >= tag.length) {
        pos = tag.length + 10;
      } else {
        var name = tag.substring(pos, eqPos).trim();
        var valStart = eqPos + 1;

        while ((valStart < tag.length) && (tag[valStart] == ' ')) {
          valStart += 1;
        }
        var value = '';
        var valEnd = 0;
        if (['"', '\''].contains(tag[valStart])) {
          valEnd = tag.indexOf(tag[valStart], valStart + 1);
          if (valEnd == -1) valEnd = tag.length;
          value = tag.substring(valStart + 1, valEnd);
        } else {
          // without string definition
          valEnd = tag.indexOf(' ', valStart);
          if (valEnd == -1) valEnd = tag.length;
          value = tag.substring(valStart, valEnd);
        }

        pos = valEnd + 1;
        attr[name] = value;
      }
    }
    return (realTag, attr);
  }

  bool isSelfClosed(String tag) {
    if (tag == '') return false;
    int pos = tag.length - 1;

    while (tag[pos] == " " && pos >= 0) {
      pos -= 1;
    }

    if (pos == -1) return false;
    return tag[pos] == '/';
  }

  String prepareStringParsing(String text) {
    //regExpr = RegExp(r"<\!\-\-[^(\-\->)]*\-\->");
    var regExpr = RegExp(r"<!--[^(-->)]*-->", unicode: true);
    return text.replaceAll(regExpr, "");
  }

  (XmlTag, int) parseString(String string, int pos) {
    var root = XmlTag();
    if (string[pos] != '<') {
      pos = findSimbols(['<'], string, pos);
    }
    var close = findSimbols(['>'], string, pos);
    var tagTxt = string.substring(pos + 1, close);
    // divide tag and xml arguments here!!
    var tagArgs = getTagArguments(tagTxt);
    root.tag = tagArgs.$1;
    root.attr = tagArgs.$2;
    if (isSelfClosed(tagTxt)) return (root, close + 1);
    pos = close + 1;
    var closed = false;
    while (!closed && pos < string.length) {
      var contentStart = pos;
      pos = findSimbols(['<'], string, contentStart);
      if (pos >= string.length) return (root, pos);
      var plainText = string.substring(contentStart, pos);
      if (plainText != '' && !(plainText != " ")) {
        root.append(XmlTag()
          ..tag = "plain_text"
          ..text = plainText);
      }
      // work '<'
      if (pos + 1 == string.length) {
        closed = true;
      }
      if (string[pos + 1] == '/') {
        closed = true;
        pos = findSimbols(['>'], string, pos + 1) + 1;
      }
      // it is internal tag
      if (!closed) {
        XmlTag subTag;
        (subTag, pos) = parseString(string, pos);
        root.append(subTag);
      }
    }
    return (root, pos);
  }

  XmlTag? parse(String path, {printExceptions = false}) {
    try {
      String encoding = _determineEncoding(path);

      String? content = readFile(path, encoding);
      if (content == null) {
        throw Exception("found unknown encoding: $encoding");
      }
      int pos = 0;

      if (!content.substring(0, 21).contains("<?hml")) {
        pos = 1;
      } else {
        pos = content.indexOf('>') + 1;
      }
      content = prepareStringParsing(content);
      var result = parseString(content, pos).$1;
      return result;
    } catch (e) {
      if (printExceptions) {
        // ignore: avoid_print
        print("error while parse xml \n $e");
      }
      return null;
    }
  }
}
