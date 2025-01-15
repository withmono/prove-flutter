import 'package:equatable/equatable.dart';
import 'package:mono_prove/src/constants.dart';
import 'package:mono_prove/src/models/event_data.dart';
import 'package:mono_prove/src/models/event_type.dart';

/// Represents an event dispatched by the Mono Prove Widget.
class ProveEvent extends Equatable {
  /// Creates a [ProveEvent] with the given [type] and [data].
  const ProveEvent({required this.type, required this.data});

  /// Creates a [ProveEvent] instance from a [Map].
  ProveEvent.fromMap(Map<String, dynamic> map)
      : type = EventType.fromValue(map['type'] as String? ?? Constants.UNKNOWN),
        data = EventData.fromMap(map['data'] as Map<String, dynamic>? ?? {});

  /// The type of the event, represented by an [EventType].
  final EventType type;

  /// The data associated with the event, encapsulated in an [EventData] object.
  final EventData data;

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
