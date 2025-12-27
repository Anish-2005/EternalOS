import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:js' as js;

class PuterAIService {
  WebViewController? _controller;
  Completer<String>? _responseCompleter;

  PuterAIService() {
    if (!kIsWeb) {
      _initializeController();
    }
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
    if (kIsWeb) {
      // Load Puter script on web
      js.context.callMethod('eval', [
        '''
        if (!window.puter) {
          var script = document.createElement('script');
          script.src = 'https://js.puter.com/v2/';
          document.head.appendChild(script);
        }
      '''
      ]);
    }
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
    if (kIsWeb) {
      return _chatWeb(message, model: model);
    } else {
      return _chatMobile(message, model: model);
    }
  }

  Future<String> _chatWeb(String message,
      {String model = 'gemini-3-pro-preview'}) async {
    final completer = Completer<String>();

    try {
      // Use JS interop to call Puter AI
      final result = js.context.callMethod('puter.ai.chat', [
        message,
        js.JsObject.jsify({'model': model})
      ]);

      // Since it's async, we need to handle the promise
      // This is tricky with dart:js, might need a different approach
      completer.complete('Web chat not fully implemented yet. Result: $result');
    } catch (e) {
      completer.completeError(e.toString());
    }

    return completer.future;
  }

  Future<String> _chatMobile(String message,
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
    if (kIsWeb || _controller == null) {
      return const SizedBox
          .shrink(); // Return empty widget if not initialized or on web
    }
    return WebViewWidget(
      controller: _controller!,
    );
  }
}
