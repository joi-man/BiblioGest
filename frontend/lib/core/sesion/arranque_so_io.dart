import 'dart:ffi';
import 'dart:io';

typedef _TicksNativo = Uint64 Function();
typedef _Ticks = int Function();

/// Instante (ms desde epoch) en que arrancó Windows, o `null` en otros sistemas
/// o si no se pudo consultar. Sirve para saber si el equipo se reinició.
Future<int?> instanteArranqueSo() async {
  if (!Platform.isWindows) return null;
  try {
    final ticks = DynamicLibrary.open('kernel32.dll').lookupFunction<_TicksNativo, _Ticks>('GetTickCount64');
    return DateTime.now().millisecondsSinceEpoch - ticks();
  } catch (_) {
    return null;
  }
}
