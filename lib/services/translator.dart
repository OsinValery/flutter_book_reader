import 'dart:async';
import 'package:simplytranslate/simplytranslate.dart';

enum TranslationApi {
  base,
  argos,
  google;

  @override
  String toString() {
    switch (this) {
      case base:
        return "test";
      case argos:
        return "argos";
      case google:
        return "google";
    }
  }

  static TranslationApi fromString(String api) => switch (api) {
        "google" => google,
        "argos" => argos,
        _ => base,
      };
}

class TranslatorProvider {
  TranslationApi _api = TranslationApi.base;

  set setApi(TranslationApi api) => _api = api;

  Translater get translater {
    return switch (_api) {
      TranslationApi.base => BaseTranslator(),
      TranslationApi.argos => ArgosTranslator(),
      TranslationApi.google => GoogleTranslater(),
      // ignore: unreachable_switch_case
      _ => throw Exception("Unknown translation api"),
    };
  }
}

abstract class Translater {
  Future<String> translate(String text, String src, String target);

  FutureOr<List<String>> get supportedLanguages;

  /// default src language
  String get defaultLanguage;
}

class BaseTranslator extends Translater {
  @override
  Future<String> translate(text, src, target) async => text;

  @override
  List<String> get supportedLanguages => ['test'];

  @override
  String get defaultLanguage => supportedLanguages.first;
}

class ArgosTranslator extends Translater {
  final _client = SimplyTranslator(EngineType.libre);
  @override
  String get defaultLanguage => "auto";

  @override
  FutureOr<List<String>> get supportedLanguages async {
    return argosLanguages;
  }

  @override
  Future<String> translate(String text, String src, String target) async {
    return (await _client.translateSimply(text, from: src, to: target))
        .translations
        .text;
  }
}

final class GoogleTranslater extends Translater {
  final _client = SimplyTranslator(EngineType.google);
  @override
  String get defaultLanguage => 'auto';

  @override
  List<String> get supportedLanguages => googleLanguages;

  @override
  Future<String> translate(String text, String src, String target) async {
    return (await _client.translateSimply(text, from: src, to: target))
        .translations
        .text;
  }
}

const argosLanguages = [
  'en',
  'ar',
  'zh',
  'fr',
  'de',
  'hi',
  'id',
  'ga',
  'it',
  'ja',
  'ko',
  'pl',
  'pt',
  'ru',
  'es',
  'tr',
  'vi',
  "auto"
];

const googleLanguages = [
  'auto',
  'af',
  'sq',
  'am',
  'ar',
  'hy',
  'az',
  'eu',
  'be',
  'bn',
  'bs',
  'bg',
  'ca',
  'ceb',
  'ny',
  'zh-cn',
  'zh-tw',
  'co',
  'hr',
  'cs',
  'da',
  'nl',
  'en',
  'eo',
  'et',
  'tl',
  'fi',
  'fr',
  'fy',
  'gl',
  'ka',
  'de',
  'el',
  'gu',
  'ht',
  'ha',
  'haw',
  'iw',
  'hi',
  'hmn',
  'hu',
  'is',
  'ig',
  'id',
  'ga',
  'it',
  'ja',
  'jw',
  'kn',
  'kk',
  'km',
  'ko',
  'ku',
  'ky',
  'lo',
  'la',
  'lv',
  'lt',
  'lb',
  'mk',
  'mg',
  'ms',
  'ml',
  'mt',
  'mi',
  'mr',
  'mn',
  'my',
  'ne',
  'no',
  'ps',
  'fa',
  'pl',
  'pt',
  'pa',
  'ro',
  'ru',
  'sm',
  'gd',
  'sr',
  'st',
  'sn',
  'sd',
  'si',
  'sk',
  'sl',
  'so',
  'es',
  'su',
  'sw',
  'sv',
  'tg',
  'ta',
  'te',
  'th',
  'tr',
  'uk',
  'ur',
  'uz',
  'ug',
  'vi',
  'cy',
  'xh',
  'yi',
  'yo',
  'zu',
];
