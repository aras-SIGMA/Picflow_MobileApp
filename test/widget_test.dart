import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picflow_mobile/main.dart';

void main() {
  testWidgets('PicFlow boot screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PicFlowApp(),
      ),
    );

    // Verify presence of brand title elements
    expect(find.text('Pic'), findsOneWidget);
    expect(find.text('Flow'), findsOneWidget);
    expect(find.text('Curated Photography Community'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
