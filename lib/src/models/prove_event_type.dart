import 'package:mono_prove/src/utils/constants.dart';
import 'package:mono_prove/src/utils/extensions.dart';

/// Event types dispatched by the Mono Prove Widget.
enum ProveEventType {
  /// Triggered when the user opens the Prove Widget.
  /// Event value: ["mono.prove.widget_opened"].
  opened(Constants.OPENED_EVENT),

  /// Triggered when the user closes the Prove Widget.
  /// Event value: ["mono.prove.widget.closed"].
  closed(Constants.CLOSED_EVENT),

  /// Triggered when the user successfully verifies their identity.
  /// Event value: ["mono.prove.identity_verified"].
  identityVerified(Constants.VERIFIED_EVENT),

  /// Triggered when the widget reports an error.
  /// Event value: ["mono.prove.error_occurred"].
  error(Constants.ERROR_EVENT),

  /// Represents an unexpected or unknown event.
  /// Event value: [Constants.UNKNOWN].
  unknown(Constants.UNKNOWN);

  const ProveEventType(this.value);

  /// The string representation of the event type.
  final String value;

  /// Converts a string value to a corresponding [ProveEventType].
  ///
  /// If the value does not match any known [ProveEventType],
  /// [ProveEventType.unknown] is returned.
  static ProveEventType fromValue(String value) {
    final type = ProveEventType.values.firstWhereOrNull((e) => e.value == value);

    return type ?? ProveEventType.unknown;
  }
}
