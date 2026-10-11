import 'package:flutter/foundation.dart';

/// Indica si la aplicación corre en un teléfono o tableta (Android o iOS).
bool get esDispositivoMovil =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Permite probar la vista de estudiante en web o escritorio durante el
/// desarrollo: `flutter run -d chrome --dart-define=PERMITIR_ESTUDIANTE_EN_ESCRITORIO=true`.
const bool _permitirEstudianteEnEscritorio =
    bool.fromEnvironment('PERMITIR_ESTUDIANTE_EN_ESCRITORIO');

/// Los estudiantes solo usan la aplicación desde el móvil.
bool get estudiantePuedeUsarEstaPlataforma =>
    esDispositivoMovil || _permitirEstudianteEnEscritorio;
