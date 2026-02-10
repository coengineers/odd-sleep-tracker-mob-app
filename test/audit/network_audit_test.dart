import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Audit test that verifies zero network code exists in production sources.
///
/// This app is fully offline (SQLite via drift). Any network-capable code
/// in `lib/` or network-capable dependencies in `pubspec.yaml` would be a
/// policy violation.
void main() {
  /// Patterns in source files that indicate network usage.
  /// We allow `dart:io` itself (drift uses it for SQLite), but ban specific
  /// network classes from `dart:io`.
  final prohibitedSourcePatterns = <String, RegExp>{
    'HttpClient (dart:io)': RegExp(r'\bHttpClient\b'),
    'HttpServer (dart:io)': RegExp(r'\bHttpServer\b'),
    'Socket (dart:io)': RegExp(r'\bSocket\b'),
    'package:http import': RegExp(r'''import\s+['"]package:http[/'"]'''),
    'package:dio import': RegExp(r'''import\s+['"]package:dio[/'"]'''),
    'http:// URL literal': RegExp(r'''['"]https?://'''),
  };

  /// Runtime dependency names in pubspec.yaml that provide network access.
  final prohibitedDependencies = <String>[
    'http',
    'dio',
    'retrofit',
    'chopper',
    'graphql',
  ];

  test('lib/ contains no network code', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'lib/ directory must exist');

    final dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    final violations = <String>[];

    for (final file in dartFiles) {
      final content = file.readAsStringSync();

      // Strip single-line comments so that URLs in comments are not flagged.
      final lines = content.split('\n');
      final strippedLines = lines.map((line) {
        final commentIndex = line.indexOf('//');
        if (commentIndex >= 0) {
          return line.substring(0, commentIndex);
        }
        return line;
      });
      final strippedContent = strippedLines.join('\n');

      for (final entry in prohibitedSourcePatterns.entries) {
        final label = entry.key;
        final pattern = entry.value;

        if (pattern.hasMatch(strippedContent)) {
          violations.add('  ${file.path}: $label');
        }
      }
    }

    if (violations.isNotEmpty) {
      fail(
        'Network code found in production sources:\n${violations.join('\n')}',
      );
    }
  });

  test('pubspec.yaml contains no network-capable runtime dependencies', () {
    final pubspec = File('pubspec.yaml');
    expect(pubspec.existsSync(), isTrue, reason: 'pubspec.yaml must exist');

    final content = pubspec.readAsStringSync();

    // Extract only the `dependencies:` section (before `dev_dependencies:`).
    final depsSectionMatch = RegExp(
      r'^dependencies:\s*\n([\s\S]*?)(?=^dev_dependencies:|\Z)',
      multiLine: true,
    ).firstMatch(content);

    if (depsSectionMatch == null) {
      // No dependencies section at all — that is fine.
      return;
    }

    final depsSection = depsSectionMatch.group(1)!;
    final violations = <String>[];

    for (final dep in prohibitedDependencies) {
      // Match a dependency name at the start of an indented line, e.g.
      //   http: ^1.0.0
      //   dio:
      if (RegExp('^\\s+$dep:', multiLine: true).hasMatch(depsSection)) {
        violations.add('  $dep');
      }
    }

    if (violations.isNotEmpty) {
      fail(
        'Network-capable runtime dependencies found in pubspec.yaml:\n'
        '${violations.join('\n')}',
      );
    }
  });
}
