import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as pack_path;

import '../reflection_factory_annotation.dart';
import 'library.dart';
import 'type_checker.dart';

class InputAnalyzer {
  static const TypeChecker typeReflectionBridge =
      TypeChecker.fromRuntime(ReflectionBridge);

  static const TypeChecker typeEnableReflection =
      TypeChecker.fromRuntime(EnableReflection);

  static const TypeChecker typeClassProxy = TypeChecker.fromRuntime(ClassProxy);

  final BuildStep buildStep;
  final AssetId inputId;

  InputAnalyzer(this.buildStep) : inputId = buildStep.inputId;

  Resolver get resolver => buildStep.resolver;

  InputAnalyzerResolved? _inputAnalyzerResolved;

  CompilationUnit? _compilationUnit;

  Future<CompilationUnit> get compilationUnit async =>
      _compilationUnit ??= await buildStep.resolver.compilationUnitFor(inputId);

  LibraryReader? _libraryReader;

  Future<LibraryReader> get libraryReader async =>
      _libraryReader ??= LibraryReader(await buildStep.inputLibrary);

  Future<InputAnalyzerResolved> resolved() async => _inputAnalyzerResolved ??=
      InputAnalyzerResolved(buildStep, inputId, resolver, await compilationUnit,
          libraryReader: _libraryReader);
}

class InputAnalyzerResolved {
  final BuildStep buildStep;
  final AssetId inputId;
  final Resolver resolver;
  final CompilationUnit compilationUnit;

  InputAnalyzerResolved(
      this.buildStep, this.inputId, this.resolver, this.compilationUnit,
      {LibraryReader? libraryReader})
      : _libraryReader = libraryReader;

  String get inputFileName => inputId.pathSegments.last;

  LibraryElement? _inputLibrary;
  Future<LibraryElement>? _inputLibraryFuture;

  Future<LibraryElement> get inputLibrary async {
    if (_inputLibrary != null) return _inputLibrary!;

    final initTime = DateTime.now();
    log.info("Loading `inputLibrary` ...");

    var inputLibraryFuture = _inputLibraryFuture;
    if (inputLibraryFuture == null) {
      _inputLibraryFuture = inputLibraryFuture = buildStep.inputLibrary;

      inputLibraryFuture.then((_) {
        if (identical(inputLibraryFuture, _inputLibraryFuture)) {
          _inputLibraryFuture = null;
        }
      });
    }

    var inputLibrary = await inputLibraryFuture;

    final elapsedTime = DateTime.now().difference(initTime);

    log.info("Loaded `inputLibrary` in: ${elapsedTime.inMilliseconds} ms");

    return inputLibrary;
  }

  LibraryReader? _libraryReader;

  Future<LibraryReader> get libraryReader async =>
      _libraryReader ??= LibraryReader(await inputLibrary);

  PartOfDirective? inputCompilationUnitPartOf() {
    var compilationUnit = this.compilationUnit;
    return getCompilationUnitPartOf(compilationUnit);
  }

  PartOfDirective? getCompilationUnitPartOf(CompilationUnit compilationUnit) {
    var partOf =
        compilationUnit.directives.whereType<PartOfDirective>().firstOrNull;
    return partOf;
  }

  List<PartDirective>? _inputCompilationUnitParts;

  List<PartDirective> inputCompilationUnitParts() =>
      _inputCompilationUnitParts ??= getCompilationUnitParts(compilationUnit);

  List<PartDirective> getCompilationUnitParts(
          CompilationUnit compilationUnit) =>
      compilationUnit.directives.whereType<PartDirective>().toList();

  List<String>? _allGParts;

  List<String> allGParts() => _allGParts ??= _allGPartsImpl();

  List<String> _allGPartsImpl() {
    var allParts = inputCompilationUnitParts();

    var allPartsPaths = allParts
        .map((e) {
          var uri = e.uri;
          return uri.stringValue;
        })
        .nonNulls
        .toList();

    return allPartsPaths.where((e) => e.endsWith('.g.dart')).toList();
  }

  Future<List<Annotation>> getDeclaredAnnotations(
      CompilationUnit compilationUnit, AssetId compilationUnitId,
      {bool deep = false}) async {
    var annotations = <Annotation>[];
    await _getDeclaredAnnotationsImpl(
        annotations, compilationUnit, compilationUnitId, deep);
    return annotations;
  }

  Future<void> _getDeclaredAnnotationsImpl(
      List<Annotation> annotations,
      CompilationUnit compilationUnit,
      AssetId compilationUnitId,
      bool deep) async {
    var declaredAnnotations = compilationUnit.declarations
        .expand((e) => e.sortedCommentAndAnnotations)
        .whereType<Annotation>();

    annotations.addAll(declaredAnnotations);

    if (deep) {
      var parts = getCompilationUnitParts(compilationUnit);
      for (var part in parts) {
        var partId = partAssetId(compilationUnitId, part);
        if (partId == null) continue;

        var partCanRead = await buildStep.canRead(partId);
        if (partCanRead) {
          var partCompUnit = await resolver.compilationUnitFor(partId);

          await _getDeclaredAnnotationsImpl(
              annotations, partCompUnit, partId, deep);
        }
      }
    }
  }

  AssetId? partAssetId(AssetId compilationUnitId, PartDirective part) {
    var partUriPath = part.uri.stringValue;
    if (partUriPath == null || partUriPath.isEmpty) {
      return null;
    }

    var partId =
        AssetId.resolve(Uri.parse(partUriPath), from: compilationUnitId);
    return partId;
  }

  Future<CompilationUnit> compilationUnitForElement(Element element) async =>
      compilationUnitFor(await assetIdForElement(element));

  final Expando<CompilationUnit> _compilationUnitForCache = Expando();

  Future<CompilationUnit> compilationUnitFor(AssetId assetId) async =>
      _compilationUnitForCache[assetId] ??=
          await resolver.compilationUnitFor(assetId);

  final Expando<AssetId> _assetIdForElementCache = Expando();

  Future<AssetId> assetIdForElement(Element element) async =>
      _assetIdForElementCache[element] ??=
          await resolver.assetIdForElement(element);

  Future<List<Annotation>> inputReflectionAnnotations(
          {bool deep = true}) async =>
      getReflectionAnnotations(compilationUnit, inputId, deep: deep);

  Future<List<Annotation>> getReflectionAnnotations(
      CompilationUnit compilationUnit, AssetId compilationUnitId,
      {bool deep = true}) async {
    var annotations = await getDeclaredAnnotations(
        compilationUnit, compilationUnitId,
        deep: deep);

    var reflectionAnnotations = annotations.where((e) {
      var name = e.name.name;
      return name == 'EnableReflection' ||
          name == 'ReflectionBridge' ||
          name == 'ClassProxy';
    }).toList();

    return reflectionAnnotations;
  }

  Future<(LibraryElement, AssetId)> getElementLibrary(Element element) async {
    var classAssetId = await resolver.assetIdForElement(element);
    var classCompUnit = await resolver.compilationUnitFor(classAssetId);

    var partOf = getCompilationUnitPartOf(classCompUnit);

    if (partOf != null) {
      var uri = partOf.uri?.stringValue ?? '';
      var dir = pack_path.dirname(classAssetId.path);
      var fullPath = uri.startsWith('/') ? uri : '$dir/$uri';

      var path2 = pack_path.normalize(fullPath);
      var partOfAssetId = AssetId(classAssetId.package, path2);

      var library = await resolver.libraryFor(partOfAssetId);
      return (library, partOfAssetId);
    }

    var library = await resolver.libraryFor(classAssetId);
    return (library, classAssetId);
  }

  Future<List<ClassElement>> findCandidateClassElements(
      String className, String libraryName, String libraryPath) async {
    var inputLibrary = await this.inputLibrary;

    var mainLibraries = <LibraryElement>[inputLibrary];
    var resolverLibraries = await resolver.libraries.toList();

    if (libraryPath.isNotEmpty) {
      libraryPath =
          libraryPath.replaceAll(RegExp(r'^(?:package:)?/*'), '').trim();
      var result =
          await inputLibrary.session.getLibraryByUri('package:$libraryPath');

      if (result is LibraryElementResult) {
        var libraryElement = result.element;
        mainLibraries.add(libraryElement);
      }
    }

    if (libraryName.isNotEmpty) {
      var library = await resolver.findLibraryByName(libraryName);
      if (library != null) {
        mainLibraries.add(library);
      }
    }

    var mainLibrariesExported =
        mainLibraries.expand((e) => e.exportedLibraries).toList();

    var allLibraries = <LibraryElement>{
      ...mainLibraries,
      ...resolverLibraries,
      ...mainLibrariesExported
    }.toList();

    var candidateClasses =
        allLibraries.allUsedClasses.where((c) => c.name == className).toList();

    if (candidateClasses.length > 1) {
      if (libraryName.isNotEmpty) {
        var targetClass = candidateClasses
            .firstWhereOrNull((e) => e.library.name == libraryName);
        if (targetClass != null) {
          return <ClassElement>[targetClass];
        }
      }
    }

    return candidateClasses;
  }

  Future<bool> hasCodeToGenerate() async {
    final libraryReader = await this.libraryReader;

    var allAnnotatedElementsItr =
        libraryReader.allAnnotatedElements(classes: true, enums: true);

    final allAnnotatedClasses = <Element>[];

    for (var e in allAnnotatedElementsItr) {
      if (e.isAnnotatedWith(InputAnalyzer.typeEnableReflection)) {
        return true;
      }

      if (e.kind == ElementKind.CLASS) {
        allAnnotatedClasses.add(e);
      }
    }

    var hasReflectionBridge = allAnnotatedClasses
        .withAnnotation(InputAnalyzer.typeReflectionBridge)
        .isNotEmpty;

    if (hasReflectionBridge) return true;

    var hasClassProxy = allAnnotatedClasses
        .withAnnotation(InputAnalyzer.typeClassProxy)
        .isNotEmpty;

    if (hasClassProxy) return true;

    return false;
  }

  Future<GeneratedPart?> resolveGeneratedPart() async {
    final inputFile = inputId.pathSegments.last;

    final reflectionParts = readInputReflectionPartDirectives();

    final isSiblingPart = reflectionParts.siblingPart != null;
    final isSubPart = reflectionParts.subPart != null;

    if (isSiblingPart && isSubPart) {
      throw StateError(
          "Can't generate multiple `reflection` files. Multiple reflection parts directives: "
          "${reflectionParts.siblingPart} AND ${reflectionParts.subPart}");
    }

    final hasCodeToGenerate = await this.hasCodeToGenerate();
    if (!hasCodeToGenerate) {
      return null;
    }

    final genSiblingId = inputId.changeExtension('.reflection.g.dart');
    final genSubId =
        inputId.changeExtension('.g.dart').withParentDirectory('reflection');

    final genId = isSiblingPart ? genSiblingId : genSubId;

    // No `part` directive!
    if (!isSiblingPart && !isSubPart) {
      var gParts = allGParts();

      var outputsPaths = reflectionPartDirectivesPaths();

      throw StateError(
          "Code generated but NO reflection part directive was found for input file: $inputId\n"
          "  > Can't generate ONE of the output files:\n"
          "    -- $genSiblingId\n"
          "    -- $genSubId\n"
          "  > Please ADD one of the directives below to the input file:\n"
          "       part '${outputsPaths.siblingPath}';\n"
          "       part '${outputsPaths.subPath}';\n"
          "  > Found part directives:\n"
          "${gParts.map((e) => '    -- $e').join('\n')}\n");
    }

    return GeneratedPart(
        genId.path, genId, isSiblingPart ? inputFile : '../$inputFile');
  }

  ({String? siblingPart, String? subPart}) readInputReflectionPartDirectives() {
    var outputsPaths = reflectionPartDirectivesPaths();
    var outputFileSibling = outputsPaths.siblingPath;
    var outputFileSub = outputsPaths.subPath;

    var allGParts = this.allGParts();

    var siblingParts = allGParts
        .where(
            (p) => p == outputFileSibling || p.endsWith('/$outputFileSibling'))
        .toList();

    var subParts = allGParts
        .where((p) => p == outputFileSub || p.endsWith('/$outputFileSub'))
        .toList();

    return (
      siblingPart: siblingParts.firstOrNull,
      subPart: subParts.firstOrNull
    );
  }

  ({String siblingPath, String subPath}) reflectionPartDirectivesPaths() =>
      buildReflectionPartDirectivesPaths(inputFileName);

  static ({String siblingPath, String subPath})
      buildReflectionPartDirectivesPaths(String inputFile) {
    var inputParts = pack_path.split(inputFile);

    var inputFileName = inputParts.last;
    var inputFileNameNoExt = pack_path.withoutExtension(inputFileName);

    var siblingPath = "$inputFileNameNoExt.reflection.g.dart";
    var subPath = "reflection/$inputFileNameNoExt.g.dart";

    return (siblingPath: siblingPath, subPath: subPath);
  }
}

class GeneratedPart {
  final String partPath;
  final AssetId genId;
  final String partOf;

  GeneratedPart(this.partPath, this.genId, this.partOf);

  Future<File?> resolveFile() async {
    var file = File(partPath);

    if (await file.exists()) {
      return file;
    }

    return null;
  }
}

extension AssetIdExtension on AssetId {
  AssetId withParentDirectory(String parentDir) {
    var ps = pack_path.split(path);
    ps.insert(ps.length - 1, parentDir);
    var p = pack_path.joinAll(ps);
    var asset = AssetId(package, p);
    return asset;
  }
}

extension _LibraryElementExtension on LibraryElement {
  static final Expando<List<ClassElement>> _exportedClasses =
      Expando<List<ClassElement>>();

  List<ClassElement> get exportedClasses =>
      _exportedClasses[this] ??= UnmodifiableListView(
          topLevelElements.whereType<ClassElement>().toList(growable: false));

  static final Expando<List<LibraryElement>> _allExports =
      Expando<List<LibraryElement>>();

  List<LibraryElement> get allExports => _allExports[this] ??=
      UnmodifiableListView(definingCompilationUnit.libraryExports
          .map((e) => e.exportedLibrary)
          .nonNulls
          .toList(growable: false));

  static final Expando<Set<ClassElement>> _allExportedClasses =
      Expando<Set<ClassElement>>();

  Set<ClassElement> get allExportedClasses => _allExportedClasses[this] ??=
      UnmodifiableSetView(allExports.expand((e) => e.exportedClasses).toSet());

  static final Expando<Set<ClassElement>> _allImportedClasses =
      Expando<Set<ClassElement>>();

  Set<ClassElement> get allImportedClasses =>
      _allImportedClasses[this] ??= UnmodifiableSetView(units
          .expand((e) =>
              e.library.importedLibraries.expand((e) => e.exportedClasses))
          .toSet());

  static final Expando<Set<ClassElement>> _allUnitsClasses =
      Expando<Set<ClassElement>>();

  Set<ClassElement> get allUnitsClasses =>
      _allUnitsClasses[this] ??= UnmodifiableSetView(
          units.expand((e) => e.library.exportedClasses).toSet());

  static final Expando<Set<ClassElement>> _allClassesFromExportedClassesUnits =
      Expando<Set<ClassElement>>();

  Set<ClassElement> get allClassesFromExportedClassesUnits =>
      _allClassesFromExportedClassesUnits[this] ??= UnmodifiableSetView(
          allExportedClasses.expand((e) => e.library.allUnitsClasses).toSet());

  static final Expando<Set<ClassElement>>
      _allImportedClassesFromExportedClasses = Expando<Set<ClassElement>>();

  Set<ClassElement> get allImportedClassesFromExportedClasses =>
      _allImportedClassesFromExportedClasses[this] ??= UnmodifiableSetView(
          allExportedClasses
              .expand((e) => e.library.allImportedClasses)
              .toSet());
}

extension _IterableLibraryElementExtension on Iterable<LibraryElement> {
  Set<ClassElement> get allUsedClasses => <ClassElement>{
        ...expand((l) => l.exportedClasses),
        ...expand((l) => l.allExportedClasses),
        ...expand((l) => l.allClassesFromExportedClassesUnits),
        ...expand((l) => l.allImportedClassesFromExportedClasses),
      };
}
