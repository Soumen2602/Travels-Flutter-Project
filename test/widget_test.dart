import 'package:flutter_test/flutter_test.dart';
import 'package:grb_travels/main.dart';

void main() {
  testWidgets('app title is configured', (tester) async {
    await tester.pumpWidget(const GrbTravelsApp());
    expect(find.byType(GrbTravelsApp), findsOneWidget);
  });
}
