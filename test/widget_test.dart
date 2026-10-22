import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:volunteerconnect/main.dart';
import 'package:volunteerconnect/services/app_state_provider.dart';

void main() {
  testWidgets('App launches with Welcome Screen and tagline', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ],
        child: const VolunteerConnectApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('VolunteerConnect'), findsOneWidget);
    expect(find.text('Small Actions. Meaningful Change.'), findsOneWidget);
    expect(find.text('Sign In as Volunteer'), findsOneWidget);
    expect(find.text('Sign In as NGO / Organization'), findsOneWidget);
  });
}
