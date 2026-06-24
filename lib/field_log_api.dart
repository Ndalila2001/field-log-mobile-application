import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'field_log_entry.dart';

class FieldLogApi {
  static Future<Set<String>> syncLogs(List<FieldLogEntry> logs) async {
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    final uri = Uri.parse('http://$host:3000/api/logs/sync');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'logs': logs.map((log) => log.toJson()).toList()}),
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('API returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return (decoded['syncedIds'] as List<dynamic>).cast<String>().toSet();
  }
}
