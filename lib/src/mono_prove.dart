import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mono_prove/mono_prove.dart';

/// The Mono Prove SDK is a quick and secure way to onboard your users from within your Flutter app.
/// Mono Prove is a customer onboarding product that offers businesses faster customer onboarding and
/// prevents fraudulent sign-ups, powered by the MDN and facial recognition technology.
class MonoProve {
  void launch(
    BuildContext context,
    String sessionId, {
    required VoidCallback onSuccess,
    bool showLogs = false,
    String? reference,
    VoidCallback? onClose,
    void Function(ProveEvent)? onEvent,
  }) {
    if (kIsWeb) {
    } else {
      Navigator.push(
        context,
        MaterialPageRoute<dynamic>(
          builder: (c) => ProveWebView(
            sessionId: sessionId,
            onSuccess: onSuccess,
            onEvent: onEvent,
            onClose: onClose,
            reference: reference,
            showLogs: showLogs,
          ),
        ),
      );
    }
  }
}
