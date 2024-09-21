import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/ui/book_view/bloc.dart';

class PageTurningView extends StatefulWidget {
  const PageTurningView({super.key});

  @override
  State<PageTurningView> createState() => _PageTurningViewState();
}

class _PageTurningViewState extends State<PageTurningView> {
  void updatePage(int value) {
    context.read<BookViewBloc>().add(PageTurnEvent(value));
  }

  late TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController();
    context.read<BookViewBloc>().add(GetPageNumber());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      child: BlocConsumer<BookViewBloc, BlocState>(
        buildWhen: (previous, current) => current is PageNumberState,
        listenWhen: (previous, current) => current is PageNumberState,
        listener: (context, state) {
          if (state is PageNumberState) {
            _pageController.text = state.curPage.toString();
          }
        },
        builder: (context, state) {
          if (state is! PageNumberState) return Container();
          var page = state;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _pageController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        int? newPage = int.tryParse(value);
                        if (newPage != null) updatePage(newPage);
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldState, newState) {
                        String newText = newState.text;
                        if (newText.isEmpty) return newState;
                        int? newPage = int.tryParse(newText);
                        if (newPage == null || newPage > page.maxPage) {
                          return oldState;
                        }
                        return newState;
                      })
                    ],
                  )),
                  const Text(" / "),
                  Text((page.maxPage - 1).toString()),
                ],
              ),
              if (page.maxPage != 0)
                Slider.adaptive(
                  key: const Key('turner'),
                  value: page.curPage.toDouble(),
                  min: 0,
                  max: page.maxPage.toDouble() - 1,
                  onChanged: (value) => updatePage(value.toInt()),
                  onChangeEnd: (value) => updatePage(value.toInt()),
                ),
            ],
          );
        },
      ),
    );
  }
}
