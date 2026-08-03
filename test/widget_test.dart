import 'package:flutter_test/flutter_test.dart';
import 'package:seismoalert/main.dart';

void main() {
  testWidgets('Smoke test verifying setup complete screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the setup complete message is present.
    expect(find.text('SeismoAlert - Setup Complete'), findsOneWidget);
  });
}
