import 'package:flutter/material.dart';
import 'package:flutter_book_reader/services/app_configuration_provider.dart';
import 'package:flutter_book_reader/services/speaking_service.dart';
import 'package:flutter_book_reader/ui/background_view.dart';
import 'package:flutter_book_reader/ui/theme_mode.dart';
import 'package:get_it/get_it.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: const BackgroundView(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ThemeSelector(),
                  SizedBox(height: 10),
                  TtsSelector(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TtsSelector extends StatefulWidget {
  const TtsSelector({super.key});

  @override
  State<TtsSelector> createState() => _TtsSelectorState();
}

class _TtsSelectorState extends State<TtsSelector> {
  void setTts(String? service) {
    if (service != null) {
      GetIt.I<SpeakingServiceProvider>().changeSpeaker(service);
      GetIt.I<AppConfigurationProvider>().setTts(service);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle contentStyle = TextStyle(color: Colors.black, fontSize: 24);
    var theme = Theme.of(context);
    final itemStyle = TextStyle(color: theme.colorScheme.onPrimary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Reading\nservice", style: contentStyle),
        DropdownButton<String>(
          value: GetIt.I<SpeakingServiceProvider>().serviceName,
          style: contentStyle,
          items: [
            DropdownMenuItem<String>(
              value: "system",
              child: Text("System", style: itemStyle),
            ),
            DropdownMenuItem<String>(
              value: "deepgram",
              child: Text("Deepgram", style: itemStyle),
            ),
          ],
          onChanged: (value) => setTts(value),
        ),
      ],
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  void setTheme(BuildContext context, ThemeMode? mode) {
    if (mode != null) {
      ThemeModeWidget.of(context)!.themeMode = mode;
      GetIt.I.get<AppConfigurationProvider>().setTheme(
            switch (mode) {
              ThemeMode.system => "system",
              ThemeMode.light => "light",
              ThemeMode.dark => "dark",
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle contentStyle = TextStyle(color: Colors.black, fontSize: 24);
    var theme = Theme.of(context);
    final itemStyle = TextStyle(color: theme.colorScheme.onPrimary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("App Theme", style: contentStyle),
        DropdownButton<ThemeMode>(
          value: ThemeModeWidget.of(context)?.value,
          style: contentStyle,
          items: [
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Text("Light", style: itemStyle),
            ),
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Text("Dark", style: itemStyle),
            ),
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Text("System", style: itemStyle),
            ),
          ],
          onChanged: (value) => setTheme(context, value),
        ),
      ],
    );
  }
}
