import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';

/// The API has no identifiers. A text digest gives facts a stable identity
/// across pages and launches, without relying on Dart's process-local hashCode.
final class CatFact extends Equatable {
  const CatFact({required this.id, required this.text});

  factory CatFact.fromText(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return CatFact(
      id: sha256.convert(utf8.encode(cleaned.toLowerCase())).toString(),
      text: cleaned,
    );
  }

  final String id;
  final String text;

  @override
  List<Object> get props => [id, text];
}
