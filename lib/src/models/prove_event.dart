import 'package:equatable/equatable.dart';
import 'package:mono_prove/src/models/prove_event_data.dart';
import 'package:mono_prove/src/models/prove_event_type.dart';
import 'package:mono_prove/src/utils/constants.dart';

/// Represents an event dispatched by the Mono Prove Widget.
class ProveEvent extends Equatable {
  /// Creates a [ProveEvent] with the given [type] and [data].
  const ProveEvent({required this.type, required this.data});

  /// Creates a [ProveEvent] instance from a [Map].
  ProveEvent.fromMap(Map<String, dynamic> map)
      : type = ProveEventType.fromValue(
          map['type'] as String? ?? (map['data'] as Map?)?['type'] as String? ?? Constants.UNKNOWN,
        ),
        data = ProveEventData.fromMap(
          map['data'] as Map<String, dynamic>? ?? {},
        );

  /// The type of the event, represented by an [ProveEventType].
  final ProveEventType type;

  /// The data associated with the event, encapsulated in an [ProveEventData] object.
  final ProveEventData data;

  /// Converts the [ProveEvent] into a [Map] representation.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.value,
      'data': data.toMap(),
    };
  }

  @override
  List<Object?> get props => <Object?>[type, data];

  @override
  String toString() => 'ProveEvent(type: $type, data: $data)';
}
