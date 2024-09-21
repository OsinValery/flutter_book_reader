import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/services/library_provider.dart';
import 'package:get_it/get_it.dart';

import '../../models/book_description.dart';

part 'events_and_states.dart';

class BooksListBloc extends Bloc<BlocEvent, BlocState> {
  BooksListBloc() : super(InitialState()) {
    on<TestEvent>(_onTestEvent);
    on<ReadLibraryEvent>(_onUpdateLibrary);
    on<AddBooksEvent>(_onAddBook);
    on<RemoveBookEvent>(_onRemoveBook);
  }

  LibraryProvider get libProvider => GetIt.I.get<LibraryProvider>();

  _onTestEvent(_, __) {
    // ignore: avoid_print
    print("test");
  }

  _onUpdateLibrary(event, emitter) async {
    var books = await libProvider.readBooks();
    emitter(BooksListState(books));
  }

  _onAddBook(AddBooksEvent event, emitter) {
    libProvider.addBooks(event.paths);
    add(ReadLibraryEvent());
  }

  _onRemoveBook(event, emitter) {
    libProvider.removeBook(event.book).then((value) => add(ReadLibraryEvent()));
  }
}
