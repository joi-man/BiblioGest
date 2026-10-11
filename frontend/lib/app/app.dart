import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/modo_tema_provider.dart';
import '../features/actualizaciones/presentation/widgets/guardia_actualizacion.dart';
import '../core/theme/tema_app.dart';
import '../features/auth/presentation/widgets/guardia_cierre_ventana.dart';
import 'router.dart';

/// Raíz de la aplicación: conecta el router, el tema y la localización.
class BiblioGestApp extends ConsumerWidget {
  const BiblioGestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modoTema = ref.watch(modoTemaProvider);

    return MaterialApp.router(
      title: 'BiblioGest',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.claro,
      darkTheme: TemaApp.oscuro,
      themeMode: modoTema,
      routerConfig: appRouter,
      builder: (context, child) => GuardiaCierreVentana(
        navegadorKey: navegadorRaizKey,
        child: GuardiaActualizacion(child: child ?? const SizedBox.shrink()),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
    );
  }
}
