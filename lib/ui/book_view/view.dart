import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/ui/background_view.dart';
import 'package:flutter_book_reader/ui/book_view/views/page_turning_view.dart';
import 'package:flutter_book_reader/ui/translation/view.dart';

import 'bloc.dart';
import "views/page_view.dart";

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<BookViewBloc, BlocState>(
      listenWhen: (previous, current) => false,
      listener: (context, state) {},
      child: const BookView(),
    );
  }
}

class BookView extends StatelessWidget {
  const BookView({super.key});

  static const double pageTurningWidgetWidth = 20;

  void showPageTurner(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (_) => const PageTurningView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toolBarIconsColor = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawerEnableOpenDragGesture: true,
      endDrawerEnableOpenDragGesture: false,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("BooksReader")),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Books list"),
              onTap: () {
                Navigator.of(context).popAndPushNamed('/library');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.of(context).popAndPushNamed('/settings');
              },
            ),
          ],
        ),
      ),
      endDrawer: const Drawer(child: TranslatorView()),
      appBar: AppBar(
        title: const Text("Reader"),
        actions: [
          TtsButton(color: toolBarIconsColor),
          if (kDebugMode)
            IconButton(
              onPressed: () =>
                  context.read<BookViewBloc>().add(DemonstrateHTML()),
              icon: Icon(Icons.code, color: toolBarIconsColor),
            ),
          IconButton(
            onPressed: () => showPageTurner(context),
            icon: Icon(Icons.book, color: toolBarIconsColor),
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundView(),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: pageTurningWidgetWidth),
              child: PageContent(),
            ),
          ),
          PageTurningButton(
            onPress: () => context.read<BookViewBloc>().add(PageTurnBackward()),
            width: pageTurningWidgetWidth,
            isRight: false,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: PageTurningButton(
              onPress: () =>
                  context.read<BookViewBloc>().add(PageTurnForward()),
              width: pageTurningWidgetWidth,
            ),
          ),
        ],
      ),
    );
  }
}

class TtsButton extends StatelessWidget {
  const TtsButton({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookViewBloc, BlocState>(
      buildWhen: (previous, current) => current is SpeakingState,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: state is! SpeakingState || !state.speaking
              ? IconButton(
                  key: const Key("start read"),
                  onPressed: () =>
                      context.read<BookViewBloc>().add(ReadPageEvent()),
                  icon: Image.asset(
                    "assets/images/sound.png",
                    width: 32,
                    height: 32,
                    color: color,
                  ),
                )
              : IconButton(
                  key: const Key("stop reading"),
                  onPressed: () =>
                      context.read<BookViewBloc>().add(StopReadingEvent()),
                  icon: Icon(Icons.stop, color: color),
                ),
        );
      },
    );
  }
}

class PageTurningButton extends StatelessWidget {
  const PageTurningButton({
    super.key,
    required this.onPress,
    required this.width,
    this.isRight = true,
  });

  final Function() onPress;
  final bool isRight;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: double.infinity,
        width: width,
        color: Colors.black.withAlpha(60),
        child: Center(
          child: Icon(
            isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            size: 16,
          ),
        ),
      ),
    );
  }
}
