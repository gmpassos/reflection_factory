// LICENSE: BSD-3-Clause License
// Original package: https://pub.dev/packages/source_gen
// Original source: https://github.com/dart-lang/source_gen

import 'package:analyzer/dart/element/element2.dart';
import 'package:collection/collection.dart';

import 'reader.dart';
import 'type_checker.dart';

/// Result of finding an [annotation] on [element] through [LibraryReader].
class AnnotatedElement {
  final ConstantReader annotation;
  final Element2 element;

  const AnnotatedElement(this.annotation, this.element);
}

class LibraryReader {
  final LibraryElement2 element;

  LibraryReader(this.element);

  /// All the compilation unit of this element ([CompilationUnitElement2]).
  Iterable<PartInclude> get allParts =>
      element.library2.fragments.expand((e) => e.partIncludes);

  /// All of the declarations in this library.
  Iterable<Element2> get allElements => CombinedIterableView([
        element.classes,
        element.enums,
        element.extensions,
        element.topLevelFunctions,
        element.topLevelVariables,
      ]);

  /// All the declared classes in this library
  Iterable<Element2> get allClasses =>
      allElements.where((e) => e.kind == ElementKind.CLASS);

  /// All the declared enums in this library
  Iterable<Element2> get allEnums =>
      allElements.where((e) => e.kind == ElementKind.ENUM);

  /// All the declared classes and enums in this library
  Iterable<Element2> get allClassesOrEnums => allElements.where((e) {
        var kind = e.kind;
        return kind == ElementKind.CLASS || kind == ElementKind.ENUM;
      });

  /// [allElements] with annotations ([Element2.metadata]).
  Iterable<Element2> allAnnotatedElements(
      {bool classes = false, bool enums = false}) {
    Iterable<Element2> elements;

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

    return elements.where((e) {
      if (e is Annotatable) {
        var ann = e as Annotatable;
        return ann.metadata2.annotations.isNotEmpty;
      }
      return false;
    });
  }

  /// All of the declarations in this library annotated with [checker].
  Iterable<AnnotatedElement> annotatedWith(TypeChecker checker,
          {bool throwOnUnresolved = true}) =>
      allElements.annotatedWith(checker, throwOnUnresolved: throwOnUnresolved);

  /// All of the elements names in this library
  /// (classes, enums, mixins, functions, extensions, typeAliases, topLevelVariables).
  Iterable<String> get elementsNames {
    final library2 = element.library2;
    return CombinedIterableView([
      library2.classes.map((e) => e.name3),
      library2.enums.map((e) => e.name3),
      library2.mixins.map((e) => e.name3),
      library2.topLevelFunctions.map((e) => e.name3),
      library2.extensions.map((e) => e.name3),
      library2.typeAliases.map((e) => e.name3),
      library2.topLevelVariables.map((e) => e.name3),
      // TODO: add getters and setters?
    ]).nonNulls;
  }

  Iterable<String> get elementsNames2 => element.library2.fragments
      .expand((LibraryFragment cu) => <String?>[
            ...cu.classes2.map((e) => e.name2),
            ...cu.enums2.map((e) => e.name2),
            ...cu.mixins2.map((e) => e.name2),
            ...cu.functions2.map((e) => e.name2),
            ...cu.extensions2.map((e) => e.name2),
            ...cu.typeAliases2.map((e) => e.name2),
            ...cu.topLevelVariables2.map((e) => e.name2),
            // TODO: add getters and setters?
          ])
      .nonNulls;

  /// All of the elements representing classes in this library.
  Iterable<ClassElement2> get classes => element.library2.classes;

  /// All of the elements representing enums in this library.
  Iterable<EnumElement2> get enums => element.library2.enums;
}

extension ElementExtension on Element2 {
  bool isAnnotatedWith(TypeChecker checker, {bool throwOnUnresolved = true}) {
    final annotation = checker.firstAnnotationOf(
      this,
      throwOnUnresolved: throwOnUnresolved,
    );
    return annotation != null;
  }
}

extension IterableElementExtension on Iterable<Element2> {
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

  Iterable<Element2> withAnnotation(TypeChecker checker,
          {bool throwOnUnresolved = true}) =>
      where((e) =>
          e.isAnnotatedWith(checker, throwOnUnresolved: throwOnUnresolved));
}
