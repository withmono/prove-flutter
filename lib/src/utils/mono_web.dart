import 'dart:js_interop';
import 'dart:js_util' as js_util;

/// Interop with the global [MonoProve] JavaScript object.
@JS('MonoProve')
@staticInterop
class MonoProve {
  external static void setup(JSAny? obj);

  external static void open();
}

/// Interop with the global [setupMonoProve] function.
@JS('setupMonoProve')
external void setupMonoProve(String requestId, JSObject? config);

dynamic jsToDart(Object data) {
  try {
    return js_util.dartify(data);
  } catch (e) {
    throw Exception('Unable to convert JS object to Dart: $e');
  }
}
