import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PuterAIService {
  WebViewController? _controller;
  Completer<String>? _responseCompleter;

  PuterAIService() {
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'aiResponse',
        onMessageReceived: (message) {
          _responseCompleter?.complete(message.message);
        },
      )
      ..addJavaScriptChannel(
        'aiError',
        onMessageReceived: (message) {
          _responseCompleter?.completeError(message.message);
        },
      )
      ..loadHtmlString(_htmlContent);
  }

  Future<void> initialize() async {
    // Already initialized in constructor
  }

  static const String _htmlContent = '''
    <html>
    <head>
      <script src="https://js.puter.com/v2/"></script>
    </head>
    <body>
      <div id="content"></div>
    </body>
    </html>
  ''';

  Future<String> chat(String message,
      {String model = 'gemini-3-pro-preview'}) async {
    if (_controller == null) {
      throw Exception('Puter AI not initialized');
    }

    _responseCompleter = Completer<String>();

    // Execute the chat function in JS
    final jsCode = '''
      puter.ai.chat("${message.replaceAll('"', '\\"')}", {
        model: '$model'
      }).then(response => {
        aiResponse.postMessage(response);
      }).catch(error => {
        aiError.postMessage(error.toString());
      });
    ''';

    await _controller!.runJavaScript(jsCode);

    return _responseCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => 'Request timed out',
    );
  }

  Widget buildWebView() {
    if (_controller == null) {
      return const SizedBox.shrink(); // Return empty widget if not initialized
    }
    return WebViewWidget(
      controller: _controller!,
    );
  }
}
