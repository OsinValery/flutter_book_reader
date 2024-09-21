import '../../models/xml_based_tags.dart';
import 'fb2_parser.dart';

class FB3BookParser extends FB2BookParser {
  @override
  FB3Tag createTag() => FB3Tag();

  @override
  (FB3Tag, int) parseString(String string, int pos) {
    var result = super.parseString(string, pos);
    return (result.$1 as FB3Tag, result.$2);
  }
}
