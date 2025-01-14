import 'package:equatable/equatable.dart';

class EventData extends Equatable {
  const EventData({
    required this.timestamp,
    this.reference,
    this.pageName,
    this.errorType,
    this.errorMessage,
    this.reason,
  });

  /// reference passed through the connect config
  final String? reference;

  /// name of page the widget exited on
  final String? pageName;

  /// error thrown by widget
  final String? errorType;

  /// error message describing the error
  final String? errorMessage;

  final String? reason;

  /// datetime representation of the event timestamp
  final DateTime timestamp;

  EventData.fromMap(Map<String, dynamic> map)
      : reference = map['reference'] as String?,
        pageName = map['pageName'] as String?,
        errorType = map['errorType'] as String?,
        errorMessage = map['errorMessage'] as String?,
        reason = map['reason'] as String?,
        timestamp = map['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
            : DateTime.now();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
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
      reference,
      pageName,
      errorType,
      errorMessage,
      reason,
      timestamp
    ];
  }

  @override
  String toString() =>
      'EventData(reference: $reference, pageName: $pageName, errorType: $errorType, errorMessage: $errorMessage, reason: $reason, timestamp: $timestamp)';
}
