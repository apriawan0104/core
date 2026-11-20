import 'dart:io';

import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  test('a 401 refreshes once and recalls the same endpoint', () async {
    final requests = <String?>[];
    final server = await _server((request) async {
      requests.add(request.headers.value('authorization'));
      final fresh = request.headers.value('authorization') == 'Bearer fresh';
      request.response.statusCode = fresh ? 200 : 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write(fresh ? '{"ok":true}' : '{}');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = _client(server);
    var recoveries = 0;
    client.setUnauthorizedRecovery((url, rejected) async {
      recoveries++;
      expect(url, contains('/items'));
      expect(rejected, 'old');
      return 'fresh';
    });

    final result = await client.get<Map<String, dynamic>>(
      '/items',
      headers: {'Authorization': 'Bearer old'},
    );

    expect(recoveries, 1);
    expect(requests, ['Bearer old', 'Bearer fresh']);
    expect(result.isRight(), isTrue);
  });

  test('a failed refresh keeps the 401', () async {
    var hits = 0;
    final server = await _server((request) async {
      hits++;
      request.response.statusCode = 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{}');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = _client(server);
    client.setUnauthorizedRecovery((_, __) async => null);

    final result = await client.get<Map<String, dynamic>>('/items');

    expect(hits, 1);
    expect(
      result.fold((failure) => failure, (_) => null),
      isA<UnauthorizedFailure>(),
    );
  });

  test('a second 401 is not refreshed again', () async {
    var hits = 0;
    final server = await _server((request) async {
      hits++;
      request.response.statusCode = 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{}');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = _client(server);
    var recoveries = 0;
    client.setUnauthorizedRecovery((_, __) async {
      recoveries++;
      return 'fresh';
    });

    final result = await client.get<Map<String, dynamic>>('/items');

    expect(recoveries, 1);
    expect(hits, 2);
    expect(
      result.fold((failure) => failure, (_) => null),
      isA<UnauthorizedFailure>(),
    );
  });

  test('a stale 401 retries with the newer cached token without refreshing',
      () async {
    final auth = GateAuthenticationService()..release.complete();
    final storage = MemoryStorage({
      'auth_access_token': 'old',
      'auth_token_expiry': '2030-01-01T00:00:00.000Z',
    });
    final provider = TokenProviderServiceImpl(
      authService: auth,
      secureStorage: storage,
    );
    final requests = <String?>[];
    final server = await _server((request) async {
      final header = request.headers.value('authorization');
      requests.add(header);
      if (header == 'Bearer old') {
        // Another request refreshed the token while this one was in flight.
        storage.values['auth_access_token'] = 'fresh';
      }
      request.response.statusCode = header == 'Bearer fresh' ? 200 : 401;
      request.response.headers.contentType = ContentType.json;
      request.response.write('{}');
      await request.response.close();
    });
    addTearDown(server.close);

    final client = _client(server);
    attachBearerAuth(client, provider);

    final result = await client.get<Map<String, dynamic>>('/items');

    expect(requests, ['Bearer old', 'Bearer fresh']);
    expect(auth.refreshCalls, 0);
    expect(result.isRight(), isTrue);
  });
}

DioHttpClient _client(HttpServer server) {
  return DioHttpClient(
    baseUrl: 'http://${server.address.host}:${server.port}',
  );
}

Future<HttpServer> _server(
  Future<void> Function(HttpRequest request) handle,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen(handle);
  return server;
}
