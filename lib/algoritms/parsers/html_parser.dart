import 'xml_parser_with_ignored_tags.dart';
import '../../models/xml_based_tags.dart';

class HtmlParser extends XmlParserWithIgnoredTags {
  @override
  List<String> get ignoreTags => const ['image'];

  @override
  HtmlTag createTag() => HtmlTag();

  @override
  (HtmlTag, int) parseString(String string, int pos) {
    var result = super.parseString(string, pos);
    return (result.$1 as HtmlTag, result.$2);
  }

  @override
  HtmlTag? parse(String path, {printExceptions = false}) {
    return super.parse(path, printExceptions: printExceptions) as HtmlTag;
  }
}
