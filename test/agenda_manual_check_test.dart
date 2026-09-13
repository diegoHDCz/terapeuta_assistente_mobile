import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terapeuta_assistente_mobile/core/theme/theme.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/pages/agenda_page.dart';
import 'package:terapeuta_assistente_mobile/features/agenda/presentation/widgets/agenda_week_strip.dart';

Future<void> _pumpAgenda(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    builder: EasyLoading.init(),
    home: const AgendaPage(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('free consultation flow registers a brand-new name as a lead', (tester) async {
    await _pumpAgenda(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('O que deseja marcar?'), findsOneWidget);

    await tester.tap(find.text('Consulta gratuita'));
    await tester.pumpAndSettle();
    expect(find.text('Nova consulta gratuita'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('Nome novo? A pessoa é registrada como lead ao marcar.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Teste Lead');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Marcar consulta gratuita'));
    await tester.pumpAndSettle();

    expect(find.text('Teste Lead'), findsOneWidget);
    expect(find.text('Gratuita'), findsOneWidget);
  });

  testWidgets('regular session rejects a name that is not an existing patient', (tester) async {
    await _pumpAgenda(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova sessão').last);
    await tester.pumpAndSettle();
    expect(find.text('Paciente'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Pessoa Desconhecida');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Marcar sessão'));
    await tester.pumpAndSettle();

    expect(find.text('Paciente não cadastrado — use consulta gratuita para novos contatos'), findsOneWidget);
  });

  testWidgets('swipe right confirms a pending appointment, swipe left deletes it', (tester) async {
    await _pumpAgenda(tester);

    expect(find.text('Bruno Lima'), findsOneWidget);
    expect(find.text('Pendente'), findsNWidgets(2));

    await tester.drag(
      find.ancestor(of: find.text('Bruno Lima'), matching: find.byType(Dismissible)),
      const Offset(400, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pendente'), findsNWidgets(1));
    expect(find.text('Confirmada'), findsNWidgets(2));

    await tester.drag(
      find.ancestor(of: find.text('Bruno Lima'), matching: find.byType(Dismissible)),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Bruno Lima'), findsNothing);
  });

  testWidgets('long-press opens the quick-actions sheet without any menu icon on the card', (tester) async {
    await _pumpAgenda(tester);

    expect(find.byIcon(Icons.more_vert), findsNothing);

    await tester.longPress(find.text('Carla Menezes'));
    await tester.pumpAndSettle();

    expect(find.text('Cancelar sessão'), findsOneWidget);
    await tester.tap(find.text('Cancelar sessão'));
    await tester.pumpAndSettle();

    expect(find.text('Cancelada'), findsOneWidget);
  });

  testWidgets('blocking a day with existing sessions warns, then guards the FAB until unblocked', (tester) async {
    await _pumpAgenda(tester);

    await tester.tap(find.byTooltip('Bloquear este dia'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bloquear impede novos agendamentos'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Bloquear'));
    await tester.pumpAndSettle();

    expect(find.text('Agenda bloqueada — novos agendamentos desativados neste dia.'), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('O que deseja marcar?'), findsNothing);

    await tester.tap(find.text('Desbloquear'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('O que deseja marcar?'), findsOneWidget);
  });

  testWidgets('blocking an empty day shows the blocked state instead of the empty state', (tester) async {
    await _pumpAgenda(tester);

    // All seeded appointments fall within [today - 1, today + 2]. Next
    // week's Monday can still land inside that range depending on today's
    // weekday, so pick next week's last day (Sunday) — always far enough
    // out — instead of driving the native date-picker grid.
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AgendaWeekStrip), matching: find.byType(AnimatedContainer)).last);
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma sessão neste dia'), findsOneWidget);

    await tester.tap(find.byTooltip('Bloquear este dia'));
    await tester.pumpAndSettle();

    expect(find.text('Agenda bloqueada neste dia'), findsOneWidget);
    expect(find.text('Nenhuma sessão neste dia'), findsNothing);

    await tester.tap(find.text('Desbloquear este dia'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma sessão neste dia'), findsOneWidget);
  });
}
