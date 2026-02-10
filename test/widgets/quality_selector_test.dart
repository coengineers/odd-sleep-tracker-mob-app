import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleeplog/theme/app_theme.dart';
import 'package:sleeplog/widgets/quality_selector.dart';

void main() {
  Widget buildWidget({int? value, ValueChanged<int>? onChanged}) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: QualitySelector(
            value: value,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders 5 items with numbers 1–5', (tester) async {
    await tester.pumpWidget(buildWidget());

    for (var i = 1; i <= 5; i++) {
      expect(find.text('$i'), findsOneWidget);
    }
  });

  testWidgets('tapping item 3 calls onChanged(3)', (tester) async {
    int? tappedValue;
    await tester.pumpWidget(
      buildWidget(onChanged: (v) => tappedValue = v),
    );

    await tester.tap(find.text('3'));
    expect(tappedValue, 3);
  });

  testWidgets('selected item (value=4) has primary colour', (tester) async {
    await tester.pumpWidget(buildWidget(value: 4));

    // Find the Container for item 4 — it should have the primary colour fill
    final containers = tester.widgetList<Container>(find.byType(Container));
    final primaryColor = AppTheme.dark.colorScheme.primary;

    bool foundSelectedWithPrimary = false;
    for (final container in containers) {
      final decoration = container.decoration;
      if (decoration is BoxDecoration && decoration.color == primaryColor) {
        foundSelectedWithPrimary = true;
        break;
      }
    }
    expect(foundSelectedWithPrimary, isTrue);
  });

  testWidgets('no item selected when value=null', (tester) async {
    await tester.pumpWidget(buildWidget(value: null));

    // No container should have primary colour
    final containers = tester.widgetList<Container>(find.byType(Container));
    final primaryColor = AppTheme.dark.colorScheme.primary;

    for (final container in containers) {
      final decoration = container.decoration;
      if (decoration is BoxDecoration) {
        expect(decoration.color, isNot(primaryColor));
      }
    }
  });

  testWidgets('each item has semantic label', (tester) async {
    await tester.pumpWidget(buildWidget(value: 3));

    for (var i = 1; i <= 5; i++) {
      expect(
        find.bySemanticsLabel(RegExp('Quality $i of 5')),
        findsOneWidget,
      );
    }
  });
}
