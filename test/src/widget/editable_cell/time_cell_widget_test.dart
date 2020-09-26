import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoStateManager();
    when(stateManager.configuration).thenReturn(PlutoConfiguration());
  });

  testWidgets('셀 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final PlutoCell cell = PlutoCell(value: '12:30');

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TimeCellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
          ),
        ),
      ),
    );

    // then
    expect(find.text('12:30'), findsOneWidget);
  });

  group('수정 가능 상태인 경우', () {
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final PlutoCell cell = PlutoCell(value: '12:30');

    final tapCell = PlutoWidgetTestHelper('Tap cell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: TimeCellWidget(
              stateManager: stateManager,
              cell: cell,
              column: column,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
    });

    tapCell.test('hour, minute 컬럼이 호출 되어야 한다.', (tester) async {
      expect(find.text('hour'), findsOneWidget);
      expect(find.text('minute'), findsOneWidget);
    });

    tapCell.test('10:30 분 선택.', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '10:30')).called(1);
    });

    tapCell.test('15:30 분 선택.', (tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);

      verify(stateManager.handleAfterSelectingRow(cell, '15:30')).called(1);
    });

    tapCell.test('12:29 분 선택.', (tester) async {

      await tester.tap(find.text('29'));
      await tester.tap(find.text('29'));

      verify(stateManager.handleAfterSelectingRow(cell, '12:29')).called(1);
    });
  });
}