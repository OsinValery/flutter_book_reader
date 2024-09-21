import 'dart:math';

import '../../models/xml_based_tags.dart';
import 'xml_parser.dart';

class XmlParserWithIgnoredTags extends XmlParser {
  // do not make static !!!!!
  final ignoreTags = [];

  XmlTag createTag() => XmlTag();

  @override
  (XmlTag, int) parseString(String string, int pos) {
    var root = createTag();
    if (string[pos] != '<') {
      pos = findSimbols(['<'], string, pos);
    }
    var close = findSimbols(['>'], string, pos);
    var tagTxt = string.substring(pos + 1, close);
    var selfClosed = isSelfClosed(tagTxt);
    // divide tag and xml arguments here!!
    var tagArgs = getTagArguments(tagTxt);
    root.tag = tagArgs.$1;
    root.attr = tagArgs.$2;

    if (selfClosed) return (root, close + 1);
    pos = close + 1;

    // ignore parsing content of tags with text content
    // this code only takes text inside tag
    if (ignoreTags.contains(root.tag)) {
      String closeTagText = getCloseTag(root.tag);
      var closeTagPos = string.indexOf(closeTagText, pos);
      if (closeTagPos == -1) {
        closeTagPos = string.length;
      }
      root.text = string.substring(pos, closeTagPos);
      return (root, closeTagPos + closeTagText.length);
    }
    var closed = false;
    while ((!closed) && (pos < string.length)) {
      var contentStart = pos;
      pos = findSimbols(['<'], string, contentStart);
      if (pos >= string.length) return (root, pos);
      var plainText = string.substring(contentStart, pos);
      if (plainText != '' && (plainText != '')) {
        root.append(createTag()
          ..tag = "plain_text"
          ..text = plainText);
      }
      // work '<'
      if (pos + 1 == string.length) closed = true;
      if (string[pos + 1] == '/') {
        closed = true;
        var closePos = findSimbols(['>'], string, pos + 1);
        pos = max(closePos + 1, pos + 1);
      }
      // it is internal tag
      if (!closed) {
        var subTag = createTag();
        (subTag, pos) = parseString(string, pos);
        root.append(subTag);
      }
    }
    return (root, pos);
  }
}
