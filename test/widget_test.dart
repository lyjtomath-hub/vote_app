import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vote_app/main.dart';
import 'package:vote_app/firebase_options.dart';

void main() {
  // 테스트용 바인딩 초기화
  TestWidgetsFlutterBinding.ensureInitialized();

  // 테스트 시작 전에 Firebase 초기화
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('앱이 제대로 뜨는지 확인', (WidgetTester tester) async {
    // VoteApp 위젯을 로드
    await tester.pumpWidget(const VoteApp());

    // VoteApp 이 하나 보이는지 검사
    expect(find.byType(VoteApp), findsOneWidget);
  });
}
