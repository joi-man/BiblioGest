import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/actualizador_personal.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/dashboard/data/models/resumen_dashboard.dart';

void main() {
  testWidgets('el personal vuelve a pedir los datos cada cierto tiempo', (tester) async {
    var pedidos = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resumenDashboardProvider.overrideWith((ref) async {
            pedidos++;
            return null as ResumenDashboard?;
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(resumenDashboardProvider);
            return const ActualizadorPersonal(
              periodo: Duration(seconds: 5),
              hijo: SizedBox(),
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(pedidos, 1);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump();
    expect(pedidos, 2);

    await tester.pumpWidget(const SizedBox()); // libera el temporizador
  });
}
