import 'package:fitgame_app/main.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders splash entry', (tester) async {
    app.main();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('FitGame'), findsOneWidget);
    expect(find.text('开始创建角色'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
