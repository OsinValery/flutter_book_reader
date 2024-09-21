class AppConfiguration {
  String theme = "system";
  String translationApi = "base";
  String ttsApi = "system";
  final Map<String, (String, String)> _translationLanguages = {
    "test": ("test", "test"),
    "argos": ("en", "ru"),
    "google": ("en", "ru"),
  };

  void setTranslation(String translater,
      {String? srcLang, String? targetLang}) {
    if (!_translationLanguages.containsKey(translater)) {
      _translationLanguages[translater] = ("en", "en");
    }

    var newSrc = srcLang ?? _translationLanguages[translater]!.$1;
    var newTarget = targetLang ?? _translationLanguages[translater]!.$2;
    _translationLanguages[translater] = (newSrc, newTarget);
  }

  String? getSrcLanguage(String translater) =>
      _translationLanguages[translater]?.$1;

  String? getTargetLanguage(String translater) =>
      _translationLanguages[translater]?.$2;

  Map<String, dynamic> toMap() => {
        "theme": theme,
        "api": translationApi,
        "tts_api": ttsApi,
        "translators": _translationLanguages.map(
          (key, value) =>
              MapEntry(key, {"first": value.$1, "second": value.$2}),
        ),
      };
  void fromMap(Map<String, dynamic> data) {
    try {
      if (data.containsKey("theme")) theme = data["theme"];
      if (data.containsKey("api")) translationApi = data['api'];
      if (data.containsKey("tts_api")) ttsApi = data['tts_api'];

      if (data.containsKey("translators")) {
        for (var key in (data['translators'] as Map).keys) {
          var value = data["translators"][key];
          _translationLanguages[key] =
              (value['first'] ?? "en", value['second'] ?? "en");
        }
      }
    } catch (_) {}
  }
}
