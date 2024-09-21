import "page.dart";

abstract class Book {
  abstract final int pages;

  Page getPage(int number);
  bool containsPage(int page);
}

mixin HtmlLinksResolver {
  final Map<String, int> _mapPageAndIds = {};

  void addLink(int page, String id) => _mapPageAndIds[id] = page;

  int? findPage(String id, String? url) =>
      _mapPageAndIds.containsKey(id) ? _mapPageAndIds[id] : null;
}

mixin MultyHtmlLinksResolver implements HtmlLinksResolver {
  @override
  Map<String, int> get _mapPageAndIds => throw UnimplementedError();

  final Map<String?, Map<String, int>> _mapUrlPageAndIds = {};

  @override
  void addLink(int page, String id, {String? url}) {
    if (!_mapUrlPageAndIds.containsKey(url)) _mapUrlPageAndIds[url] = {};
    _mapUrlPageAndIds[url]![id] = page;
  }

  @override
  int? findPage(String id, String? url) => _mapUrlPageAndIds[url]?[id];
}

final class HtmlBook with HtmlLinksResolver implements Book {
  HtmlBook(this._path);
  @override
  final int pages = 1;

  final String _path;

  @override
  getPage(int number) => Page(number, PageType.html, _path);

  @override
  bool containsPage(int page) => page == 0;
}

final class Fb2Book with HtmlLinksResolver implements Book {
  @override
  late final int pages;

  dynamic content;
  final List<String> _pages = [];

  @override
  getPage(int number) {
    if (number == 0) return Page(number, PageType.html, content);
    return Page(number, PageType.html, _pages[number]);
  }

  @override
  bool containsPage(int page) => (page >= 0 && page < pages);
  addPage(String page) => _pages.add(page);
}

final class EpubBook with MultyHtmlLinksResolver implements Book {
  List<String> pagesList = [];
  @override
  late final int pages;

  @override
  bool containsPage(int page) => (page >= 0 && page < pages);

  @override
  getPage(int number) {
    return Page(number, PageType.html, pagesList.elementAt(number));
  }
}

final class SplittedHtmlBook with HtmlLinksResolver implements Book {
  final List<String> _pages = [];
  @override
  int get pages => _pages.length;

  @override
  bool containsPage(int page) {
    return (page >= 0) && (page < pages);
  }

  @override
  getPage(int number) => Page(number, PageType.html, _pages[number]);
  void addPage(String page) => _pages.add(page);
}

final class Fb3Book with MultyHtmlLinksResolver implements Book {
  final List<String> _pagesList = [];

  @override
  bool containsPage(int page) => page >= 0 && page <= pages;

  @override
  getPage(int number) {
    return Page(number, PageType.html, _pagesList[number]);
  }

  @override
  int get pages => _pagesList.length;

  void addPage(String page) => _pagesList.add(page);
}

final class PdfBook implements Book {
  PdfBook();
  late final _document;

  @override
  bool containsPage(int page) => page >= 0 && page < pages;

  @override
  Page getPage(int number) {
    return Page(number, PageType.pdf, _document);
  }

  set content(dynamic cont) => _document = cont;

  @override
  late final int pages;
}
