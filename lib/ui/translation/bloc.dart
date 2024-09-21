import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/services/app_configuration_provider.dart';
import 'package:get_it/get_it.dart';

import '../../services/translator.dart';
part 'events_and_states.dart';

final class TranslationBloc
    extends Bloc<BaseTranslationEvent, TranslationState> {
  TranslationBloc() : super(TranslationState()) {
    on<TranslationEvent>(_onTranslateText);
    on<SelectSrcLangEvent>(_onSelectSrcLang);
    on<SelectTargetLangEvent>(_onSelectTargetLang);
    on<UpdateLaanguagesEvent>(_onUpdateLanguages);
    on<SelectTranslationApiEvent>(_onChangeApi);

    var conf = GetIt.I.get<AppConfigurationProvider>().getConfiguration();
    state.srcLanguage =
        conf.getSrcLanguage(conf.translationApi) ?? state.srcLanguage;
    state.targetLanguage =
        conf.getTargetLanguage(conf.translationApi) ?? state.targetLanguage;

    add(UpdateLaanguagesEvent());
  }

  _onUpdateLanguages(_, emitter) async {
    var translater = GetIt.I.get<TranslatorProvider>().translater;

    var configuration =
        GetIt.I.get<AppConfigurationProvider>().getConfiguration();
    late List<String> languages;
    try {
      languages = await translater.supportedLanguages;
    } catch (_) {
      languages = ["error"];
    }

    String? srcLang =
        configuration.getSrcLanguage(configuration.translationApi);
    String? targetLlang =
        configuration.getTargetLanguage(configuration.translationApi);

    emitter(
      state.copyWith(
          srcLang: languages.contains(state.srcLanguage)
              ? state.srcLanguage
              : languages.contains(srcLang)
                  ? srcLang
                  : translater.defaultLanguage,
          targetLang: languages.contains(state.targetLanguage)
              ? state.targetLanguage
              : languages.contains(targetLlang)
                  ? targetLlang
                  : languages.first,
          languages: languages),
    );
  }

  _onChangeApi(SelectTranslationApiEvent event, emitter) async {
    var translationApiFactory = GetIt.I.get<TranslatorProvider>();
    switch (event.api) {
      case 0:
        translationApiFactory.setApi = TranslationApi.base;
        GetIt.I
            .get<AppConfigurationProvider>()
            .setTranslationApi(TranslationApi.base);
      case 1:
        translationApiFactory.setApi = TranslationApi.argos;
        GetIt.I
            .get<AppConfigurationProvider>()
            .setTranslationApi(TranslationApi.argos);
      case 2:
        translationApiFactory.setApi = TranslationApi.google;
        GetIt.I
            .get<AppConfigurationProvider>()
            .setTranslationApi(TranslationApi.google);
    }

    add(UpdateLaanguagesEvent());
    await Future.delayed(const Duration(milliseconds: 700));
    add(TranslationEvent(state.text));
  }

  _onTranslateText(TranslationEvent event, Emitter emitter) async {
    var translator = GetIt.I.get<TranslatorProvider>().translater;
    if (event.text.isEmpty) return;
    emitter(state.copyWith(translatedText: " "));

    late final String translatedText;
    try {
      translatedText = await translator.translate(
        event.text,
        state.srcLanguage,
        state.targetLanguage,
      );
    } catch (e) {
      translatedText = "Internet error!  Can't translate text.";
      if (kDebugMode) {
        print("error!!!");
        print(e);
      }
    }
    emitter(state.copyWith(text: event.text, translatedText: translatedText));
  }

  _onSelectSrcLang(SelectSrcLangEvent event, Emitter emitter) {
    if (state.supportedLanguages.contains(event.lang)) {
      emitter(state.copyWith(srcLang: event.lang));
      var configProvider = GetIt.I.get<AppConfigurationProvider>();
      configProvider.setTranslation(
          configProvider.getConfiguration().translationApi,
          srcLang: event.lang);
      add(TranslationEvent(state.text));
    }
  }

  _onSelectTargetLang(SelectTargetLangEvent event, Emitter emitter) {
    if (state.supportedLanguages.contains(event.lang)) {
      emitter(state.copyWith(targetLang: event.lang));
      var configProvider = GetIt.I.get<AppConfigurationProvider>();
      configProvider.setTranslation(
          configProvider.getConfiguration().translationApi,
          targetLang: event.lang);
      add(TranslationEvent(state.text));
    }
  }

  int getPageNumber() {
    var conf = GetIt.I.get<AppConfigurationProvider>().getConfiguration();
    return switch (conf.translationApi) { "google" => 2, "argos" => 1, _ => 0 };
  }
}
