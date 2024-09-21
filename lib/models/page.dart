enum PageType {
  html,
  pdf,
  empty,
}

final class Page {
  Page(this.number, this.type, this.content);
  int number;
  PageType type;
  dynamic content;
}
