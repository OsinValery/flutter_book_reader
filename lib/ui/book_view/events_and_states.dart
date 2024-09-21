part of "bloc.dart";

abstract class BlocState {}

abstract class BlocEvent {}

// --------------------------------------------------
// events
// --------------------------------------------------

final class TestEvent extends BlocEvent {}

final class OpenBookEvent extends BlocEvent {
  OpenBookEvent(this.book, {this.startPage = 0});
  BookDescription book;
  int startPage;
}

final class PageTurnEvent extends BlocEvent {
  PageTurnEvent(this.page);
  int page;
}

final class PageTurnForward extends BlocEvent {}

final class PageTurnBackward extends BlocEvent {}

final class ReadTextEvent extends BlocEvent {
  ReadTextEvent(this.text, {this.isPage = false});
  final String text;
  final bool isPage;
}

final class StopReadingEvent extends BlocEvent {}

final class ReadingFinishedEvent extends BlocEvent {}

final class ReadPageEvent extends BlocEvent {}

// <a href='id'></a>
final class GoToPageFragment extends BlocEvent {
  String id;
  String? url;
  GoToPageFragment(this.id, this.url);
}

final class GetPageNumber extends BlocEvent {}

final class DemonstrateHTML extends BlocEvent {}

// --------------------------------------------------
// states
// --------------------------------------------------

final class InitialState extends BlocState {}

final class PageState extends BlocState {
  PageState(this.page, this.bookId);
  Page page;
  // this id generated from Book object and neededs to rener WebView widget
  // when user change book
  int bookId;
}

final class PageNumberState extends BlocState {
  final int maxPage;
  final int curPage;
  PageNumberState(this.curPage, this.maxPage);
}

final class ReadPageState extends BlocState {}

final class SpeakingState extends BlocState {
  final bool speaking;
  SpeakingState(this.speaking);
}
