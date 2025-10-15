// LICENSE: BSD-3-Clause License
// Original package: https://pub.dev/packages/source_gen
// Original source: https://github.com/dart-lang/source_gen

import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Returns what 'part "..."' URL is needed to import [output] from [input].
///
/// For example, will return `test_lib.g.dart` for `test_lib.dart`.
String computePartUrl(AssetId input, AssetId output) =>
    p.joinAll(p.split(p.relative(output.path, from: input.path)).skip(1));

/// Returns a URL representing [element].
String urlOfElement(Element element) => element.kind == ElementKind.DYNAMIC
    ? 'dart:core#dynamic'
    // using librarySource.uri – in case the element is in a part
    : normalizeUrl(
        element.library!.uri,
      ).replace(fragment: element.name).toString();

Uri normalizeUrl(Uri url) {
  switch (url.scheme) {
    case 'dart':
      return normalizeDartUrl(url);
    case 'package':
      return packageToAssetUrl(url);
    case 'file':
      return fileToAssetUrl(url);
    default:
      return url;
  }
}

/// Make `dart:`-type URLs look like a user-knowable path.
///
/// Some internal dart: URLs are something like `dart:core/map.dart`.
///
/// This isn't a user-knowable path, so we strip out extra path segments
/// and only expose `dart:core`.
Uri normalizeDartUrl(Uri url) => url.pathSegments.isNotEmpty
    ? url.replace(pathSegments: url.pathSegments.take(1))
    : url;

Uri fileToAssetUrl(Uri url) {
  if (!p.isWithin(p.current, url.path)) return url;
  return Uri(
    scheme: 'asset',
    path: p.join(rootPackageName, p.relative(url.path)),
  );
}

/// Returns a `package:` URL converted to a `asset:` URL.
///
/// This makes internal comparison logic much easier, but still allows users
/// to define assets in terms of `package:`, which is something that makes more
/// sense to most.
///
/// For example, this transforms `package:source_gen/source_gen.dart` into:
/// `asset:source_gen/lib/source_gen.dart`.
Uri packageToAssetUrl(Uri url) => url.scheme == 'package'
    ? url.replace(
        scheme: 'asset',
        pathSegments: <String>[
          url.pathSegments.first,
          'lib',
          ...url.pathSegments.skip(1),
        ],
      )
    : url;

final String rootPackageName = () {
  final name =
      (loadYaml(File('pubspec.yaml').readAsStringSync()) as Map)['name'];
  if (name is! String) {
    throw StateError(
      'Your pubspec.yaml file is missing a `name` field or it isn\'t '
      'a String.',
    );
  }
  return name;
}();

/// Returns whether or not [object] is or represents a `null` value.
bool isNullLike(DartObject? object) => object?.isNull != false;

/// Similar to [DartObject.getField], but traverses super classes.
///
/// Returns `null` if ultimately [field] is never found.
DartObject? getFieldRecursive(DartObject? object, String field) {
  if (isNullLike(object)) {
    return null;
  }
  final result = object!.getField(field);
  if (isNullLike(result)) {
    return getFieldRecursive(object.getField('(super)'), field);
  }
  return result;
}
