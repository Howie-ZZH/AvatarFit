import 'package:fitgame_app/src/app/fit_game_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders FitGame onboarding', (tester) async {
    await tester.pumpWidget(const FitGameApp());
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('FitGame'), findsOneWidget);
    expect(find.text('开始创建角色'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
