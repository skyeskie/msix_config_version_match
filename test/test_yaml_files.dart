import 'dart:io';

import 'package:test/test.dart';

import '../bin/msix_config_version_match.dart' as cmd;

const testFileNames = [
  'diff_semver',
  'full_flutter',
  'minimal',
];

void main() {
  setUpAll(() => {Directory.current = './test/yaml_files'});

  for (final name in testFileNames) {
    final baseFile = File('$name.yaml');
    final targetFile = File('$name.target.yaml');
    final testFileName = '$name.test.yaml';

    test('File case: $name', () async {
      print('Copy file for testing: $testFileName');
      baseFile.copySync(testFileName);
      print('Execute program');
      await cmd.main([testFileName]);
      final testFile = File(testFileName);

      print('Loading contents for comparison');
      final processedContents = testFile.readAsStringSync();
      final targetContents = targetFile.readAsStringSync();

      expect(processedContents, equals(targetContents));

      testFile.deleteSync();
    });
  }
}
