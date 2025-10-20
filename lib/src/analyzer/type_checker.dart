// LICENSE: BSD-3-Clause License
// Original package: https://pub.dev/packages/source_gen
// Original source: https://github.com/dart-lang/source_gen

// import 'dart:mirrors' hide SourceLocation;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_span/source_span.dart';

import 'utils.dart';

/// An abstraction around doing static type checking at compile/build time.
abstract class TypeChecker {
  const TypeChecker._();

  /*
  /// Create a new [TypeChecker] backed by a runtime [type].
  ///
  /// This implementation uses `dart:mirrors` (runtime reflection).
  const factory TypeChecker.fromRuntime(Type type) = _MirrorTypeChecker;
   */

  /// Create a new [TypeChecker] backed by a package path and type name.
  ///
  /// Useful when checking for types by package import location.
  const factory TypeChecker.fromPackage(String packagePath, String typeName) =
      _PackageTypeChecker;

  /// Create a new [TypeChecker] backed by a library [url].
  ///
  /// Example of referring to a `LinkedHashMap` from `dart:collection`:
  /// ```dart
  /// const linkedHashMap = const TypeChecker.fromUrl(
  ///   'dart:collection#LinkedHashMap',
  /// );
  /// ```
  ///
  /// **NOTE**: This is considered a more _brittle_ way of determining the type
  /// because it relies on knowing the _absolute_ path (i.e. after resolved
  /// `export` directives). You should ideally only use `fromUrl` when you know
  /// the full path (likely you own/control the package) or it is in a stable
  /// package like in the `dart:` SDK.
  const factory TypeChecker.fromUrl(dynamic url) = _UriTypeChecker;

  /// Returns the first constant annotating [element] assignable to this type.
  ///
  /// Otherwise returns `null`.
  ///
  /// Throws on unresolved annotations unless [throwOnUnresolved] is `false`.
  DartObject? firstAnnotationOf(
    Element element, {
    bool throwOnUnresolved = true,
  }) {
    if (element.metadata.annotations.isEmpty) {
      return null;
    }
    final results = annotationsOf(
      element,
      throwOnUnresolved: throwOnUnresolved,
    );
    return results.isEmpty ? null : results.first;
  }

  /// Returns if a constant annotating [element] is assignable to this type.
  ///
  /// Throws on unresolved annotations unless [throwOnUnresolved] is `false`.
  bool hasAnnotationOf(Element element, {bool throwOnUnresolved = true}) =>
      firstAnnotationOf(element, throwOnUnresolved: throwOnUnresolved) != null;

  /// Returns the first constant annotating [element] that is exactly this type.
  ///
  /// Throws [UnresolvedAnnotationException] on unresolved annotations unless
  /// [throwOnUnresolved] is explicitly set to `false` (default is `true`).
  DartObject? firstAnnotationOfExact(
    Element element, {
    bool throwOnUnresolved = true,
  }) {
    if (element.metadata.annotations.isEmpty) {
      return null;
    }
    final results = annotationsOfExact(
      element,
      throwOnUnresolved: throwOnUnresolved,
    );
    return results.isEmpty ? null : results.first;
  }

  /// Returns if a constant annotating [element] is exactly this type.
  ///
  /// Throws [UnresolvedAnnotationException] on unresolved annotations unless
  /// [throwOnUnresolved] is explicitly set to `false` (default is `true`).
  bool hasAnnotationOfExact(Element element, {bool throwOnUnresolved = true}) =>
      firstAnnotationOfExact(element, throwOnUnresolved: throwOnUnresolved) !=
      null;

  DartObject? _computeConstantValue(
    Element element,
    int annotationIndex, {
    bool throwOnUnresolved = true,
  }) {
    final annotation = element.metadata.annotations[annotationIndex];
    final result = annotation.computeConstantValue();

    if (result == null && throwOnUnresolved) {
      throw UnresolvedAnnotationException._from(element, annotationIndex);
    }
    return result;
  }

  /// Returns annotating constants on [element] assignable to this type.
  ///
  /// Throws [UnresolvedAnnotationException] on unresolved annotations unless
  /// [throwOnUnresolved] is explicitly set to `false` (default is `true`).
  Iterable<DartObject> annotationsOf(
    Element element, {
    bool throwOnUnresolved = true,
  }) => _annotationsWhere(
    element,
    isAssignableFromType,
    throwOnUnresolved: throwOnUnresolved,
  );

  Iterable<DartObject> _annotationsWhere(
    Element element,
    bool Function(DartType) predicate, {
    bool throwOnUnresolved = true,
  }) sync* {
    final annotations = element.metadata.annotations;
    for (var i = 0; i < annotations.length; i++) {
      final value = _computeConstantValue(
        element,
        i,
        throwOnUnresolved: throwOnUnresolved,
      );
      if (value?.type != null && predicate(value!.type!)) {
        yield value;
      }
    }
  }

  /// Returns annotating constants on [element] of exactly this type.
  ///
  /// Throws [UnresolvedAnnotationException] on unresolved annotations unless
  /// [throwOnUnresolved] is explicitly set to `false` (default is `true`).
  Iterable<DartObject> annotationsOfExact(
    Element element, {
    bool throwOnUnresolved = true,
  }) => _annotationsWhere(
    element,
    isExactlyType,
    throwOnUnresolved: throwOnUnresolved,
  );

  /// Returns `true` if the type of [element] can be assigned to this type.
  bool isAssignableFrom(Element? element) {
    if (element == null) return false;

    return isExactly(element) ||
        (element is InterfaceElement &&
            element.allSupertypes.any(isExactlyType));
  }

  /// Returns `true` if [staticType] can be assigned to this type.
  bool isAssignableFromType(DartType? staticType) =>
      isAssignableFrom(staticType?.elementDeclaration);

  /// Returns `true` if representing the exact same class as [element].
  bool isExactly(Element? element);

  /// Returns `true` if representing the exact same type as [staticType].
  bool isExactlyType(DartType? staticType) =>
      isExactly(staticType?.elementDeclaration);

  /// Returns `true` if representing a super class of [element].
  ///
  /// This check only takes into account the *extends* hierarchy. If you wish
  /// to check mixins and interfaces, use [isAssignableFrom].
  bool isSuperOf(Element element) {
    if (element is InterfaceElement) {
      var theSuper = element.supertype;

      while (theSuper != null) {
        if (isExactlyType(theSuper)) {
          return true;
        }

        theSuper = theSuper.superclass;
      }
    }

    return false;
  }

  /// Returns `true` if representing a super type of [staticType].
  ///
  /// This only takes into account the *extends* hierarchy. If you wish
  /// to check mixins and interfaces, use [isAssignableFromType].
  bool isSuperTypeOf(DartType staticType) =>
      isSuperOf(staticType.elementDeclaration!);
}

class _PackageTypeChecker extends TypeChecker {
  static Uri _uriOf(String packagePath, String typeName) {
    if (!packagePath.startsWith('package:')) {
      throw ArgumentError(
        'Parameter `packagePath` should start with "package:": $packagePath',
      );
    }

    var packageUri = Uri.tryParse(packagePath);
    if (packageUri == null) {
      throw StateError("Can't parse `packagePath` as `Uri`: $packagePath");
    }

    var uri = normalizeUrl(packageUri).replace(fragment: typeName);
    return uri;
  }

  // Precomputed type checker for types that already have been used.
  static final _cache = Expando<TypeChecker>();

  final String packagePath;
  final String typeName;

  const _PackageTypeChecker(this.packagePath, this.typeName) : super._();

  TypeChecker get _computed =>
      _cache[this] ??= TypeChecker.fromUrl(_uriOf(packagePath, typeName));

  @override
  bool isExactly(Element? element) => _computed.isExactly(element);

  @override
  String toString() => _computed.toString();
}

/*
// Checks a runtime type against a static type.
class _MirrorTypeChecker extends TypeChecker {
  static Uri _uriOf(ClassMirror mirror) {
    var mirrorUri = (mirror.owner as LibraryMirror).uri;
    var typeName = MirrorSystem.getName(mirror.simpleName);
    var uri = normalizeUrl(mirrorUri).replace(fragment: typeName);
    return uri;
  }

  // Precomputed type checker for types that already have been used.
  static final _cache = Expando<TypeChecker>();

  final Type _type;

  const _MirrorTypeChecker(this._type) : super._();

  TypeChecker get _computed =>
      _cache[this] ??= TypeChecker.fromUrl(_uriOf(reflectClass(_type)));

  @override
  bool isExactly(Element? element) => _computed.isExactly(element);

  @override
  String toString() => _computed.toString();
}
 */

// Checks a runtime type against an Uri and Symbol.
class _UriTypeChecker extends TypeChecker {
  final String _url;

  // Precomputed cache of String --> Uri.
  static final _cache = Expando<Uri>();

  const _UriTypeChecker(dynamic url) : _url = '$url', super._();

  @override
  bool operator ==(Object o) => o is _UriTypeChecker && o._url == _url;

  @override
  int get hashCode => _url.hashCode;

  /// Url as a [Uri] object, lazily constructed.
  Uri get uri => _cache[this] ??= normalizeUrl(Uri.parse(_url));

  /// Returns whether this type represents the same as [url].
  bool hasSameUrl(dynamic url) =>
      uri.toString() ==
      (url is String ? url : normalizeUrl(url as Uri).toString());

  @override
  bool isExactly(Element? element) {
    if (element == null) return false;
    return hasSameUrl(urlOfElement(element));
  }

  @override
  String toString() => '$uri';
}

/// Exception thrown when [TypeChecker] fails to resolve a metadata annotation.
///
/// Methods such as [TypeChecker.firstAnnotationOf] may throw this exception
/// when one or more annotations are not resolvable. This is usually a sign that
/// something was misspelled, an import is missing, or a dependency was not
/// defined (for build systems such as Bazel).
class UnresolvedAnnotationException implements Exception {
  /// Element that was annotated with something we could not resolve.
  final Element annotatedElement;

  /// Source span of the annotation that was not resolved.
  ///
  /// May be `null` if the import library was not found.
  final SourceSpan? annotationSource;

  static SourceSpan? _findSpan(Element annotatedElement, int annotationIndex) {
    try {
      final parsedLibrary =
          annotatedElement.session!.getParsedLibraryByElement(
                annotatedElement.library!,
              )
              as ParsedLibraryResult;
      final declaration = parsedLibrary.getFragmentDeclaration(
        annotatedElement.firstFragment,
      );
      if (declaration == null) {
        return null;
      }
      final annotatedNode = declaration.node as AnnotatedNode;
      final annotation = annotatedNode.metadata[annotationIndex];
      final start = annotation.offset;
      final end = start + annotation.length;
      final parsedUnit = declaration.parsedUnit!;
      return SourceSpan(
        SourceLocation(start, sourceUrl: parsedUnit.uri),
        SourceLocation(end, sourceUrl: parsedUnit.uri),
        parsedUnit.content.substring(start, end),
      );
    } catch (e, stack) {
      // Trying to get more information on https://github.com/dart-lang/sdk/issues/45127
      log.warning(
        '''
An unexpected error was thrown trying to get location information on `$annotatedElement` (${annotatedElement.runtimeType}). 

Please file an issue at https://github.com/dart-lang/source_gen/issues/new
Include the contents of this warning and the stack trace along with
the version of `package:source_gen`, `package:analyzer` from `pubspec.lock`.
''',
        e,
        stack,
      );
      return null;
    }
  }

  /// Creates an exception from an annotation ([annotationIndex]) that was not
  /// resolvable while traversing [Element.metadata] on [annotatedElement].
  factory UnresolvedAnnotationException._from(
    Element annotatedElement,
    int annotationIndex,
  ) {
    final sourceSpan = _findSpan(annotatedElement, annotationIndex);
    return UnresolvedAnnotationException._(annotatedElement, sourceSpan);
  }

  const UnresolvedAnnotationException._(
    this.annotatedElement,
    this.annotationSource,
  );

  @override
  String toString() {
    final message = 'Could not resolve annotation for `$annotatedElement`.';
    if (annotationSource != null) {
      return annotationSource!.message(message);
    }
    return message;
  }
}

extension DartTypeExtension on DartType {
  Element? get elementDeclaration {
    var self = this;
    if (self is InterfaceType) {
      return self.element;
    }
    return null;
  }
}
