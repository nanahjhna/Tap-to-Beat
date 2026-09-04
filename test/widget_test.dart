import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TapToBeat/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 빌드 및 앱 실행 확인 (초기 라우트는 로딩 화면)
    await tester.pumpWidget(const TapToBeatGameApp());

    // 로딩 화면의 스피너가 정상 렌더링되는지 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
