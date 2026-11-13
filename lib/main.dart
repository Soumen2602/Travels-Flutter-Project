import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _homeUrl = 'https://www.grbtravels.com/GRBAPP1/';
const _brand = Color(0xFF075A64);

void main() => runApp(const GrbTravelsApp());

class GrbTravelsApp extends StatelessWidget {
  const GrbTravelsApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'GRB Travels',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: _brand, useMaterial3: true),
        home: const TravelWebPage(),
      );
}

class TravelWebPage extends StatefulWidget {
  const TravelWebPage({super.key});

  @override
  State<TravelWebPage> createState() => _TravelWebPageState();
}

class _TravelWebPageState extends State<TravelWebPage> {
  late final WebViewController _controller;
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() {
          _loading = true;
          _error = null;
        }),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? true) {
            setState(() {
              _loading = false;
              _error = 'Unable to load GRB Travels. Check your connection and try again.';
            });
          }
        },
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri == null) return NavigationDecision.prevent;
          if (_isExternalLink(uri)) {
            unawaited(_openExternalApp(uri));
            return NavigationDecision.prevent;
          }
          // Keep normal HTTPS website navigation inside the app.
          return uri.scheme == 'https' ? NavigationDecision.navigate : NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(_homeUrl));
  }

  bool _isExternalLink(Uri uri) {
    const whatsappHosts = {'wa.me', 'api.whatsapp.com', 'web.whatsapp.com'};
    return uri.scheme == 'whatsapp' ||
        uri.scheme == 'intent' ||
        uri.scheme == 'tel' ||
        uri.scheme == 'mailto' ||
        whatsappHosts.contains(uri.host.toLowerCase());
  }

  Future<void> _openExternalApp(Uri uri) async {
    var target = uri;
    // Android websites occasionally use intent:// WhatsApp links. Convert these
    // to the standard WhatsApp deep-link so both Android and iOS can handle it.
    if (uri.scheme == 'intent') {
      target = Uri.parse(uri.toString().replaceFirst('intent://', 'https://'));
    }
    final opened = await launchUrl(target, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp is not available on this device.')),
      );
    }
  }

  Future<void> _back() async {
    if (await _controller.canGoBack()) await _controller.goBack();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => _back(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            // Keeps the website clear of iPhone notches, Dynamic Island and Android cutouts.
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const LinearProgressIndicator(minHeight: 3),
                if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.cloud_off, size: 48, color: _brand),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => _controller.loadRequest(Uri.parse(_homeUrl)),
                          child: const Text('Try again'),
                        ),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
