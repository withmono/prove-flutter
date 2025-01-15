import 'package:flutter/widgets.dart';
import 'package:mono_prove/src/models/prove_event.dart';

class ProveConfiguration {
  ProveConfiguration({
    required this.sessionId,
    required this.onSuccess,
    this.reference,
    this.onClose,
    this.onEvent,
  });

  /// The session ID for the current Mono Prove session.
  final String sessionId;

  /// Callback triggered when the user's identity has been successfully verified.
  final VoidCallback onSuccess;

  /// An optional reference to the current instance of Mono Prove.
  /// This value will be included in all [onEvent] callbacks for tracking purposes.
  final String? reference;

  /// Callback triggered when the Mono Prove widget is closed.
  final VoidCallback? onClose;

  /// Callback triggered whenever an event is dispatched by the Mono Prove widget.
  final void Function(ProveEvent)? onEvent;

  ProveConfiguration copyWith({
    String? reference,
    VoidCallback? onClose,
    void Function(ProveEvent)? onEvent,
  }) {
    return ProveConfiguration(
      sessionId: sessionId,
      onSuccess: onSuccess,
      reference: reference ?? this.reference,
      onClose: onClose ?? this.onClose,
      onEvent: onEvent ?? this.onEvent,
    );
  }
}
