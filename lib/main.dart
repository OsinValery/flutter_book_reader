import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_book_reader/env/env.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'services/file_manager.dart';
import 'services/library_provider.dart';
import 'services/last_book_provider.dart';
import 'services/translator.dart';
import '/services/speaking_service.dart';
import '/services/app_configuration_provider.dart';

import 'ui/book_view/view.dart';
import 'ui/books_list/view.dart';
import 'ui/theme_mode.dart';

import 'ui/book_view/bloc.dart';
import 'ui/books_list/bloc.dart';
import 'ui/translation/bloc.dart';
import 'ui/settings/view.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS || Platform.isMacOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  await FileManager.initManager();
  var manager = FileManager();
  manager.createFolder(LibraryProvider.libraryFolder);
  var configuration = AppConfigurationProvider(manager);
  configuration.loadConfiguration();
  var translationProvider = TranslatorProvider();
  translationProvider.setApi = configuration.getApi();

  GetIt.I.allowReassignment = true;
  GetIt.I.registerSingleton<FileManager>(manager);
  GetIt.I.registerSingleton<LibraryProvider>(LibraryProvider(manager));
  GetIt.I.registerSingleton<LastBookProvider>(LastBookProvider(manager));
  GetIt.I.registerSingleton<TranslatorProvider>(translationProvider);
  GetIt.I.registerSingleton<AppConfigurationProvider>(configuration);
  GetIt.I.registerSingleton<SpeakingServiceProvider>(SpeakingServiceProvider(
    configuration.getConfiguration().ttsApi,
    (String service) => switch (service) {
      "deepgram" => DeepgramSpeakingService(Env.myApiKey),
      "system" || _ => SystemSpeaker()
    },
  ));

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  var strings = [
    "problems:",
    "1) select language, voice for tts, use https://pub.dev/packages/flutter_langdetect",
    "6) fb2 epigraph пофиксить выравнивание в строках разной длинны и эпиграфах из 2 стихов"
        "and table created borders (remove it)",
    "12) add file drag and drop",
    "13) epub supports pdf pages",
    "14) epub supports encryption",
    "15) fb2 description translate content (fields names, genres, and so on)",
    "16) epub show metadata",
    "18) deepgram android: requests in background dont work maybe, add changes to "
        "android manifest according just_audio_background"
        "main.dart add Platform.android to service Init condition",
    "---------------------------------------------------------------",
  ];
  // ignore: avoid_print
  strings.forEach(print);
  // ignore: avoid_print
  print("support files:\n${LibraryProvider.supportedFormats.join('\n')}");

  ThemeMode initialThemeMode = ThemeMode.system;
  switch (configuration.getConfiguration().theme) {
    case "system":
      initialThemeMode = ThemeMode.system;
    case "dark":
      initialThemeMode = ThemeMode.dark;
    case "light":
      initialThemeMode = ThemeMode.light;
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BookViewBloc>(create: (_) => BookViewBloc()),
        BlocProvider<BooksListBloc>(create: (_) => BooksListBloc()),
        BlocProvider<TranslationBloc>(create: (_) => TranslationBloc())
      ],
      child: ThemeModeWidget(
        initialMode: initialThemeMode,
        child: const App(),
      ),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // light theme color
    Color color = Colors.brown;
    Color secondary = Colors.brown.shade400;
    Color contrast = Colors.green;

    // dark theme color
    Color dColor = Colors.black;
    Color dSecondary = Colors.black.withAlpha(100);
    Color dContrast = Colors.grey;
    Color dWhite = const Color.fromARGB(255, 169, 177, 208);

    return MaterialApp(
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const MainView(),
        '/library': (context) => const BooksListView(),
        "/settings": (context) => const SettingsView(),
      },
      themeMode: ThemeModeWidget.of(context)?.value,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: color,
        canvasColor: color,
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: color,
          onPrimary: Colors.white,
          secondary: secondary,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: secondary,
          onSurface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: color,
          centerTitle: false,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: color,
        ),
        dividerColor: contrast,
        sliderTheme: SliderThemeData(
          activeTrackColor: color,
          inactiveTickMarkColor: Colors.white,
          inactiveTrackColor: Colors.white,
          secondaryActiveTrackColor: Colors.white,
          thumbColor: color,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: dColor,
        canvasColor: dSecondary,
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: dColor,
          onPrimary: dWhite,
          secondary: dSecondary,
          onSecondary: dWhite,
          error: const Color.fromARGB(255, 152, 30, 21),
          onError: dWhite,
          surface: dSecondary,
          onSurface: dWhite,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: dColor,
          centerTitle: false,
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: dColor,
        ),
        dividerColor: dContrast,
        sliderTheme: SliderThemeData(
          activeTrackColor: dColor,
          inactiveTickMarkColor: dWhite,
          inactiveTrackColor: dWhite,
          secondaryActiveTrackColor: dWhite,
          thumbColor: dColor,
        ),
      ),
    );
  }
}
