import 'dart:convert';
import 'package:flutter_book_reader/services/translator.dart';

import '../models/app_configuration.dart';
import 'file_manager.dart' show FileManager;

class AppConfigurationProvider {
  AppConfigurationProvider(this._manager);

  final _configuration = AppConfiguration();
  static const fileName = "config.json";
  final FileManager _manager;

  void setTheme(String mode) {
    _configuration.theme = mode;
    saveConfiguration();
  }

  void setTts(String service) {
    _configuration.ttsApi = service;
    saveConfiguration();
  }

  void setTranslation(String translater,
      {String? srcLang, String? targetLang}) {
    _configuration.setTranslation(translater,
        srcLang: srcLang, targetLang: targetLang);
    saveConfiguration();
  }

  void setTranslationApi(TranslationApi api) {
    _configuration.translationApi = api.toString();
    saveConfiguration();
  }

  TranslationApi getApi() =>
      TranslationApi.fromString(_configuration.translationApi);
  AppConfiguration getConfiguration() => _configuration;

  void loadConfiguration() {
    var fileContent = _manager.readFile(fileName);
    if (fileContent != null) {
      var encoder = const JsonDecoder();
      _configuration.fromMap(encoder.convert(fileContent));
    }
  }

  void saveConfiguration() {
    JsonEncoder encoder = const JsonEncoder();
    String content = encoder.convert(_configuration.toMap());
    _manager.writeFileSync(fileName, content);
  }
}
