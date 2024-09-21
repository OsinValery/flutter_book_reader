import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/services/library_provider.dart';
import 'package:flutter_book_reader/ui/background_view.dart';
import 'package:flutter_book_reader/ui/book_view/bloc.dart'
    show BookViewBloc, OpenBookEvent;

import '../../models/book_description.dart';
import 'bloc.dart';

class BooksListView extends StatefulWidget {
  const BooksListView({super.key});

  @override
  State<BooksListView> createState() => _BooksListViewState();
}

class _BooksListViewState extends State<BooksListView> {
  @override
  void initState() {
    super.initState();
    context.read<BooksListBloc>().add(ReadLibraryEvent());
  }

  void addBook() async {
    var bloc = context.read<BooksListBloc>();
    bool extFilterSupported = !Platform.isAndroid & !Platform.isIOS;
    var result = await FilePicker.platform.pickFiles(
      allowedExtensions:
          extFilterSupported ? LibraryProvider.supportedFormats : null,
      type: extFilterSupported ? FileType.custom : FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      bloc.add(AddBooksEvent(result.paths));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BooksListBloc, BlocState>(
      listenWhen: (previous, current) => false,
      listener: (context, state) {},
      child: Scaffold(
        appBar: AppBar(title: const Text("Library")),
        body: const BackgroundView(child: BooksListContent()),
        floatingActionButton: FloatingActionButton.small(
          onPressed: addBook,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class BooksListContent extends StatelessWidget {
  const BooksListContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BooksListBloc, BlocState>(
      buildWhen: (previous, current) => current is BooksListState,
      builder: (context, state) {
        if (state is! BooksListState || state.books.isEmpty) {
          return const EmptyBooksListView();
        }
        return ListView(
          key: UniqueKey(),
          children: state.books
              .map(
                (e) => BookView(book: e, key: Key(e.toString())),
              )
              .toList(),
        );
      },
    );
  }
}

class BookView extends StatelessWidget {
  const BookView({super.key, required this.book});

  final BookDescription book;

  @override
  Widget build(BuildContext context) {
    Color elementsColor = Colors.black;

    return ListTile(
      leading: Icon(Icons.book, color: elementsColor),
      title: Text(book.name, style: TextStyle(color: elementsColor)),
      subtitle: Text(
        book.extension,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.error,
          size: 28,
        ),
        onPressed: () =>
            context.read<BooksListBloc>().add(RemoveBookEvent(book)),
      ),
      onTap: () {
        context.read<BookViewBloc>().add(OpenBookEvent(book));
        Navigator.of(context).pop();
      },
    );
  }
}

class EmptyBooksListView extends StatelessWidget {
  const EmptyBooksListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Books list is empty"));
  }
}
