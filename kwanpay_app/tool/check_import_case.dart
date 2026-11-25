// Fails when an import's path differs in letter case from the file on disk.
//
// Windows and default macOS file systems ignore case, so such imports work
// locally but break builds on Linux CI. Run: dart run tool/check_import_case.dart
import 'dart:io';

final _directive = RegExp(r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''');

void main() {
  final root = Directory('lib');
  final files = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // Exact-case set of every Dart file under lib/, as package-relative paths.
  final known = {
    for (final f in files) f.uri.pathSegments.skipWhile((s) => s != 'lib').skip(1).join('/'),
  };

  var problems = 0;
  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final match = _directive.firstMatch(lines[i]);
      if (match == null) continue;
      final target = match.group(1)!;

      String? resolved;
      if (target.startsWith('package:kwanpay_app/')) {
        resolved = target.substring('package:kwanpay_app/'.length);
      } else if (!target.contains(':')) {
        final from = file.uri.pathSegments.skipWhile((s) => s != 'lib').skip(1).toList()
          ..removeLast();
        final parts = [...from];
        for (final segment in target.split('/')) {
          if (segment == '..') {
            if (parts.isNotEmpty) parts.removeLast();
          } else if (segment != '.') {
            parts.add(segment);
          }
        }
        resolved = parts.join('/');
      }

      if (resolved != null && !known.contains(resolved)) {
        problems++;
        stderr.writeln('${file.path}:${i + 1}: "$target" does not match a file with that exact case');
      }
    }
  }

  if (problems > 0) {
    stderr.writeln('$problems import(s) with mismatched case.');
    exit(1);
  }
  stdout.writeln('All ${files.length} files: import paths match on-disk case.');
}
