import 'package:mono_prove/src/constants.dart';
import 'package:mono_prove/src/utils/extensions.dart';

/// Events dispatched by the Mono Prove Widget
enum EventType {
  /// ["mono.prove.widget_opened"] Triggered when the user opens the Prove Widget.
  opened(Constants.OPENED_EVENT),

  /// ["mono.prove.widget.closed"] Triggered when the user closes the Prove Widget.
  closed(Constants.CLOSED_EVENT),

  /// ["mono.prove.identity_verified"] Triggered when the user successfully verifies their identity.
  identityVerified(Constants.VERIFIED_EVENT),

  /// ["mono.prove.error_occurred"] ERROR	Triggered when the widget reports an error.
  error(Constants.ERROR_EVENT),

  /// An unexpected event
  unknown(Constants.UNKNOWN);

  const EventType(this.value);

  final String value;

  /// Convert a string value to a Prove event
  static EventType fromValue(String value) {
    final type = EventType.values.firstWhereOrNull((e) => e.value == value);

    return type ?? EventType.unknown;
  }
}
