import 'package:path/path.dart';

final class BookDescription {
  BookDescription(this.path) {
    String fileName = basename(path);
    int point = fileName.lastIndexOf(".");
    name = fileName.substring(0, point);
    extension = fileName.substring(point + 1).toLowerCase();
  }
  late final String name;
  late final String extension;
  String path;
}
