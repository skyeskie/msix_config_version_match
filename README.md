# msix_config_version_parse

## Description

The [msix](https://pub.dev/packages/msix) package requires and installer version separate from the main pubspec version.
This utility copies the pubspec version to that `msix_version`.

It is assumed that the pubspec version is using semantic versioning ([semver]).

The `msix_version` is 4 digits, whereas normal semver is 3 with optional miscellaneous additions. The mapping follows
the following rules:

- The number should increase*
- x.y.z maps directly to x.y.z.0 if the first 3 numbers are different
- If the first 3 numbers match, the existing fourth number is incremented

Examples:

| Pubspec Version | Existing msix_version | New msix_version |
| --------------- | --------------------- | ---------------- |
| 0.1.2           | 0.1.1.23              | 0.1.2.0          |
| 1.2.3-alpha+43  | 1.2.3.42              | 1.2.3.43         |
| 1.2.3-alpha+10  | 1.2.3.42              | 1.2.3.43         |
| 1.2.3-alpha.12  | 1.2.3.0               | 1.2.3.1          |
| 1.2.3           | 1.2.3.12              | 1.2.3.13         |

* Note: If the parts of the semver x, y, z decrease, this *will ignore* that decrease and follow it.
The check on increasing is only for the same semver.

## Install

Add to dev-dependencies

## Usage

`dart pub run msix_config_version_match [pubspec.yaml]`

or

`flutter pub run msix_config_version_match [pubspec.yaml]`

You can optionally specify a single argument - the path to the `pubspec.yaml`
file. It defaults to `pubspec.yaml` file in the current working directory.

[semver](https://semver.org)
