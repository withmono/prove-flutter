import 'package:equatable/equatable.dart';
import 'package:mono_prove/src/constants.dart';
import 'package:mono_prove/src/models/event_data.dart';
import 'package:mono_prove/src/models/event_type.dart';

class ProveEvent extends Equatable {
  ProveEvent({required this.type, required this.data});

  final EventType type;

  final EventData data;

  ProveEvent.fromMap(Map<String, dynamic> map)
      : type =
            EventType.fromValue(map['type'] as String? ?? Constants.UNKNOWN),
        data = EventData.fromMap(map['data'] as Map<String, dynamic>? ?? {});

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
