import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/ui/book_view/bloc.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfViewPage extends StatefulWidget {
  const PdfViewPage({super.key});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) {
    var pdfWidgetSize = MediaQuery.of(context).size;
    return BlocBuilder<BookViewBloc, BlocState>(
      buildWhen: (previous, current) => current is PageState,
      builder: (context, state) {
        if (state is! PageState) {
          context.read<BookViewBloc>().add(GetPageNumber());
          return Container();
        }
        var result = Center(
          child: FittedBox(
            fit: BoxFit.fill,
            child: PdfPageView(
              key: UniqueKey(),
              document: state.page.content,
              pageNumber: state.page.number + 1,
              backgroundColor: Colors.transparent,
              decorationBuilder: (context, pageSize, page, pageImage) {
                page.loadText().then(
                  (value) {
                    print(value.fragments);
                  },
                );
                return Container(
                  margin: const EdgeInsets.all(0),
                  width: pdfWidgetSize.width,
                  height: pdfWidgetSize.height,
                  alignment: Alignment.center,
                  child: pageImage,
                );
              },
            ),
          ),
        );

        return result;
      },
    );
  }
}
