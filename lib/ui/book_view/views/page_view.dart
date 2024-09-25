import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/models/page.dart';
import 'package:flutter_book_reader/ui/book_view/views/pdf_page_view.dart';
import '../bloc.dart';
import 'html_page_view.dart';

class PageContent extends StatefulWidget {
  const PageContent({super.key});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  PageType currentPageType = PageType.empty;
  Widget curView = Container();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookViewBloc, BlocState>(
      buildWhen: (previous, current) => current is PageState,
      builder: (context, state) {
        var viewType = currentPageType;
        if (state is PageState) viewType = state.page.type;

        if (viewType != currentPageType) {
          currentPageType = viewType;
          switch (currentPageType) {
            case PageType.html:
              if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
                curView = const HtmlBasedPageContent();
              } else {
                var platform = Platform.operatingSystem;
                var message = "Now html isn't supported on $platform";
                curView = Center(child: Text(message));
              }
            case PageType.pdf:
              curView = const PdfViewPage();

            case PageType.empty:
              curView = const Center(child: Text("empty page"));
          }
        }
        return curView;
      },
    );
  }
}
