// LICENSE: BSD-3-Clause License
// Original package: https://pub.dev/packages/source_gen
// Original source: https://github.com/dart-lang/source_gen

import 'package:analyzer/dart/element/element.dart';
import 'package:collection/collection.dart';

import 'reader.dart';
import 'type_checker.dart';

/// Result of finding an [annotation] on [element] through [LibraryReader].
class AnnotatedElement {
  final ConstantReader annotation;
  final Element element;

  const AnnotatedElement(this.annotation, this.element);
}

class LibraryReader {
  final LibraryElement element;

  LibraryReader(this.element);

  /// All the compilation unit of this element ([CompilationUnitElement]).
  Iterable<PartElement> get allParts => element.parts;

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

    return elements.where((e) => e.metadata.isNotEmpty);
  }

  /// All of the declarations in this library annotated with [checker].
  Iterable<AnnotatedElement> annotatedWith(TypeChecker checker,
          {bool throwOnUnresolved = true}) =>
      allElements.annotatedWith(checker, throwOnUnresolved: throwOnUnresolved);

  /// All of the elements names in this library
  /// (classes, enums, mixins, functions, extensions, typeAliases, topLevelVariables).
  Iterable<String> get elementsNames => element.units
      .expand((CompilationUnitElement cu) => <String?>[
            ...cu.classes.map((e) => e.name),
            ...cu.enums.map((e) => e.name),
            ...cu.mixins.map((e) => e.name),
            ...cu.functions.map((e) => e.name),
            ...cu.extensions.map((e) => e.name),
            ...cu.typeAliases.map((e) => e.name),
            ...cu.topLevelVariables.map((e) => e.name),
          ])
      .whereNotNull();

  /// All of the elements representing classes in this library.
  Iterable<ClassElement> get classes =>
      element.units.expand((CompilationUnitElement cu) => cu.classes);

  /// All of the elements representing enums in this library.
  Iterable<EnumElement> get enums => element.units.expand((cu) => cu.enums);
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
