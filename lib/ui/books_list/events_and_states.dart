part of "bloc.dart";

abstract class BlocState {}

abstract class BlocEvent {}

// --------------------------------------------------
// events
// --------------------------------------------------

final class TestEvent extends BlocEvent {}

final class ReadLibraryEvent extends BlocEvent {}

final class AddBooksEvent extends BlocEvent {
  AddBooksEvent(this.paths);
  Iterable<String?> paths;
}

final class RemoveBookEvent extends BlocEvent {
  RemoveBookEvent(this.book);
  BookDescription book;
}

// --------------------------------------------------
// states
// --------------------------------------------------

final class InitialState extends BlocState {}

final class BooksListState extends BlocState {
  BooksListState(this.books);
  List<BookDescription> books;
}
