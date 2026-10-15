import 'package:flutter_test/flutter_test.dart';
import 'package:metrixvox_app/main.dart';

void main() {
  testWidgets('Muestra la pantalla de configuración del dispositivo', (WidgetTester tester) async {
    await tester.pumpWidget(const MetrixVoxApp());

    expect(find.text('Configuración de Dispositivo'), findsOneWidget);
    expect(find.text('Iniciar Cuestionario'), findsOneWidget);
    expect(find.text('Ver Dashboard'), findsOneWidget);
  });
}
