import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laantech_test/core/services/connectivity_provider.dart';
import 'package:laantech_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:laantech_test/features/transfer/presentation/widgets/pos_app_bar.dart';
import 'package:laantech_test/features/transfer/presentation/widgets/transfer_stat_card.dart';

class MockAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  MockAuthNotifier() : super(const AuthState(isAuthenticated: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('PosAppBar renders on narrow screens without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => Stream.value(true)),
          authNotifierProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            appBar: PosAppBar(
              title: 'POS File Catalog & Downloads',
            ),
          ),
        ),
      ),
    );

    expect(find.text('POS File Catalog & Downloads'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TransferStatCard renders on narrow screens without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 140,
            child: TransferStatCard(
              title: 'Active Transfers',
              value: '0',
              icon: Icons.sync,
              iconColor: Colors.blue,
              subtitle: 'Transfers finished',
            ),
          ),
        ),
      ),
    );

    expect(find.text('ACTIVE TRANSFERS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
