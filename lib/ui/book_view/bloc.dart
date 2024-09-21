import 'package:flutter_book_reader/models/page.dart';
import 'package:flutter_book_reader/services/last_book_provider.dart';
import 'package:flutter_book_reader/services/speaking_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_book_reader/models/book.dart';
import 'package:flutter_book_reader/models/book_description.dart';
import 'package:flutter_book_reader/services/book_reader.dart';
import 'package:flutter_book_reader/services/file_manager.dart';

import 'package:get_it/get_it.dart';

part "events_and_states.dart";

class BookViewBloc extends Bloc<BlocEvent, BlocState> {
  BookViewBloc() : super(InitialState()) {
    on<TestEvent>(_onTestEvent);
    on<OpenBookEvent>(_onOpenBook);
    on<PageTurnEvent>(_onTurnPage);
    on<ReadTextEvent>(_onReadText);
    on<DemonstrateHTML>(_onDemonstrateHTML);
    on<PageTurnBackward>(_onBackward);
    on<PageTurnForward>(_onForward);
    on<GoToPageFragment>(_onWorkPageFragmentNavigation);
    on<GetPageNumber>(_onGetPage);
    on<ReadPageEvent>(_onReadPage);
    on<StopReadingEvent>(_onStopReading);
    on<ReadingFinishedEvent>(_onReadingFinished);

    Future.delayed(const Duration(milliseconds: 1000), _readLastBook);
  }

  Book? book;
  int page = 0;
  bool speakPage = false;
  FileManager get fileManager => GetIt.I<FileManager>();

  _onTestEvent(event, emitter) {
    print("test!!!!");
  }

  _onOpenBook(OpenBookEvent event, emitter) async {
    GetIt.I<SpeakingServiceProvider>().service.stop();
    speakPage = false;
    try {
      var reader =
          BookReaderFactory.getReader(event.book.extension, fileManager);
      book = await reader.getBook(event.book.path);
      GetIt.I.get<LastBookProvider>().saveLastBook(event.book.path);
      int startPage = 0;
      if (book!.containsPage(event.startPage)) startPage = event.startPage;

      // ignore: avoid_print
      print("I can read this book!!!!!!");
      add(PageTurnEvent(startPage));
      await Future.delayed(const Duration(milliseconds: 100));
      // event dont go into BlocListener of PageView
      emitter(PageState(book!.getPage(startPage), book.hashCode));
    } catch (e) {
      // ignore: avoid_print
      print("$e\ncant open book");
    }
  }

  _onTurnPage(PageTurnEvent event, emitter) {
    GetIt.I<SpeakingServiceProvider>().service.stop();
    if (book == null) return;
    if (book!.containsPage(event.page)) {
      if ((page != event.page) || page == 0) {
        page = event.page;
        var url = book!.getPage(page);
        emitter(PageState(url, book.hashCode));
        GetIt.I.get<LastBookProvider>().saveLastPage(page);
        if (speakPage) {
          Future.delayed(const Duration(milliseconds: 500), () {
            add(ReadPageEvent());
          });
        }
      }
    } else {
      speakPage = false;
    }
    add(GetPageNumber());
  }

  _onForward(event, emitter) => add(PageTurnEvent(page + 1));
  _onBackward(event, emitter) => add(PageTurnEvent(page - 1));

  _onWorkPageFragmentNavigation(GoToPageFragment event, emitter) {
    if (book is HtmlLinksResolver) {
      var bookLinker = book as HtmlLinksResolver;
      var page = bookLinker.findPage(event.id, event.url);
      if (page != null) add(PageTurnEvent(page));
    }
  }

  _onGetPage(event, emitter) {
    emitter(PageNumberState(page, book?.pages ?? 0));
  }

  _onReadText(ReadTextEvent event, Emitter emitter) async {
    GetIt.I<SpeakingServiceProvider>().service.speak(event.text, onFinish: () {
      add(ReadingFinishedEvent());
      if (speakPage) add(PageTurnForward());
    });
    speakPage = event.isPage;
    emitter(SpeakingState(true));
  }

  _onReadPage(evemt, Emitter emitter) {
    emitter(ReadPageState());
  }

  _onStopReading(event, emitter) {
    speakPage = false;
    GetIt.I<SpeakingServiceProvider>().service.stop();
    emitter(SpeakingState(false));
  }

  _onReadingFinished(event, Emitter emitter) {
    emitter(SpeakingState(false));
  }

  _onDemonstrateHTML(event, emitter) {
    if (book != null) {
      var pageDescription = book!.getPage(page);
      if (pageDescription.type != PageType.html) return;
      var path = pageDescription.content;
      // ignore: avoid_print
      print(path);
      var content = fileManager.readFile(path, isFull: true);
      // ignore: avoid_print
      print(content);
      Share.shareXFiles([XFile(path)]);
    }
  }

  _readLastBook() async {
    var (path, page) = await GetIt.I.get<LastBookProvider>().getLastPage();
    if (path != null) {
      add(OpenBookEvent(BookDescription(path), startPage: page ?? 0));
    }
  }
}
