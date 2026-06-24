import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CaptchaService {
  static String _buildHtml(String siteKey) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { display: flex; justify-content: center; align-items: center; min-height: 100vh; background: transparent; }
  </style>
</head>
<body>
  <div id="turnstile-container"></div>
  <script>
    window.addEventListener('load', function() {
      turnstile.render('#turnstile-container', {
        sitekey: '$siteKey',
        callback: function(token) { CaptchaChannel.postMessage(token); },
        'error-callback': function() { CaptchaChannel.postMessage('__ERROR__'); }
      });
    });
  </script>
</body>
</html>
''';

  static Future<String?> verify(BuildContext context, {required String siteKey}) {
    final html = _buildHtml(siteKey);
    final completer = Completer<String?>();
    Navigator.of(context).push(_CaptchaRoute(html: html, completer: completer));
    return completer.future;
  }
}

class _CaptchaRoute extends PageRouteBuilder<void> {
  _CaptchaRoute({required String html, required Completer<String?> completer})
    : super(
        pageBuilder: (_, __, ___) => _CaptchaPage(html: html, completer: completer),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        barrierDismissible: false,
        opaque: false,
      );
}

class _CaptchaPage extends StatefulWidget {
  final String html;
  final Completer<String?> completer;
  const _CaptchaPage({required this.html, required this.completer});

  @override
  State<_CaptchaPage> createState() => _CaptchaPageState();
}

class _CaptchaPageState extends State<_CaptchaPage> {
  late final WebViewController _controller;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'CaptchaChannel',
        onMessageReceived: _onMessage,
      )
      ..loadHtmlString(widget.html);

    Future.delayed(const Duration(seconds: 16), () {
      if (!_resolved && mounted) {
        _resolved = true;
        widget.completer.complete(null);
        Navigator.of(context).pop();
      }
    });
  }

  void _onMessage(JavaScriptMessage msg) {
    if (_resolved) return;
    _resolved = true;
    widget.completer.complete(msg.message == '__ERROR__' ? null : msg.message);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 1,
              height: 1,
              child: Opacity(
                opacity: 0,
                child: WebViewWidget(controller: _controller),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Verifying your request…',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
