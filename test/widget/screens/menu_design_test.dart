import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../../lib/themes/colors.dart';
import '../../../lib/widgets/menu_design.dart';

void main() {
  testWidgets('MenuDesign deve renderizar elementos principais do MenuDesign', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MenuDesign(
          titleText: 'TituloTeste',
          headerText: 'HeaderTeste',
          child: Text('ConteudoTeste'),
          showSun: false, // para evitar dependência do asset
          background: null,
        ),
      ),
    );
    expect(find.text('TituloTeste'), findsOneWidget);
    expect(find.text('HeaderTeste'), findsOneWidget);
    expect(find.text('ConteudoTeste'), findsOneWidget);
  });

  testWidgets(
    'MenuDesign deve executar callback de onHomePressed ao clicar no botao home',
    (WidgetTester tester) async {
      bool clicouHome = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MenuDesign(
            titleText: 'TituloTeste',
            child: Text('ConteudoTeste'),
            showHomeButton: true,
            showSun: false, // evita asset
            background: null,
            onHomePressed: () => clicouHome = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.home));
      await tester.pump();
      expect(clicouHome, isTrue);
    },
  );
}
