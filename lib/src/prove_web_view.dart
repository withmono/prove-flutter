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

class ProveWebView extends StatefulWidget {
  const ProveWebView({
    required this.sessionId,
    required this.onSuccess,
    this.showLogs = false,
    super.key,
    this.reference,
    this.onEvent,
    this.onClose,
  });

  final String sessionId;

  final VoidCallback onSuccess;

  /// This optional string is used as a reference to the current
  /// instance of Mono Connect. It will be passed to the data object
  /// in all onEvent callbacks.
  final String? reference;

  final void Function(ProveEvent event)? onEvent;

  final VoidCallback? onClose;

  final bool showLogs;

  @override
  State<ProveWebView> createState() => _ProveWebViewState();
}

class _ProveWebViewState extends State<ProveWebView> {
  late WebViewController _webViewController;
  ValueNotifier<bool> isLoading = ValueNotifier(true);

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
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}
                ..add(
                  Factory<TapGestureRecognizer>(
                    () => TapGestureRecognizer()
                      ..onTapDown = (tap) {
                        SystemChannels.textInput.invokeMethod(
                          'TextInput.hide',
                        );
                      },
                  ),
                ),
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
