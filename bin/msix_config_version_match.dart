import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

final matchMsixVersion = RegExp(
  r'^(\s*msix_version:\s*)(\d+\.\d+\.\d+)\.(\d+)(.*)$',
);

Future<void> main(List<String> arguments) async {
  if (arguments.length > 1) {
    throw ArgumentError(
      'Invalid usage. Has one optional argument of the pubspec.yaml file',
      arguments.toString(),
    );
  }
  //Try to get yaml
  File projectPubspec = File(
    arguments.isNotEmpty ? arguments.first : 'pubspec.yaml',
  );

  if (!projectPubspec.existsSync()) {
    throw FileSystemException(
      'Could not find pubspec.yaml',
      projectPubspec.path,
    );
  }

  String yaml = projectPubspec.readAsStringSync();

  final pubspec = Pubspec.parse(yaml, sourceUrl: projectPubspec.uri);

  if (pubspec.version == null) {
    throw FormatException('Could not parse version from pubspec.yaml');
  }

  Version pubspecVersion = pubspec.version!;

  // Just do a hack replace
  // - find a line with "msix_version: #.#.#.#"
  // - Then replace it

  final pubspecLines = projectPubspec.readAsLinesSync();

  // Find version line
  final msixVersionLine = pubspecLines.singleWhere(
    (e) => matchMsixVersion.hasMatch(e),
  );
  print('Existing MSIX version: $msixVersionLine');
  // Parse version line
  final matchMsix = matchMsixVersion.firstMatch(msixVersionLine)!;
  String assignPart = matchMsix.group(1)!;
  String semverPart = matchMsix.group(2)!;
  int fourthPart = int.parse(matchMsix.group(3)!);
  String trailPart = matchMsix.group(4)!;

  // Determine new version line
  String pubspecStdSemver = [
    pubspecVersion.major,
    pubspecVersion.minor,
    pubspecVersion.patch,
  ].join('.');

  late String newVersion;
  if (semverPart == pubspecStdSemver) {
    ++fourthPart;
    newVersion = '$semverPart.$fourthPart';
  } else {
    newVersion = '$pubspecStdSemver.0';
  }
  final newMsixLine = '$assignPart$newVersion$trailPart';

  print('New MSIX version: $newVersion');

  //Write out file
  final out = projectPubspec.openWrite();
  for (final line in pubspecLines) {
    if (line == msixVersionLine) {
      out.writeln(newMsixLine);
    } else {
      out.writeln(line);
    }
  }
  await out.flush();
  await out.close();
}
