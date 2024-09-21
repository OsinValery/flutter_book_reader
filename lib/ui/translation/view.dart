import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/ui/translation/bloc.dart';

class TranslatorView extends StatelessWidget {
  const TranslatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        initialIndex: context.read<TranslationBloc>().getPageNumber(),
        child: Scaffold(
          body: Column(
            children: [
              TabBar(
                onTap: (value) => context
                    .read<TranslationBloc>()
                    .add(SelectTranslationApiEvent(value)),
                tabs: const [
                  Tab(text: "test"),
                  Tab(text: "Argos"),
                  Tab(text: "Google"),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    TabBarContent(index: 0),
                    TabBarContent(index: 1),
                    TabBarContent(index: 2),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TabBarContent extends StatelessWidget {
  const TabBarContent({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Translate from: "),
              BlocSelector<TranslationBloc, TranslationState,
                  (String, List<String>)>(
                selector: (st) => (st.srcLanguage, st.supportedLanguages),
                builder: (context, state) => LanguageSelector(
                  lenguages: state.$2,
                  selectedItem: state.$1,
                  onSelect: (newLanguage) => context
                      .read<TranslationBloc>()
                      .add(SelectSrcLangEvent(newLanguage)),
                ),
              )
            ],
          ),
          const Divider(),
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              child: BlocSelector<TranslationBloc, TranslationState, String>(
                selector: (value) => value.text,
                builder: (context, state) => Text(
                  state.isEmpty
                      ? "Select words in text ot translate it here"
                      : state,
                ),
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Translate to: "),
              BlocSelector<TranslationBloc, TranslationState,
                  (String, List<String>)>(
                selector: (st) => (st.targetLanguage, st.supportedLanguages),
                builder: (context, state) => LanguageSelector(
                  lenguages: state.$2,
                  selectedItem: state.$1,
                  onSelect: (newLang) => context
                      .read<TranslationBloc>()
                      .add(SelectTargetLangEvent(newLang)),
                ),
              )
            ],
          ),
          const Divider(),
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              child: BlocSelector<TranslationBloc, TranslationState, String>(
                selector: (value) => value.translatedText,
                builder: (context, state) => Text(
                  state.isEmpty
                      ? "Select words in text ot translate it here"
                      : state,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (index == 0)
            const Center(child: Text("Translated with test translater")),
          if (index == 1)
            const Center(child: Text("Translated with Argos translater")),
          if (index == 2)
            const Center(child: Text("Translated with Google translater")),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.lenguages,
    required this.selectedItem,
    required this.onSelect,
  });

  final String selectedItem;
  final List<String> lenguages;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: selectedItem,
      menuHeight: 300,
      onSelected: (value) => value == null ? null : onSelect(value),
      dropdownMenuEntries: lenguages
          .map((lang) => DropdownMenuEntry(value: lang, label: lang))
          .toList(),
    );
  }
}
