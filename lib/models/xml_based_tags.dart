class XmlTag {
  String? text;
  String _tag = "";
  String sheme = "";
  List<XmlTag> content = [];
  Map<String, dynamic> attr = {};

  XmlTag copy() {
    return XmlTag()
      ..text = text
      ..tag = tag
      ..sheme = sheme
      ..content = [...content]
      ..attr = {...attr};
  }

  void append(XmlTag tag) => content.add(tag);
  void addAttribut(String key, dynamic value) => attr[key] = value;
  bool get isEmpty => content.isEmpty;
  String get tag => _tag;
  set tag(String tagName) {
    int pos = tagName.lastIndexOf(":");
    if (pos == -1) {
      _tag = tagName;
    } else {
      _tag = tagName.substring(pos + 1);
      sheme = tagName.substring(0, pos);
    }
  }

  XmlTag? findTagInTree(String name) {
    if (tag == name) return this;
    for (var child in content) {
      var res = child.findTagInTree(name);
      if (res != null) return res;
    }
    return null;
  }

  List<XmlTag> findAllTagsInTree(String name,
      {bool includeThisWhenChildrenIsName = true}) {
    List<XmlTag> result = [];

    for (var child in content) {
      result += child.findAllTagsInTree(name);
    }
    if (tag == name) {
      if (result.isEmpty || includeThisWhenChildrenIsName) result = [this];
    }
    return result;
  }

  Map<String, XmlTag> findTagsWithId() {
    Map<String, XmlTag> result = {};
    if (attr.containsKey('id')) result[attr['id']] = this;

    for (var child in content) {
      result.addAll(child.findTagsWithId());
    }
    return result;
  }

  int get countSymbols {
    int result = 0;
    if (text != null) result = text!.length;
    for (var child in content) {
      result += child.countSymbols;
    }
    return result;
  }

  (List<XmlTag>, int) splitTagOnPages(
    int prefferedMaxSize, [
    int alreadyUsedSize = 0,
  ]) {
    if (content.isEmpty) {
      return ([this], alreadyUsedSize + countSymbols);
    }
    List<List<XmlTag>> result = [];
    List<XmlTag> curGroup = [];
    for (var child in content) {
      int childSize = child.countSymbols;
      if (childSize < prefferedMaxSize - alreadyUsedSize) {
        curGroup.add(child);
        alreadyUsedSize += childSize;
      } else {
        var (tmpGroup, newUsedSize) = (childSize < prefferedMaxSize)
            ? ([child], childSize)
            : child.splitTagOnPages(prefferedMaxSize, alreadyUsedSize);

        if (tmpGroup.isNotEmpty) {
          var first = tmpGroup.removeAt(0);
          alreadyUsedSize = 0;
          if (first.countSymbols + alreadyUsedSize <= prefferedMaxSize) {
            curGroup.add(first);
            result.add(curGroup);
          } else {
            result.add(curGroup);
            result.add([first]);
          }
          curGroup = [];

          if (tmpGroup.isNotEmpty) {
            if (newUsedSize < prefferedMaxSize) {
              curGroup = [tmpGroup.removeLast()];
              alreadyUsedSize = newUsedSize;
            }
          }

          for (var el in tmpGroup) {
            result.add([el]);
          }
        }
      }
    }
    if (curGroup.isNotEmpty) result.add(curGroup);
    return ([for (var el in result) copy()..content = el], alreadyUsedSize);
  }
}

/// method work
class FB2Tag extends XmlTag {
  @override
  FB2Tag copy() {
    return FB2Tag()
      ..text = text
      ..tag = tag
      ..content = [...content]
      ..attr = {...attr};
  }

  String getHtml() {
    var arguments = "";
    attr.forEach((key, value) => arguments += ' $key="$value"');
    if (arguments.isNotEmpty) arguments = ' $arguments';

    var childrenHtml = '';
    if (tag == "poem") {
      for (var child in content) {
        if (child.tag == "stanza" || child.tag == "text-author") {
          if (childrenHtml.isNotEmpty) childrenHtml += "<br/>";
        }
        childrenHtml += (child as FB2Tag).getHtml();
      }
    } else {
      for (var child in content) {
        childrenHtml += (child as FB2Tag).getHtml();
      }
    }
    childrenHtml += " ${text ?? ''}";

    // work specific logic
    if (tag == "image") {
      String path = attr['l:href'] ?? attr['xlink:href'] ?? "";
      if (path.startsWith('#')) path = path.substring(1);

      return '<img style="max-width:98%;display:block;margin:auto;" src="$path"$arguments>';
    } else if (tag == 'a') {
      String path = attr['l:href'] ?? attr['xlink:href'] ?? "";
      return '<a href="$path"$arguments>$childrenHtml</a>';
    } else if (tag == "plain_text") {
      return text ?? "";
    } else if (tag == "strikethrough") {
      return '<s$arguments><del$arguments> $childrenHtml </del></s>';
    } else if (tag == "sup" || tag == "sub") {
      return '<$tag$arguments> $childrenHtml </$tag>';
    } else if (tag == "strong") {
      return '<span style="font-weight:bold"$arguments> $childrenHtml </span>';
    } else if (tag == "emphasis") {
      return '<i$arguments> $childrenHtml </i>';
    } else if (tag == "title") {
      return "<h1$arguments> $childrenHtml </h1>";
    } else if (tag == "subtitle") {
      return "<h4$arguments> $childrenHtml </h4>";
    } else if (tag == "empty-line") {
      return "<br/>";
    } else if (tag == "cite") {
      return "<blockquote$arguments> $childrenHtml </blockquote>";
    } else if (["th", "tr", "table"].contains(tag)) {
      return '<$tag$arguments> $childrenHtml </$tag>';
    } else if (tag == "code") {
      return "";
    } else if (tag == "v") {
      return '<p$arguments> $childrenHtml </p>';
    } else if (tag == "annotation" || tag == "body") {
      return childrenHtml;
    } else if (tag == "section") {
      return "<div$arguments>$childrenHtml</div>";
    } else if (tag == "poem") {
      return "<div class=\"poem\"$arguments> $childrenHtml </div>";
    } else if (tag == "epigraph") {
      return '<table border="0" align="right"><tr><td> $childrenHtml </td></tr></table><br clear="all">';
    } else {
      return "<$tag$arguments> $childrenHtml </$tag>";
    }
  }
}

class HtmlTag extends XmlTag {
  @override
  HtmlTag copy() => HtmlTag()
    ..text = text
    ..tag = tag
    ..content = [...content]
    ..attr = {...attr};

  String getHtml() {
    var arguments = "";
    for (var key in attr.keys) {
      arguments += ' $key="${attr[key]}"';
    }
    if (arguments.isNotEmpty) arguments = ' $arguments';

    var childrenHtml = '';
    for (HtmlTag child in content.cast()) {
      childrenHtml += child.getHtml();
    }
    childrenHtml += " ${text ?? ''}";

    return "<$tag$arguments> $childrenHtml </$tag>";
  }
}

class FB3Tag extends FB2Tag {
  @override
  FB3Tag copy() {
    return FB3Tag()
      ..text = text
      ..tag = tag
      ..content = [...content]
      ..attr = {...attr};
  }
}
