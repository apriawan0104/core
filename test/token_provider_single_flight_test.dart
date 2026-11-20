import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('concurrent token reads share one provider refresh', () async {
    final auth = GateAuthenticationService();
    final provider = TokenProviderServiceImpl(
      authService: auth,
      secureStorage: MemoryStorage(),
    );

    final first = provider.getAccessToken();
    final second = provider.getAccessToken();
    await pumpEventQueue();
    expect(auth.refreshCalls, 1);

    auth.release.complete();
    final results = await Future.wait([first, second]);
    final tokens = [
      for (final result in results) result.fold((_) => null, (token) => token),
    ];
    expect(tokens, ['token-1', 'token-1']);
  });
}
