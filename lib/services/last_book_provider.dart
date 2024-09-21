import 'file_manager.dart';

class LastBookProvider {
  final FileManager _manager;
  LastBookProvider(this._manager);

  String? _book;
  int? _page;

  static const _fileName = "lastBook.txt";

  String get _fileContent => "page:${_page ?? 0}\nbook:$_book";

  void saveLastBook(String book) {
    _book = book;
    _manager.writeFile(_fileName, _fileContent);
  }

  void saveLastPage(int page) {
    _page = page;
    _manager.writeFile(_fileName, _fileContent);
  }

  Future<(String?, int?)> getLastPage() async {
    var content = _manager.readFileAsLinesSync(_fileName);
    if (content == null) return (null, null);
    for (var line in content) {
      var [key, value] = line.split(":");
      switch (key) {
        case "page":
          _page = int.tryParse(value);
        case "book":
          _book = value;
        default:
          break;
      }
    }

    return (_book, _page);
  }
}
