import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/errors/app_failure.dart';
import '../domain/cat_fact.dart';
import '../domain/facts_repository.dart';

/// Owns transport and JSON validation; presentation never sees HTTP or maps.
final class CatFactApi {
  CatFactApi({
    required this._client,
    this.timeout = const Duration(seconds: 12),
  });

  final http.Client _client;
  final Duration timeout;

  Future<FactsPage> fetchPage({required int page}) async {
    final uri = Uri.https('catfact.ninja', '/facts', {
      'page': '$page',
      'limit': '12',
    });
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw const AppFailure(
          FailureKind.server,
          'The fact library is unavailable. Please try again.',
        );
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic> ||
          json['data'] is! List ||
          json['current_page'] is! int ||
          json['last_page'] is! int ||
          json['current_page'] != page ||
          (json['last_page'] as int) < page) {
        throw const FormatException('Invalid page envelope');
      }
      final facts = <CatFact>[];
      for (final item in json['data'] as List<dynamic>) {
        if (item is! Map<String, dynamic> ||
            item['fact'] is! String ||
            (item['fact'] as String).trim().isEmpty) {
          throw const FormatException('Invalid fact');
        }
        facts.add(CatFact.fromText(item['fact'] as String));
      }
      return FactsPage(
        facts: facts,
        nextPage: page < (json['last_page'] as int) ? page + 1 : null,
      );
    } on AppFailure {
      rethrow;
    } on TimeoutException {
      throw const AppFailure(
        FailureKind.network,
        'The request took too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const AppFailure(
        FailureKind.network,
        'Unable to connect. Your saved facts are still available in Favorites.',
      );
    } on FormatException {
      throw const AppFailure(
        FailureKind.invalidData,
        'The server returned an unreadable response. Please try again later.',
      );
    }
  }
}
