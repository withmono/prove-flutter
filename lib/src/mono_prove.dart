import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mono_prove/mono_prove.dart';

/// The Mono Prove SDK is a quick and secure way to onboard your users from within your Flutter app.
/// Mono Prove is a customer onboarding product that offers businesses faster customer onboarding and
/// prevents fraudulent sign-ups, powered by the MDN and facial recognition technology.
///
/// This class serves as the entry point for interacting with the Mono Prove SDK in Flutter,
/// offering multiple ways to present the Mono Prove WebView widget to users.
class MonoProve {
  static MethodChannel channel = const MethodChannel('flutter.mono.co/prove');

  /// Returns the Mono Prove WebView widget configured with the provided [ProveConfiguration].
  ///
  /// This method is used to initialize and return the `ProveWebView` widget with the specified
  /// [config] and optional [showLogs] parameter. The `ProveWebView` widget is only available
  /// on non-web platforms.
  static Widget _webView(
    ProveConfiguration config, {
    bool showLogs = false,
  }) {
    return ProveWebView.config(
      config: config,
      showLogs: showLogs,
    );
  }

  static void _open(ProveConfiguration config) {
    channel
      ..invokeMethod('setup', {
        'requestId': config.sessionId,
      })
      ..setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onClose':
            config.onClose?.call();

            return true;
          case 'onSuccess':
            config.onSuccess();

            return true;
          case 'onEvent':
            if (config.onEvent != null) {
              final args = (call.arguments as Map<Object?, Object?>)
                  .map<String, Object?>(
                (key, value) => MapEntry('$key', value),
              );

              final data = {
                ...(jsonDecode(args['data'].toString())
                    as Map<String, dynamic>),
                'type': args['eventName'],
              };

              config.onEvent!(ProveEvent.fromMap({...args, 'data': data}));
            }
            return true;
        }
      });
  }

  /// Launches the Mono Prove WebView widget in a new full-screen page.
  ///
  /// It requires a [BuildContext] and a [ProveConfiguration] instance
  /// to initialize the WebView.
  ///
  /// ### Parameters:
  /// - [context]: The `BuildContext` used to access the navigation stack.
  /// - [config]: A required [ProveConfiguration] instance for configuring the Mono Prove session.
  /// - [showLogs]: (Optional) A boolean flag to enable or disable logging. Default is `false`.
  ///
  /// ### Example:
  /// ```dart
  /// final config = ProveConfiguration(
  ///   sessionId: 'your-session-id',
  ///   onSuccess: () => print('Success!'),
  /// );
  ///
  /// MonoProve.launch(context, config: config);
  /// ```
  static void launch(
    BuildContext context, {
    required ProveConfiguration config,
    bool showLogs = false,
  }) {
    if (kIsWeb) {
      return _open(config);
    }

    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (c) => _webView(
          config,
          showLogs: showLogs,
        ),
      ),
    );
  }

  /// Launches the Mono Prove WebView widget in a dialog.
  ///
  /// This method presents the WebView inside a modal dialog.
  /// Use this when you want the WebView to appear as a floating window.
  ///
  /// ### Example:
  /// ```dart
  /// MonoProve.launchDialog(context, config: config);
  /// ```
  static void launchDialog(
    BuildContext context, {
    required ProveConfiguration config,
    bool showLogs = false,
  }) {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported for this method. Please use MonoProve.launch(context, config: config) for web.');
    }

    showDialog<dynamic>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _webView(
            config,
            showLogs: showLogs,
          ),
        ),
      ),
    );
  }

  /// Launches the Mono Prove WebView widget in a modal bottom sheet.
  ///
  /// This method displays the WebView inside a modal bottom sheet.
  ///
  /// ### Example:
  /// ```dart
  /// MonoProve.launchModalBottomSheet(context, config: config);
  /// ```
  static void launchModalBottomSheet(
    BuildContext context, {
    required ProveConfiguration config,
    bool showLogs = false,
  }) {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported for this method. Please use MonoProve.launch(context, config: config) for web.');
    }

    showModalBottomSheet<dynamic>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      builder: (_) => _webView(
        config,
        showLogs: showLogs,
      ),
    );
  }
}
