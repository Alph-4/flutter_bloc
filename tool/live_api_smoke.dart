import 'dart:io';

import 'package:cat_facts_mvi/features/facts/data/cat_fact_api.dart';
import 'package:http/http.dart' as http;

/// An opt-in external check, intentionally excluded from deterministic tests.
Future<void> main() async {
  final client = http.Client();
  try {
    final page = await CatFactApi(client: client).fetchPage(page: 1);
    if (page.facts.isEmpty) throw StateError('The live first page was empty.');
    stdout.writeln('Live API OK: ${page.facts.length} facts; next page: ${page.nextPage}.');
  } finally {
    client.close();
  }
}
