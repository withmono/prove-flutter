import 'package:equatable/equatable.dart';

class ProveEventData extends Equatable {
  const ProveEventData({
    required this.eventType,
    required this.timestamp,
    this.reference,
    this.pageName,
    this.errorType,
    this.errorMessage,
    this.reason,
  });

  /// Creates an [ProveEventData] instance from a [Map].
  ///
  /// If a `timestamp` is provided, it is parsed as milliseconds since epoch.
  /// Defaults to the current time if `timestamp` is absent.
  ProveEventData.fromMap(Map<String, dynamic> map)
      : eventType = map['type'] as String? ?? 'UNKNOWN',
        reference = map['reference'] as String?,
        pageName = map['pageName'] as String?,
        errorType = map['errorType'] as String?,
        errorMessage = map['errorMessage'] as String?,
        reason = map['reason'] as String?,
        timestamp = map['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
            : DateTime.now();

  /// The type of event, typically following the format `mono.prove.xxxx`.
  final String eventType;

  /// An optional reference passed through the config or returned from the widget.
  final String? reference;

  /// The name of the page where the widget exited.
  final String? pageName;

  /// The type of error thrown by the widget, if any.
  final String? errorType;

  /// A message describing the error thrown, if any.
  final String? errorMessage;

  /// The reason for the event, providing additional context when available.
  final String? reason;

  /// The timestamp of the event as a [DateTime] object.
  final DateTime timestamp;

  /// Converts the [ProveEventData] instance to a [Map].
  ///
  /// The `timestamp` is represented as milliseconds since epoch.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': eventType,
      'reference': reference,
      'pageName': pageName,
      'errorType': errorType,
      'errorMessage': errorMessage,
      'reason': reason,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props {
    return <Object?>[
      eventType,
      reference,
      pageName,
      errorType,
      errorMessage,
      reason,
      timestamp,
    ];
  }

  @override
  String toString() =>
      'ProveEventData(eventType: $eventType, reference: $reference, pageName: $pageName, errorType: $errorType, errorMessage: $errorMessage, reason: $reason, timestamp: $timestamp)';
}
