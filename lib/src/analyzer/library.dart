// LICENSE: BSD-3-Clause License
// Original package: https://pub.dev/packages/source_gen
// Original source: https://github.com/dart-lang/source_gen

import 'package:analyzer/dart/element/element.dart';

import 'reader.dart';
import 'type_checker.dart';

/// Result of finding an [annotation] on [element] through [LibraryReader].
class AnnotatedElement {
  final ConstantReader annotation;
  final Element element;

  const AnnotatedElement(this.annotation, this.element);
}

extension LibraryElementExtension on LibraryElement {
  String get libraryName {
    var name = this.name;
    if (name != null && name.isNotEmpty) return name;

    var uri = firstFragment.source.uri;
    return uri.toString();
  }

  Iterable<Fragment> get topLevelFragments sync* {
    for (var unit in fragments) {
      yield* unit.classes;
      yield* unit.enums;
      yield* unit.extensions;
      yield* unit.extensionTypes;
      yield* unit.functions;
      yield* unit.mixins;
      yield* unit.topLevelVariables;
      yield* unit.typeAliases;
    }
  }

  Iterable<Element> get topLevelElements =>
      topLevelFragments.map((e) => e.element);
}

class LibraryReader {
  final LibraryElement element;

  LibraryReader(this.element);

  /// All the compilation unit of this element ([CompilationUnitElement]).
  Iterable<PartInclude> get allParts =>
      element.fragments.expand((e) => e.partIncludes);

  /// All of the declarations in this library.
  Iterable<Element> get allElements => element.topLevelElements;

  /// All the declared classes in this library
  Iterable<Element> get allClasses =>
      allElements.where((e) => e.kind == ElementKind.CLASS);

  /// All the declared enums in this library
  Iterable<Element> get allEnums =>
      allElements.where((e) => e.kind == ElementKind.ENUM);

  /// All the declared classes and enums in this library
  Iterable<Element> get allClassesOrEnums => allElements.where((e) {
        var kind = e.kind;
        return kind == ElementKind.CLASS || kind == ElementKind.ENUM;
      });

  /// [allElements] with annotations ([Element.metadata]).
  Iterable<Element> allAnnotatedElements(
      {bool classes = false, bool enums = false}) {
    Iterable<Element> elements;

    if (classes) {
      if (enums) {
        elements = allClassesOrEnums;
      } else {
        elements = allClasses;
      }
    } else if (enums) {
      elements = allEnums;
    } else {
      elements = allElements;
    }

    return elements.where((e) => e.metadata.annotations.isNotEmpty);
  }

  /// All of the declarations in this library annotated with [checker].
  Iterable<AnnotatedElement> annotatedWith(TypeChecker checker,
          {bool throwOnUnresolved = true}) =>
      allElements.annotatedWith(checker, throwOnUnresolved: throwOnUnresolved);

  /// All of the elements names in this library
  /// (classes, enums, mixins, functions, extensions, typeAliases, topLevelVariables).
  Iterable<String> get elementsNames => element.fragments
      .expand((cu) => <String?>[
            ...cu.classes.map((e) => e.name),
            ...cu.enums.map((e) => e.name),
            ...cu.mixins.map((e) => e.name),
            ...cu.functions.map((e) => e.name),
            ...cu.extensions.map((e) => e.name),
            ...cu.typeAliases.map((e) => e.name),
            ...cu.topLevelVariables.map((e) => e.name),
          ])
      .nonNulls;

  /// All of the elements representing classes in this library.
  Iterable<ClassElement> get classes =>
      element.fragments.expand((cu) => cu.classes.map((c) => c.element));

  /// All of the elements representing enums in this library.
  Iterable<EnumElement> get enums =>
      element.fragments.expand((cu) => cu.enums.map((c) => c.element));
}

extension ElementExtension on Element {
  bool isAnnotatedWith(TypeChecker checker, {bool throwOnUnresolved = true}) {
    final annotation = checker.firstAnnotationOf(
      this,
      throwOnUnresolved: throwOnUnresolved,
    );
    return annotation != null;
  }
}

extension IterableElementExtension on Iterable<Element> {
  Iterable<AnnotatedElement> annotatedWith(TypeChecker checker,
      {bool throwOnUnresolved = true}) sync* {
    for (final element in this) {
      final annotation = checker.firstAnnotationOf(
        element,
        throwOnUnresolved: throwOnUnresolved,
      );
      if (annotation != null) {
        yield AnnotatedElement(ConstantReader(annotation), element);
      }
    }
  }

  Iterable<Element> withAnnotation(TypeChecker checker,
          {bool throwOnUnresolved = true}) =>
      where((e) =>
          e.isAnnotatedWith(checker, throwOnUnresolved: throwOnUnresolved));
}

extension ConstructorElementExtension on ConstructorElement {
  String get codeName {
    var name = this.name;
    if (name == null || name == 'new') return '';
    return name;
  }
}
