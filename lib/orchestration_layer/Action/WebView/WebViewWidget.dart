import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as wv;
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class EmbeddedWebViewWidget extends StatefulWidget {
  final String url;
  final bool showControls;

  const EmbeddedWebViewWidget({
    super.key,
    required this.url,
    this.showControls = true,
  });

  @override
  State<EmbeddedWebViewWidget> createState() => _EmbeddedWebViewWidgetState();
}

class _EmbeddedWebViewWidgetState extends State<EmbeddedWebViewWidget> {
  late final wv.WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    late final wv.PlatformWebViewControllerCreationParams params;
    if (wv.WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const wv.PlatformWebViewControllerCreationParams();
    }

    final wv.WebViewController controller =
        wv.WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(wv.JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        wv.NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _progress = progress / 100.0;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _progress = 0.0;
              });
            }
          },
          onWebResourceError: (wv.WebResourceError error) {
            if (mounted) {
              setState(() {
                _errorMessage = "Failed to load: ${error.description}";
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (defaultTargetPlatform != TargetPlatform.macOS) {
      controller.setBackgroundColor(const Color(0x00000000));
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        wv.WebViewWidget(controller: _controller),
        if (_progress > 0 && _progress < 1.0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 3,
            ),
          ),
        if (_errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connection Error',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _controller.reload(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_isLoading && _errorMessage == null && _progress == 0)
          const Center(child: CircularProgressIndicator()),
        if (widget.showControls && _errorMessage == null)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.small(
              onPressed: () => _controller.reload(),
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
      ],
    );
  }
}
