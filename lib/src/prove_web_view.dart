import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mono_prove/src/constants.dart';
import 'package:mono_prove/src/models/models.dart';
import 'package:mono_prove/src/utils/extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const _loggerName = 'MonoProveWidgetLogger';

/// This widget provides the interface for managing user identity
/// verification via Mono Prove.
class ProveWebView extends StatefulWidget {
  /// Creates a [ProveWebView] instance for integrating Mono Prove within the application.
  const ProveWebView({
    required this.sessionId,
    required this.onSuccess,
    this.showLogs = false,
    super.key,
    this.reference,
    this.onEvent,
    this.onClose,
  });

  /// Creates a [ProveWebView] instance from a [ProveConfiguration] config
  /// for integrating Mono Prove within the application
  ProveWebView.config({
    required ProveConfiguration config,
    this.showLogs = false,
    super.key,
  })  : sessionId = config.sessionId,
        onSuccess = config.onSuccess,
        reference = config.reference,
        onEvent = config.onEvent,
        onClose = config.onClose;

  /// The session ID for the current Mono Prove session.
  final String sessionId;

  /// Callback triggered when the user's identity has been successfully verified.
  final VoidCallback onSuccess;

  /// An optional reference to the current instance of Mono Prove.
  /// This value will be included in all [onEvent] callbacks for tracking purposes.
  final String? reference;

  /// Callback triggered whenever an event is dispatched by the Mono Prove widget.
  final void Function(ProveEvent event)? onEvent;

  /// Callback triggered when the Mono Prove widget is closed.
  final VoidCallback? onClose;

  /// Enables or disables detailed debug logging.
  /// Defaults to `false`.
  final bool showLogs;

  @override
  State<ProveWebView> createState() => _ProveWebViewState();
}

class _ProveWebViewState extends State<ProveWebView> {
  late WebViewController _webViewController;
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory<TapGestureRecognizer>(
      () => TapGestureRecognizer()
        ..onTapDown = (tap) {
          SystemChannels.textInput.invokeMethod(
            'TextInput.hide',
          );
        },
    ),
    const Factory(EagerGestureRecognizer.new),
  };

  @override
  void initState() {
    super.initState();
    initializeWebview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(
              controller: _webViewController,
              gestureRecognizers: gestureRecognizers,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, value, child) {
                if (value) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  void initializeWebview() {
    late final PlatformWebViewControllerCreationParams params;
    params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
          )
        : const PlatformWebViewControllerCreationParams();

    _webViewController = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) => request.grant(),
    );

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        Constants.jsChannel,
        onMessageReceived: (JavaScriptMessage data) {
          final rawData = data.message
              .removePrefix('"')
              .removeSuffix('"')
              .replaceAll(r'\', '');
          try {
            handleResponse(rawData);
          } catch (e) {
            logger('Failed to parse message: ${data.message} \nError: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading.value = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading.value = false;
            });

            if (widget.onEvent != null) {
              final event = ProveEvent(
                type: EventType.opened,
                data: EventData(
                  eventType: Constants.OPENED_EVENT,
                  reference: widget.reference,
                  timestamp: DateTime.now(),
                ),
              );
              widget.onEvent!(event);
            }
          },
          onWebResourceError: (e) {
            setState(() {
              isLoading.value = false;
            });
            logger('WebResourceError: ${e.description}, Type: ${e.errorType}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final parameters = Uri.parse(request.url).queryParameters;
            if (parameters.containsValue('cancelled') &&
                parameters.containsValue('widget_closed')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    confirmPermissionsAndLoadUrl();
  }

  Future<void> confirmPermissionsAndLoadUrl() async {
    bool isCameraGranted;

    if (!kIsWeb) {
      // Request camera permission
      final cameraStatus = await Permission.camera.status;
      isCameraGranted = cameraStatus.isGranted;
    } else {
      isCameraGranted = true;
    }

    if (!isCameraGranted) {
      final result = await Permission.camera.request();

      if (result == PermissionStatus.granted) {
        await loadRequest();
      } else {
        const snackBar = SnackBar(
          content: Text('Permissions not granted'),
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } else {
      await loadRequest();
    }
  }

  Future<void> loadRequest() {
    return _webViewController.loadRequest(
      Uri(
        scheme: Constants.urlScheme,
        host: Constants.proveHost,
        path: '/${widget.sessionId}',
      ),
    );
  }

  /// parse event from javascript channel
  void handleResponse(String body) {
    try {
      final bodyMap = json.decode(body) as Map<String, dynamic>;
      final type = bodyMap['type'] as String?;

      if (widget.onEvent != null) {
        final event = ProveEvent.fromMap(bodyMap);
        widget.onEvent!(event);
      }

      if (type != null) {
        switch (type) {
          case 'mono.prove.identity_verified':
            Navigator.pop(context);
            if (widget.onEvent != null) widget.onSuccess();
          case 'mono.prove.widget.closed':
            Navigator.pop(context);
            if (mounted && widget.onClose != null) widget.onClose?.call();
        }
      }
    } catch (e) {
      logger('$_loggerName: Failed to parse message: $body \nError: $e');
    }
  }

  void logger(String log) {
    if (kDebugMode && widget.showLogs) {
      debugPrint('$_loggerName: $log');
    }
  }
}
