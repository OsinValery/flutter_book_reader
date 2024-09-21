part of "bloc.dart";

abstract class BaseTranslationEvent {}

final class TranslationState {
  String text = "";
  String translatedText = "";
  String srcLanguage = "";
  String targetLanguage = "";

  List<String> supportedLanguages = [];

  TranslationState copyWith({
    String? text,
    String? translatedText,
    String? srcLang,
    String? targetLang,
    List<String>? languages,
  }) =>
      TranslationState()
        ..text = text ?? this.text
        ..translatedText = translatedText ?? this.translatedText
        ..srcLanguage = srcLang ?? srcLanguage
        ..targetLanguage = targetLang ?? targetLanguage
        ..supportedLanguages = languages ?? supportedLanguages;
}

final class TranslationEvent extends BaseTranslationEvent {
  TranslationEvent(this.text);
  final String text;
}

final class SelectSrcLangEvent extends BaseTranslationEvent {
  final String lang;
  SelectSrcLangEvent(this.lang);
}

final class SelectTargetLangEvent extends BaseTranslationEvent {
  final String lang;
  SelectTargetLangEvent(this.lang);
}

final class UpdateLaanguagesEvent extends BaseTranslationEvent {}

final class SelectTranslationApiEvent extends BaseTranslationEvent {
  int api;
  SelectTranslationApiEvent(this.api);
}
