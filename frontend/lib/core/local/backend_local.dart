// Inicia el backend que acompaña a la aplicación de escritorio.
// En la web y en móvil no existe: `iniciarBackendLocal()` devuelve null.
export 'backend_local_base.dart';
export 'backend_local_stub.dart' if (dart.library.io) 'backend_local_io.dart';
