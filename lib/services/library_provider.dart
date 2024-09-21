import 'package:flutter_book_reader/services/file_manager.dart';
import '../models/book_description.dart';

class LibraryProvider {
  LibraryProvider(this._fileManager);
  static String libraryFolder = 'library';
  static final supportedFormats = [
    "html",
    "xhtml",
    'fb2',
    'htm',
    "txt",
    "epub",
    "pdf",
  ];

  List<String>? _books;
  final FileManager _fileManager;

  List<BookDescription> getBooks() => (_books ?? [])
      .map((e) => BookDescription(_fileManager.concatenate(libraryFolder, e)))
      .toList();

  Future<List<BookDescription>> readBooks() async {
    _books = _fileManager.getFolderContentSync(libraryFolder);
    return getBooks();
  }

  void addBook(String path) {
    if (supportedFormats
        .contains(_fileManager.getFileExtension(path).toLowerCase())) {
      _fileManager.copyFile(path, libraryFolder, isFull1: true);
    }
  }

  void addBooks(Iterable<String?> paths) =>
      paths.where((e) => e != null).cast<String>().forEach(addBook);

  Future removeBook(BookDescription book) {
    return _fileManager.removeFile(book.path);
  }
}
