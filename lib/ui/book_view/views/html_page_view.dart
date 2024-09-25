import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../translation/bloc.dart' show TranslationBloc, TranslationEvent;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../bloc.dart';

/// presents book page
class HtmlBasedPageContent extends StatefulWidget {
  const HtmlBasedPageContent({super.key});

  @override
  State<HtmlBasedPageContent> createState() => _HtmlBasedPageContentState();
}

class _HtmlBasedPageContentState extends State<HtmlBasedPageContent> {
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    transparentBackground: true,
    //javaScriptEnabled: true,
    isInspectable: kDebugMode,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    defaultFontSize: 16,
    clearCache: true,
  );

  ContextMenu? contextMenu;
  bool needDrawPage = false;
  String rememberUrlWhileLoadPage = '';
  String pageKey = '';

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 1,
          title: "Copy",
          action: () async {
            var text = await webViewController!.getSelectedText();
            if (text != null && text.isNotEmpty) copyText(text);
          },
        ),
        ContextMenuItem(
          id: 2,
          title: "Read",
          action: () async {
            var text = await webViewController!.getSelectedText();
            if (mounted && text != null && text.isNotEmpty) {
              context.read<BookViewBloc>().add(ReadTextEvent(text));
            }
          },
        ),
        ContextMenuItem(
          id: 3,
          title: "Translate",
          action: () async {
            var text = await webViewController!.getSelectedText();
            if (mounted && text != null && text.isNotEmpty) translateText(text);
          },
        ),
      ],
      settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: true),
    );
  }

  void copyInternetLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Link was copied to clipboard"),
            const SizedBox(height: 8),
            Text(url),
          ],
        ),
      ));
    }
  }

  void copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text copied")),
      );
    }
  }

  void translateText(String text) {
    Scaffold.of(context).openEndDrawer();
    context.read<TranslationBloc>().add(TranslationEvent(text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookViewBloc, BlocState>(
      listenWhen: (previous, current) =>
          current is PageState || current is ReadPageState,
      listener: (context, state) async {
        if (state is ReadPageState) {
          var text = (await webViewController?.evaluateJavascript(
                  source: "document.body.innerText;")) ??
              "";

          if (mounted) {
            // ignore: use_build_context_synchronously
            context.read<BookViewBloc>().add(ReadTextEvent(text, isPage: true));
          }
        } else if (state is PageState) {
          String finalUrl = "file://${state.page.content}";
          if (webViewController == null) {
            needDrawPage = true;
            rememberUrlWhileLoadPage = finalUrl;
          } else {
            await InAppWebViewController.clearAllCache();
            webViewController?.loadUrl(
                urlRequest: URLRequest(url: WebUri(finalUrl)));
            if (pageKey.isNotEmpty && pageKey != state.bookId.toString()) {
              pageKey = state.bookId.toString();
              webViewController?.clearHistory();
            }
          }
        }
      },
      child: InAppWebView(
        onCloseWindow: (controller) => webViewController = null,
        key: Key(pageKey),
        initialSettings: settings,
        contextMenu: contextMenu,
        onWebViewCreated: (controller) {
          webViewController = controller;
          if (needDrawPage) {
            var req = URLRequest(url: WebUri(rememberUrlWhileLoadPage));
            webViewController?.loadUrl(urlRequest: req);
            needDrawPage = false;
          }
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url!;

          print("\nwant call: $uri !!!\n");
          print(uri.scheme);

          if (uri.fragment.isNotEmpty) {
            context
                .read<BookViewBloc>()
                .add(GoToPageFragment(uri.fragment, uri.path));
            await Future.delayed(const Duration(milliseconds: 500));

            var js =
                "document.getElementById(\"${uri.fragment}\").scrollIntoView(false);";
            controller.evaluateJavascript(source: js);
            return NavigationActionPolicy.ALLOW;
          } else if (uri.scheme != 'file') {
            copyInternetLink(uri.rawValue);
            return NavigationActionPolicy.CANCEL;
          }

          if (![
            "http",
            "https",
            "file",
            "chrome",
            "data",
            "javascript",
            "about"
          ].contains(uri.scheme)) {
            print("found");
          }

          return NavigationActionPolicy.ALLOW;
        },
        onConsoleMessage: (controller, consoleMessage) {
          if (kDebugMode) print(consoleMessage);
        },
      ),
    );
  }
}
