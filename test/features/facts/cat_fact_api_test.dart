import 'dart:async';
import 'dart:convert';

import 'package:cat_facts_mvi/core/errors/app_failure.dart';
import 'package:cat_facts_mvi/features/facts/data/cat_fact_api.dart';
import 'package:cat_facts_mvi/features/facts/domain/cat_fact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('stable identifiers normalize whitespace and case', () {
    expect(
      CatFact.fromText(' Cats  sleep. ').id,
      CatFact.fromText('cats sleep.').id,
    );
    expect(
      CatFact.fromText('Cats sleep.').id,
      isNot(CatFact.fromText('Cats play.').id),
    );
  });

  test('requests HTTPS and maps a validated paginated response', () async {
    final client = MockClient((request) async {
      expect(request.url.scheme, 'https');
      expect(request.url.host, 'catfact.ninja');
      expect(request.url.queryParameters, {'page': '2', 'limit': '12'});
      return http.Response(
        jsonEncode({
          'current_page': 2,
          'last_page': 3,
          'data': [
            {'fact': 'Cats sleep.'},
          ],
        }),
        200,
      );
    });
    addTearDown(client.close);
    final page = await CatFactApi(client: client).fetchPage(page: 2);
    expect(page.facts.single.text, 'Cats sleep.');
    expect(page.nextPage, 3);
    expect(() => page.facts.clear(), throwsUnsupportedError);
  });

  test('last page has no next page', () async {
    final client = MockClient(
      (_) async =>
          http.Response('{"current_page":1,"last_page":1,"data":[]}', 200),
    );
    addTearDown(client.close);
    expect(
      (await CatFactApi(client: client).fetchPage(page: 1)).nextPage,
      isNull,
    );
  });

  for (final body in [
    '<html>Unavailable</html>',
    '{"data":[]}',
    '{"current_page":1,"last_page":1,"data":[{"fact":12}]}',
    '{"current_page":1,"last_page":1,"data":[{"fact":"  "}]}',
  ]) {
    test('rejects malformed responses: $body', () async {
      final client = MockClient((_) async => http.Response(body, 200));
      addTearDown(client.close);
      await expectLater(
        CatFactApi(client: client).fetchPage(page: 1),
        throwsA(
          isA<AppFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.invalidData,
          ),
        ),
      );
    });
  }

  test('maps server failure without exposing response content', () async {
    final client = MockClient(
      (_) async => http.Response('internal server details', 503),
    );
    addTearDown(client.close);
    await expectLater(
      CatFactApi(client: client).fetchPage(page: 1),
      throwsA(
        isA<AppFailure>().having((e) => e.kind, 'kind', FailureKind.server),
      ),
    );
  });

  test('maps connection failures', () async {
    final client = MockClient(
      (_) async => throw http.ClientException('offline'),
    );
    addTearDown(client.close);
    await expectLater(
      CatFactApi(client: client).fetchPage(page: 1),
      throwsA(
        isA<AppFailure>().having((e) => e.kind, 'kind', FailureKind.network),
      ),
    );
  });

  test('maps timeouts', () async {
    final client = MockClient((_) async => throw TimeoutException('timeout'));
    addTearDown(client.close);
    await expectLater(
      CatFactApi(client: client).fetchPage(page: 1),
      throwsA(
        isA<AppFailure>().having((e) => e.kind, 'kind', FailureKind.network),
      ),
    );
  });
}
