import 'dart:collection';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as pack_path;
import 'package:pub_semver/pub_semver.dart';

import 'analyzer/library.dart';
import 'analyzer/type_checker.dart';
import 'reflection_factory_annotation.dart';
import 'reflection_factory_base.dart';

/// The reflection builder.
class ReflectionBuilder implements Builder {
  /// If `true` builds code in verbose mode.
  bool verbose;

  ReflectionBuilder({this.verbose = false});

  @override
  final buildExtensions = const {
    '{{dir}}/{{file}}.dart': [
      '{{dir}}/reflection/{{file}}.g.dart',
      '{{dir}}/{{file}}.reflection.g.dart'
    ]
  };

  static const TypeChecker typeReflectionBridge =
      TypeChecker.fromRuntime(ReflectionBridge);

  static const TypeChecker typeEnableReflection =
      TypeChecker.fromRuntime(EnableReflection);

  static const TypeChecker typeClassProxy = TypeChecker.fromRuntime(ClassProxy);

  @override
  Future<void> build(BuildStep buildStep) async {
    var inputLib = await buildStep.inputLibrary;
    var inputId = buildStep.inputId;

    if (inputId.package == 'reflection_factory') {
      if (!inputId.path.startsWith('example/') &&
          !inputId.path.startsWith('test/')) {
        return;
      }
    } else if (inputLib.name == 'reflection_factory' ||
        inputLib.name.startsWith('reflection_factory.')) {
      return;
    }

    var libraryReader = LibraryReader(inputLib);

    var inputFile = inputId.pathSegments.last;

    var allParts = _readReflectionPartDirectives(libraryReader, inputFile);
    var siblingParts = allParts[0];
    var subParts = allParts[1];

    var isSiblingPart = siblingParts.isNotEmpty;
    var isSubPart = subParts.isNotEmpty;

    if (isSiblingPart && isSubPart) {
      throw StateError(
          "Can't generate multiple `reflection` files. Multiple reflection parts directives: $siblingParts AND $subParts");
    }

    var codeTable = await _buildCodeTable(buildStep, libraryReader);

    if (codeTable.isEmpty) {
      return;
    }

    var genSiblingId = inputId.changeExtension('.reflection.g.dart');
    var genSubId =
        inputId.changeExtension('.g.dart').withParentDirectory('reflection');

    // No `part` directive!
    if (siblingParts.isEmpty && subParts.isEmpty) {
      var gParts = _readAllGParts(libraryReader);

      var outputsPaths =
          _reflectionPartDirectivesPaths(libraryReader, inputFile);
      throw StateError(
          "Code generated but NO reflection part directive was found for input file: $inputId\n"
          "  > Can't generate ONE of the output files:\n"
          "    -- $genSiblingId\n"
          "    -- $genSubId\n"
          "  > Please ADD one of the directives below to the input file:\n"
          "${outputsPaths.map((p) => '    part \'$p\';').join('\n')}\n"
          "  > Found part directives: $gParts");
    }

    var genId = isSiblingPart ? genSiblingId : genSubId;

    var siblingsClassReflection = _buildSiblingsClassReflection(codeTable);

    var fullCode = StringBuffer();

    fullCode.write('// \n');
    fullCode.write('// GENERATED CODE - DO NOT MODIFY BY HAND!\n');
    fullCode
        .write('// BUILDER: reflection_factory/${ReflectionFactory.VERSION}\n');
    fullCode.write('// BUILD COMMAND: dart run build_runner build\n');
    fullCode.write('// \n\n');

    fullCode.write('// coverage:ignore-file\n');
    fullCode.write('// ignore_for_file: unnecessary_const\n');
    fullCode.write('// ignore_for_file: unnecessary_cast\n');
    fullCode.write('// ignore_for_file: unnecessary_type_check\n\n');

    if (isSiblingPart) {
      fullCode.write("part of '$inputFile';\n\n");
    } else {
      fullCode.write("part of '../$inputFile';\n\n");
    }

    var codeKeys = codeTable.allKeys.toList();
    _sortCodeKeys(codeKeys);

    for (var key in codeKeys) {
      var code = codeTable.get(key)!;
      if (code.trim().isNotEmpty) {
        fullCode.write(code);
      }
    }

    fullCode.write(siblingsClassReflection);

    var generatedCode = fullCode.toString();

    var dartFormatter = DartFormatter();
    var formattedCode = dartFormatter.format(generatedCode);

    await buildStep.writeAsString(genId, formattedCode);

    print('** GENERATED:\n'
        '  -- Elements: $codeKeys\n'
        '  -- Code file: $genId\n');

    if (verbose) {
      print('<<<\n$formattedCode\n>>>');
    }
  }

  List<List<String>> _readReflectionPartDirectives(
      LibraryReader libraryReader, String inputFile) {
    var outputsPaths = _reflectionPartDirectivesPaths(libraryReader, inputFile);
    var outputFileSibling = outputsPaths[0];
    var outputFileSub = outputsPaths[1];

    var allGParts = _readAllGParts(libraryReader);

    var siblingParts = allGParts
        .where(
            (p) => p == outputFileSibling || p.endsWith('/$outputFileSibling'))
        .toList();

    var subParts = allGParts
        .where((p) => p == outputFileSub || p.endsWith('/$outputFileSub'))
        .toList();

    return [siblingParts, subParts];
  }

  List<String> _readAllGParts(LibraryReader libraryReader) {
    var allPartsPaths = libraryReader.allParts.map((e) {
      var uri = e.uri;
      return uri is DirectiveUriWithRelativeUriString
          ? uri.relativeUriString
          : e.toString();
    }).toList();

    return allPartsPaths.where((e) => e.endsWith('.g.dart')).toList();
  }

  List<String> _reflectionPartDirectivesPaths(
      LibraryReader libraryReader, String inputFile) {
    var inputParts = pack_path.split(inputFile);

    var inputFileName = inputParts.last;
    var inputFileNameNoExt = pack_path.withoutExtension(inputFileName);

    var outputFileSibling = "$inputFileNameNoExt.reflection.g.dart";
    var outputFileSub = "reflection/$inputFileNameNoExt.g.dart";

    return <String>[outputFileSibling, outputFileSub];
  }

  Future<_CodeTable> _buildCodeTable(
      BuildStep buildStep, LibraryReader libraryReader) async {
    var codeTable = _CodeTable();

    var annotatedReflectionBridge =
        libraryReader.annotatedWith(typeReflectionBridge).toList();

    for (var annotated in annotatedReflectionBridge) {
      if (annotated.element.kind == ElementKind.CLASS) {
        var codes = await _reflectionBridge(buildStep, annotated);
        codeTable.addAllClasses(codes);
      }
    }

    var annotatedEnableReflection =
        libraryReader.annotatedWith(typeEnableReflection).toList();

    for (var annotated in annotatedEnableReflection) {
      var annotation = annotated.annotation;
      var reflectionClassName =
          annotation.peek('reflectionClassName')!.stringValue;
      var reflectionExtensionName =
          annotated.annotation.peek('reflectionExtensionName')!.stringValue;

      if (annotated.element.kind == ElementKind.CLASS) {
        var classElement = annotated.element as ClassElement;

        var codes = await _enableReflectionClass(
          buildStep,
          classElement,
          reflectionClassName,
          reflectionExtensionName,
        );

        codeTable.addAllClasses(codes);
      } else if (annotated.element.kind == ElementKind.ENUM) {
        var enumElement = annotated.element;

        var codes = await _enableReflectionEnum(
          buildStep,
          enumElement,
          reflectionClassName,
          reflectionExtensionName,
        );

        codeTable.addAllClasses(codes);
      }
    }

    var annotatedClassProxy =
        libraryReader.annotatedWith(typeClassProxy).toList();

    for (var annotated in annotatedClassProxy) {
      if (annotated.element.kind == ElementKind.CLASS) {
        var codes = await _classProxy(buildStep, annotated);
        codeTable.addProxies(codes);
      }
    }

    return codeTable;
  }

  void _sortCodeKeys(List<String> codeKeys) {
    codeKeys.sort((a, b) {
      var k1 = _parseCodeKey(a);
      var k2 = _parseCodeKey(b);
      var cmp = k1.compareTo(k2);
      if (cmp == 0) {
        cmp = a.compareTo(b);
      }
      return cmp;
    });
  }

  String _parseCodeKey(String s) {
    var idx = s.indexOf(r'$');
    return idx >= 0 ? s.substring(idx + 1) : s;
  }

  Future<Map<String, String>> _classProxy(
      BuildStep buildStep, AnnotatedElement annotated) async {
    var annotation = annotated.annotation;
    var annotatedClass = annotated.element as ClassElement;

    var className = annotation.peek('className')!.stringValue;
    var libraryName = annotation.peek('libraryName')!.stringValue;
    var libraryPath = annotation.peek('libraryPath')!.stringValue;
    var reflectionProxyName =
        annotation.peek('reflectionProxyName')!.stringValue;
    var alwaysReturnFuture = annotation.peek('alwaysReturnFuture')!.boolValue;
    var traverseReturnTypes = annotation.peek('traverseReturnTypes')!.setValue;
    var ignoreParametersTypes =
        annotation.peek('ignoreParametersTypes')!.setValue;
    var ignoreMethods = annotation.peek('ignoreMethods')!.setValue;

    if (reflectionProxyName.isEmpty) {
      reflectionProxyName = annotatedClass.name;
    }

    print('** ClassProxy:\n'
        '  -- Target Class Name: $className\n'
        '  -- Always Return Future: $alwaysReturnFuture\n'
        '  -- reflectionProxyName: $reflectionProxyName\n'
        '  -- traverseReturnTypes: $traverseReturnTypes\n'
        '  -- ignoreParametersTypes: $ignoreParametersTypes\n');

    var codeTable = <String, String>{};

    var candidateClasses =
        await _findClassElement(buildStep, className, libraryName, libraryPath);

    if (candidateClasses.isEmpty) {
      throw StateError(
          "** Can't find a class with name `$className` to generate a `ClassProxy`! libraryName: `$libraryName` ; libraryPath: `$libraryPath`.");
    } else if (candidateClasses.length > 1) {
      throw StateError(
          "** Found many candidate classes with name `$className`: $candidateClasses");
    }

    var classElement = candidateClasses.first;

    var classTree = _ClassTree(
      classElement,
      '?%',
      '?%',
      reflectionProxyName,
      classElement.library.languageVersion.effective,
      verbose: verbose,
    );

    if (verbose) {
      print(classTree);
    }

    codeTable.putIfAbsent(
        classTree.reflectionProxyExtension,
        () => classTree.buildReflectionProxyClass(
            annotatedClass,
            alwaysReturnFuture,
            traverseReturnTypes,
            ignoreParametersTypes,
            ignoreMethods));

    return codeTable;
  }

  Future<List<ClassElement>> _findClassElement(BuildStep buildStep,
      String className, String libraryName, String libraryPath) async {
    var inputLibrary = await buildStep.inputLibrary;
    var mainLibraries = <LibraryElement>[inputLibrary];
    var resolverLibraries = await buildStep.resolver.libraries.toList();

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
      var library = await buildStep.resolver.findLibraryByName(libraryName);
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

  Future<Map<String, String>> _reflectionBridge(
      BuildStep buildStep, AnnotatedElement annotated) async {
    var annotation = annotated.annotation;
    var annotatedClass = annotated.element as ClassElement;

    var classesTypes = annotation
        .peek('classesTypes')!
        .listValue
        .map((e) => e.toTypeValue()!)
        .toList();

    var bridgeExtensionName =
        annotation.peek('bridgeExtensionName')!.stringValue;
    var reflectionClassNames = annotation
        .peek('reflectionClassNames')!
        .mapValue
        .map((k, v) => MapEntry(k!.toTypeValue()!, v!.toStringValue()!));
    var reflectionExtensionNames = annotation
        .peek('reflectionExtensionNames')!
        .mapValue
        .map((k, v) => MapEntry(k!.toTypeValue()!, v!.toStringValue()!));

    print('** ReflectionBridge:\n'
        '  -- classesTypes: $classesTypes\n'
        '  -- bridgeExtensionName: $bridgeExtensionName\n'
        '  -- reflectionClassNames: $reflectionClassNames\n'
        '  -- reflectionExtensionNames: $reflectionExtensionNames\n');

    var codeTable = <String, String>{};

    for (var classType in classesTypes) {
      var classElement = classType.elementDeclaration;
      if (classElement == null || classElement is! ClassElement) {
        continue;
      }

      var classLibrary = await _getElementLibrary(buildStep, classElement);

      var reflectionClassName = reflectionClassNames[classType] ?? '';
      var reflectionExtensionName = reflectionExtensionNames[classType] ?? '';

      var classTree = _ClassTree(
        classElement,
        reflectionClassName,
        reflectionExtensionName,
        '?%',
        classLibrary.languageVersion.effective,
        verbose: verbose,
      );

      if (verbose) {
        print(classTree);
      }

      codeTable.putIfAbsent(classTree.classGlobalFunction('_'),
          () => classTree.buildClassGlobalFunctions());
      codeTable.putIfAbsent(
          classTree.reflectionClass, () => classTree.buildReflectionClass());
      codeTable.putIfAbsent(classTree.reflectionExtension,
          () => classTree.buildReflectionExtension());
    }

    codeTable.addAll(_reflectionBridgeExtension(annotatedClass, classesTypes,
        bridgeExtensionName, reflectionClassNames));

    return codeTable;
  }

  Map<String, String> _reflectionBridgeExtension(
      ClassElement annotatedClass,
      List<DartType> classesTypes,
      String reflectionBridgeExtensionName,
      Map<DartType, String> reflectionClassNames) {
    var bridgeClassName = annotatedClass.name;

    var bridgeExtensionName = _buildReflectionExtensionName(
        bridgeClassName, reflectionBridgeExtensionName);

    var str = StringBuffer();

    str.write('extension $bridgeExtensionName on $bridgeClassName {\n');

    str.write(
        '  /// Returns a [ClassReflection] for type [T] or [obj]. (Generated by [ReflectionFactory])\n');
    str.write('  ClassReflection<T> reflection<T>([T? obj]) {\n');

    str.write('    switch (T) {\n');

    for (var classType in classesTypes) {
      var bridgeReflectionClassName = reflectionClassNames[classType] ?? '';
      var className = classType.elementDeclaration!.name!;

      var reflectionClassName =
          _buildReflectionClassName(className, bridgeReflectionClassName);
      str.write(
          '      case $className: return $reflectionClassName(obj as $className?) as ClassReflection<T>;\n');
    }

    str.write(
        "      default: throw UnsupportedError('<\$runtimeType> No reflection for Type: \$T');\n");
    str.write('    }\n');

    str.write('  }\n\n');

    str.write('}\n\n');

    var code = str.toString();

    return {bridgeExtensionName: code};
  }

  Future<Map<String, String>> _enableReflectionEnum(
      BuildStep buildStep,
      Element enumElement,
      String reflectionClassName,
      String reflectionExtensionName) async {
    var enumLibrary = await _getElementLibrary(buildStep, enumElement);

    var enumTree = _EnumTree(
      enumElement,
      reflectionClassName,
      reflectionExtensionName,
      enumLibrary.languageVersion.effective,
      verbose: verbose,
    );

    if (verbose) {
      print(enumTree);
    }

    var enumGlobalFunctions = enumTree.buildEnumGlobalFunctions();
    var reflectionClassCode = enumTree.buildReflectionEnum();
    var reflectionExtensionCode = enumTree.buildReflectionExtension();

    return {
      enumTree.classGlobalFunction('_'): enumGlobalFunctions,
      enumTree.reflectionClass: reflectionClassCode,
      enumTree.reflectionExtension: reflectionExtensionCode,
    };
  }

  Future<Map<String, String>> _enableReflectionClass(
      BuildStep buildStep,
      ClassElement classElement,
      String reflectionClassName,
      String reflectionExtensionName) async {
    var classLibrary = await _getElementLibrary(buildStep, classElement);

    var classTree = _ClassTree(
      classElement,
      reflectionClassName,
      reflectionExtensionName,
      '?%',
      classLibrary.languageVersion.effective,
      verbose: verbose,
    );

    if (verbose) {
      print(classTree);
    }

    var classGlobalFunctions = classTree.buildClassGlobalFunctions();
    var reflectionClassCode = classTree.buildReflectionClass();
    var reflectionExtensionCode = classTree.buildReflectionExtension();

    return {
      classTree.classGlobalFunction('_'): classGlobalFunctions,
      classTree.reflectionClass: reflectionClassCode,
      classTree.reflectionExtension: reflectionExtensionCode,
    };
  }

  Future<LibraryElement> _getElementLibrary(
      BuildStep buildStep, Element element) async {
    var resolver = buildStep.resolver;
    var classAssetId = await resolver.assetIdForElement(element);
    var library = await resolver.libraryFor(classAssetId);
    return library;
  }

  String _buildSiblingsClassReflection(_CodeTable codeTable) {
    if (codeTable.reflectionClassesIsEmpty) return '';

    var str = StringBuffer();

    str.write('List<Reflection> _listSiblingsReflection() => ');
    str.write('<Reflection>[');

    for (var c in codeTable.reflectionClassesKeys
        .where((e) => e.endsWith(r'$reflection'))) {
      str.write(c);
      str.write('(), ');
    }

    str.write('];\n\n');

    str.write('List<Reflection>? _siblingsReflectionList;\n');
    str.write('List<Reflection> _siblingsReflection() => ');
    str.write(
        '_siblingsReflectionList ??= List<Reflection>.unmodifiable( _listSiblingsReflection() );\n\n');

    str.write('bool _registerSiblingsReflectionCalled = false;\n');
    str.write('void _registerSiblingsReflection() {\n');
    str.write('  if (_registerSiblingsReflectionCalled) return ;\n');
    str.write('  _registerSiblingsReflectionCalled = true ;\n');
    str.write('  var length = _listSiblingsReflection().length;\n');
    str.write('  assert(length > 0);\n');
    str.write('}\n\n');

    var code = str.toString();
    return code;
  }
}

extension _AssetIdExtension on AssetId {
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

  List<ClassElement> get exportedClasses => _exportedClasses[this] ??=
      UnmodifiableListView(topLevelElements.whereType<ClassElement>().toList());

  static final Expando<List<LibraryElement>> _allExports =
      Expando<List<LibraryElement>>();

  List<LibraryElement> get allExports =>
      _allExports[this] ??= UnmodifiableListView(
          libraryExports.map((e) => e.exportedLibrary).whereNotNull().toList());

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

extension IterableLibraryElementExtension on Iterable<LibraryElement> {
  Set<ClassElement> get allUsedClasses => <ClassElement>{
        ...expand((l) => l.exportedClasses),
        ...expand((l) => l.allExportedClasses),
        ...expand((l) => l.allClassesFromExportedClassesUnits),
        ...expand((l) => l.allImportedClassesFromExportedClasses),
      };
}

class _CodeTable {
  final Map<String, String> _reflectionClasses = <String, String>{};
  final Map<String, String> _reflectionProxies = <String, String>{};

  bool get reflectionClassesIsEmpty => _reflectionClasses.isEmpty;

  bool get isEmpty => _reflectionClasses.isEmpty && _reflectionProxies.isEmpty;

  Iterable<String> get reflectionClassesKeys => _reflectionClasses.keys;

  Iterable<String> get reflectionProxiesKeys => _reflectionClasses.keys;

  Iterable<String> get allKeys =>
      <String>[..._reflectionClasses.keys, ..._reflectionProxies.keys];

  void _checkKey(String key) {
    var code = get(key);
    if (code != null) {
      throw StateError("Key `$key` already exists in the code table!");
    }
  }

  String? get(String key) => _reflectionClasses[key] ?? _reflectionProxies[key];

  void addClass(String key, String code) {
    _checkKey(key);
    _reflectionClasses[key] = code;
  }

  void addAllClasses(Map<String, String> codes) {
    for (var e in codes.entries) {
      addClass(e.key, e.value);
    }
  }

  void addProxy(String key, String code) {
    _checkKey(key);
    _reflectionProxies[key] = code;
  }

  void addProxies(Map<String, String> codes) {
    for (var e in codes.entries) {
      addProxy(e.key, e.value);
    }
  }
}

String _buildClassGlobalFunction(
    String className, String reflectionClassName, String functionName,
    {String delimiter = '\$'}) {
  reflectionClassName = reflectionClassName.trim();
  if (reflectionClassName.isNotEmpty) {
    return '$reflectionClassName$delimiter$functionName';
  }

  return '$className$delimiter$functionName';
}

String _buildReflectionClassName(String className, String reflectionClassName) {
  reflectionClassName = reflectionClassName.trim();
  if (reflectionClassName.isNotEmpty) {
    return reflectionClassName;
  }

  return '$className\$reflection';
}

String _buildReflectionExtensionName(
    String className, String reflectionExtensionName) {
  reflectionExtensionName = reflectionExtensionName.trim();
  if (reflectionExtensionName.isNotEmpty) {
    return reflectionExtensionName;
  }

  return '$className\$reflectionExtension';
}

class _EnumTree<T> extends RecursiveElementVisitor<T> {
  final Element _enumElement;

  final String reflectionClassName;
  final String reflectionExtensionName;

  final Version languageVersion;

  final bool verbose;

  final String enumName;

  _EnumTree(this._enumElement, this.reflectionClassName,
      this.reflectionExtensionName, this.languageVersion,
      {this.verbose = false})
      : enumName = _enumElement.name! {
    _enumElement.visitChildren(this);
  }

  String classGlobalFunction(String functionName) =>
      _buildClassGlobalFunction(enumName, reflectionClassName, functionName);

  String get reflectionClass =>
      _buildReflectionClassName(enumName, reflectionClassName);

  String get reflectionExtension =>
      _buildReflectionExtensionName(enumName, reflectionExtensionName);

  final Set<FieldElement> fields = <FieldElement>{};

  @override
  T? visitFieldElement(FieldElement element) {
    var name = element.name;

    if (name == 'index' || name == 'values') {
      return null;
    }

    fields.add(element);
    return null;
  }

  List<String> get fieldsNames => fields.map((e) => e.name).toList();

  bool hasField(String filedName) =>
      fields.where((m) => m.name == filedName).isNotEmpty;

  @override
  String toString() {
    return '_EnumTree{ '
        'enumName: $enumName, '
        'languageVersion: $languageVersion, '
        'fields: $fieldsNames '
        '}';
  }

  String buildEnumGlobalFunctions() {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    var from = classGlobalFunction('from');

    str.write('// ignore: non_constant_identifier_names\n');
    str.write(
        '$enumName? $from(Object? o) => $reflectionClass.staticInstance.from(o);\n');

    return str.toString();
  }

  String buildReflectionEnum() {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    str.write('class $reflectionClass extends EnumReflection<$enumName> {\n\n');

    str.write(
        '  $reflectionClass([$enumName? object]) : super($enumName, object);\n\n');

    str.write('  static bool _registered = false;\n');
    str.write('  @override\n');
    str.write('  void register() {\n');
    str.write('    if (!_registered) {\n');
    str.write('      _registered = true;\n');
    str.write('      super.register();\n');
    str.write('      _registerSiblingsReflection();\n');
    str.write('    }\n');
    str.write('  }\n\n');

    str.write('  @override\n');
    str.write(
        "  Version get languageVersion => Version.parse('$languageVersion');\n\n");

    str.write('  @override\n');
    str.write(
        "  Version get reflectionFactoryVersion => Version.parse('${ReflectionFactory.VERSION}');\n\n");

    str.write('  @override\n');
    str.write(
        '  $reflectionClass withObject([$enumName? obj]) => $reflectionClass(obj);\n\n');

    str.write('  static $reflectionClass? _withoutObjectInstance;\n');
    str.write('  @override\n');
    str.write(
        '  $reflectionClass withoutObjectInstance() => _withoutObjectInstance ??= super.withoutObjectInstance() as $reflectionClass;\n\n');

    str.write(
        '  static $reflectionClass get staticInstance => _withoutObjectInstance ??= $reflectionClass();\n\n');

    str.write('  @override\n');
    str.write(
        '   $reflectionClass getStaticInstance() => staticInstance ;\n\n');

    str.write('  static bool _boot = false;'
        '  static void boot() {\n'
        '    if (_boot) return;\n'
        '    _boot = true;\n'
        '    $reflectionClass.staticInstance ;\n'
        '}');

    var classElement = _Element(_enumElement);

    var classAnnotationListCode = classElement.annotationsAsListCode;
    if (classAnnotationListCode != 'null') {
      str.write(
          '  static const List<Object> _classAnnotations = $classAnnotationListCode; \n\n');
      str.write('  @override\n');
      str.write(
          '  List<Object> get classAnnotations => List<Object>.unmodifiable(_classAnnotations);\n\n');
    } else {
      str.write('  @override\n');
      str.write(
          '  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);\n\n');
    }

    str.write('\n  @override\n');
    str.write(
        '  List<EnumReflection> siblingsEnumReflection() => _siblingsReflection().whereType<EnumReflection>().toList();\n\n');

    str.write('\n  @override\n');
    str.write(
        '  List<Reflection> siblingsReflection() => _siblingsReflection();\n\n');

    _buildField(str);

    str.write('}\n\n');

    return str.toString();
  }

  void _buildField(StringBuffer str) {
    var entries = _toFieldEntries(fields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get fieldsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  Map<String,$enumName> get valuesByName => const <String,$enumName>{\n');
    for (var name in entries.keys) {
      str.write("  '$name': $enumName.$name,\n");
    }
    str.write('  };\n\n');

    str.write('  @override\n');
    str.write('  List<$enumName> get values => $enumName.values;\n\n');
  }

  Map<String, _Field> _toFieldEntries(Set<FieldElement> fields) {
    return Map.fromEntries(fields.map((e) => MapEntry(e.name, _Field(e))));
  }

  String buildReflectionExtension() {
    var str = StringBuffer();

    _buildExtension(str);

    return str.toString();
  }

  void _buildExtension(StringBuffer codeBuffer) {
    var str = StringBuffer();

    str.write('extension $reflectionExtension on $enumName {\n');

    var entriesCount = 0;

    if (!hasField('reflection')) {
      str.write(
          '  /// Returns a [EnumReflection] for type [$enumName]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  EnumReflection<$enumName> get reflection => $reflectionClass(this);\n');
      entriesCount++;
    }

    if (!hasField('enumName')) {
      str.write(
          '  /// Returns the name of the [$enumName] instance. (Generated by [ReflectionFactory])\n');
      str.write('  String get enumName => $reflectionClass(this).name()!;\n');
      entriesCount++;
    }

    if (!hasField('toJson')) {
      str.write(
          '\n  /// Returns a JSON for type [$enumName]. (Generated by [ReflectionFactory])\n');
      str.write('  String? toJson() => reflection.toJson();\n');
      entriesCount++;
    }

    if (!hasField('toJsonMap')) {
      str.write(
          '\n  /// Returns a JSON [Map] for type [$enumName]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  Map<String,Object>? toJsonMap() => reflection.toJsonMap();\n');
      entriesCount++;
    }

    if (!hasField('toJsonEncoded')) {
      str.write(
          '\n  /// Returns an encoded JSON [String] for type [$enumName]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  String toJsonEncoded({bool pretty = false}) => reflection.toJsonEncoded(pretty: pretty);\n');
      entriesCount++;
    }

    str.write('}\n\n');

    if (entriesCount > 0) {
      codeBuffer.write(str);
    }
  }
}

class _ClassTree<T> extends RecursiveElementVisitor<T> {
  final ClassElement _classElement;

  final String reflectionClassName;
  final String reflectionExtensionName;
  final String reflectionProxyName;

  final Version languageVersion;

  final bool verbose;

  final String className;

  _ClassTree(
      this._classElement,
      this.reflectionClassName,
      this.reflectionExtensionName,
      this.reflectionProxyName,
      this.languageVersion,
      {this.verbose = false})
      : className = _classElement.name {
    scan(_classElement);
  }

  final Set<ClassElement> supperTypes = <ClassElement>{};

  final Queue<ClassElement> _visitingClassStack = Queue<ClassElement>();

  ClassElement? get _visitingClass => _visitingClassStack.last;

  bool get _isVisitingSupperClass => _visitingClass != _classElement;

  void scan(ClassElement classElement) {
    try {
      _visitingClassStack.addLast(classElement);

      if (classElement != _classElement) {
        supperTypes.add(classElement);
      }

      classElement.visitChildren(this);

      for (var t in classElement.allSupertypes) {
        var superClass = t.element2;
        if (superClass is! ClassElement) continue;

        if (superClass.isDartCoreObject) {
          continue;
        }

        scan(superClass);
      }
    } finally {
      var c = _visitingClassStack.removeLast();
      if (c != classElement) {
        throw StateError('_visitingClassStack error!');
      }
    }
  }

  @override
  String toString() {
    return '_ClassTree{ '
        'className: $className, '
        'languageVersion: $languageVersion, '
        'staticMethods: $staticMethodsNames, '
        'methods: $methodsNames, '
        'staticFields: $staticFieldsNames, '
        'fields: $fieldsNames '
        '}';
  }

  String classGlobalFunction(String functionName) =>
      _buildClassGlobalFunction(className, reflectionClassName, functionName);

  String get reflectionClass =>
      _buildReflectionClassName(className, reflectionClassName);

  String get reflectionExtension =>
      _buildReflectionExtensionName(className, reflectionExtensionName);

  String get reflectionProxyExtension =>
      '$reflectionProxyName\$reflectionProxy';

  final Set<ConstructorElement> constructors = <ConstructorElement>{};

  ConstructorElement? get defaultConstructor =>
      constructors.firstWhereOrNull((e) => e.isDefaultConstructor);

  ConstructorElement? get emptyConstructor {
    var noArgsConstructors = constructors
        .where((e) => e.name.isNotEmpty && e.parameters.isEmpty)
        .toList();

    if (noArgsConstructors.isEmpty) {
      return null;
    } else if (noArgsConstructors.length == 1) {
      return noArgsConstructors[0];
    } else {
      var found = noArgsConstructors.firstWhereOrNull((e) {
        var name = e.name.toLowerCase();
        return name == 'empty' || name == 'create' || name == 'def';
      });

      if (found != null) {
        return found;
      } else {
        return noArgsConstructors.first;
      }
    }
  }

  ConstructorElement? get noRequiredArgsConstructor {
    var noArgsConstructors = constructors
        .where((e) =>
            e.name.isNotEmpty &&
            e.normalParameters.isEmpty &&
            e.optionalParameters.where((p) => p.required).isEmpty &&
            e.namedParameters.values.where((p) => p.required).isEmpty)
        .toList();

    if (noArgsConstructors.isEmpty) {
      return null;
    } else if (noArgsConstructors.length == 1) {
      return noArgsConstructors[0];
    } else {
      var found = noArgsConstructors.firstWhereOrNull((e) {
        var name = e.name.toLowerCase();
        return name == 'empty' || name == 'create' || name == 'def';
      });

      if (found != null) {
        return found;
      } else {
        return noArgsConstructors.first;
      }
    }
  }

  @override
  T? visitConstructorElement(ConstructorElement element) {
    if (element.isPrivate || !isValidMethodName(element.name)) {
      return super.visitConstructorElement(element);
    }

    if (!_isVisitingSupperClass) {
      _addWithUniqueName(constructors, element);
    }

    return null;
  }

  static bool _addWithUniqueName(Set<Element> set, Element element) {
    if (set.where((e) => e.name == element.name).isEmpty) {
      set.add(element);
      return true;
    }

    return false;
  }

  final Set<MethodElement> staticMethods = <MethodElement>{};

  List<String> get staticMethodsNames =>
      staticMethods.map((e) => e.name).toList();

  final Set<MethodElement> methods = <MethodElement>{};

  List<String> get methodsNames => methods.map((e) => e.name).toList();

  bool hasMethod(String methodName) =>
      methods.where((m) => m.name == methodName).isNotEmpty;

  bool hasStaticMethod(String methodName) =>
      staticMethods.where((m) => m.name == methodName).isNotEmpty;

  bool isValidMethodName(String name) =>
      name != '==' &&
      name != '+' &&
      name != '-' &&
      name != '*' &&
      name != '/' &&
      name != '~/' &&
      name != '[]' &&
      name != '[]=' &&
      name != '<' &&
      name != '>' &&
      name != '<=' &&
      name != '>=' &&
      name != '&' &&
      name != '|' &&
      name != '^' &&
      name != '<<' &&
      name != '>>' &&
      name != '~' &&
      name != '%';

  @override
  T? visitMethodElement(MethodElement element) {
    if (element.isPrivate || !isValidMethodName(element.name)) {
      return super.visitMethodElement(element);
    }

    if (element.isStatic) {
      if (!_isVisitingSupperClass) {
        _addWithUniqueName(staticMethods, element);
      }
    } else {
      _addWithUniqueName(methods, element);
    }

    return super.visitMethodElement(element);
  }

  final Set<FieldElement> staticFields = <FieldElement>{};

  List<String> get staticFieldsNames =>
      staticFields.map((e) => e.name).toList();

  final Set<FieldElement> fields = <FieldElement>{};

  List<String> get fieldsNames => fields.map((e) => e.name).toList();

  bool hasField(String filedName) =>
      fields.where((m) => m.name == filedName).isNotEmpty;

  bool hasStaticField(String filedName) =>
      staticFields.where((m) => m.name == filedName).isNotEmpty;

  bool hasEntry(String name) =>
      hasMethod(name) ||
      hasStaticMethod(name) ||
      hasField(name) ||
      hasStaticField(name);

  @override
  T? visitFieldElement(FieldElement element) {
    if (element.isPrivate) {
      return super.visitFieldElement(element);
    }

    if (element.isStatic) {
      if (!_isVisitingSupperClass) {
        _addWithUniqueName(staticFields, element);
      }
    } else {
      _addWithUniqueName(fields, element);
    }

    return super.visitFieldElement(element);
  }

  String buildClassGlobalFunctions() {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    var fromJsonName = classGlobalFunction('fromJson');

    str.write('// ignore: non_constant_identifier_names\n');
    str.write(
        '$className $fromJsonName(Map<String,Object?> map) => $reflectionClass.staticInstance.fromJson(map);\n');

    var fromJsonEncodedName = classGlobalFunction('fromJsonEncoded');

    str.write('// ignore: non_constant_identifier_names\n');
    str.write(
        '$className $fromJsonEncodedName(String jsonEncoded) => $reflectionClass.staticInstance.fromJsonEncoded(jsonEncoded);\n');

    return str.toString();
  }

  String buildReflectionClass() {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    str.write(
        'class $reflectionClass extends ClassReflection<$className> {\n\n');

    str.write(
        '  $reflectionClass([$className? object]) : super($className, object);\n\n');

    str.write('  static bool _registered = false;\n');
    str.write('  @override\n');
    str.write('  void register() {\n');
    str.write('    if (!_registered) {\n');
    str.write('      _registered = true;\n');
    str.write('      super.register();\n');
    str.write('      _registerSiblingsReflection();\n');
    str.write('    }\n');
    str.write('  }\n\n');

    str.write('  @override\n');
    str.write(
        "  Version get languageVersion => Version.parse('$languageVersion');\n\n");

    str.write('  @override\n');
    str.write(
        "  Version get reflectionFactoryVersion => Version.parse('${ReflectionFactory.VERSION}');\n\n");

    str.write('  @override\n');
    str.write(
        '  $reflectionClass withObject([$className? obj]) => $reflectionClass(obj);\n\n');

    str.write('  static $reflectionClass? _withoutObjectInstance;\n');
    str.write('  @override\n');
    str.write(
        '  $reflectionClass withoutObjectInstance() => _withoutObjectInstance ??= super.withoutObjectInstance() as $reflectionClass;\n\n');

    str.write(
        '  static $reflectionClass get staticInstance => _withoutObjectInstance ??= $reflectionClass();\n\n');

    str.write('  @override\n');
    str.write(
        '   $reflectionClass getStaticInstance() => staticInstance ;\n\n');

    str.write('  static bool _boot = false;'
        '  static void boot() {\n'
        '    if (_boot) return;\n'
        '    _boot = true;\n'
        '    $reflectionClass.staticInstance ;\n'
        '}');

    _buildConstructors(str);

    var classElement = _Element(_classElement);

    var classAnnotationListCode = classElement.annotationsAsListCode;
    if (classAnnotationListCode != 'null') {
      str.write(
          '  static const List<Object> _classAnnotations = $classAnnotationListCode; \n\n');
      str.write('  @override\n');
      str.write(
          '  List<Object> get classAnnotations => List<Object>.unmodifiable(_classAnnotations);\n\n');
    } else {
      str.write('  @override\n');
      str.write(
          '  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);\n\n');
    }

    str.write('\n  @override\n');
    str.write(
        '  List<ClassReflection> siblingsClassReflection() => _siblingsReflection().whereType<ClassReflection>().toList();\n\n');

    str.write('\n  @override\n');
    str.write(
        '  List<Reflection> siblingsReflection() => _siblingsReflection();\n\n');

    str.write('\n  @override\n');
    str.write(
        '  List<Type> get supperTypes => const <Type>[${supperTypes.map((e) => e.name).join(', ')}];\n\n');

    _buildCallMethodToJson(str);

    _buildField(str);
    _buildStaticField(str);

    _buildMethod(str);
    _buildStaticMethod(str);

    str.write('}\n\n');

    return str.toString();
  }

  void _buildConstructors(StringBuffer str) {
    _buildDefaultConstructor(str);

    var entries =
        _toConstructorEntries(this, constructors.where(_canConstruct).toSet());
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get constructorsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  ConstructorReflection<$className>? constructor<R>(String constructorName) {\n');

    _buildSwitches(str, 'constructorName', entries.keys, (name) {
      var constructor = entries[name]!;
      if (verbose) {
        print(constructor);
      }

      var declaringType = constructor.declaringType!.typeNameResolvable;
      var callerCode = constructor.asCallerCode;

      return "ConstructorReflection<$className>("
          "this, $declaringType, '$name', () => $callerCode , "
          "${constructor.normalParametersAsCode} , "
          "${constructor.optionalParametersAsCode}, "
          "${constructor.namedParametersAsCode}, "
          "${constructor.annotationsAsListCode}"
          ")";
    });

    str.write('  }\n\n');
  }

  bool _canConstruct(ConstructorElement? c) {
    if (c == null) return false;
    if (c.isFactory) return true;
    return !_classElement.isAbstract;
  }

  void _buildDefaultConstructor(StringBuffer str) {
    var defaultConstructor = this.defaultConstructor;

    if (_canConstruct(defaultConstructor)) {
      str.write('  @override\n');
      str.write('  bool get hasDefaultConstructor => true;\n');

      str.write('  @override\n');
      str.write(
          '  $className? createInstanceWithDefaultConstructor() => $className();\n');
    } else {
      str.write('  @override\n');
      str.write('  bool get hasDefaultConstructor => false;\n');

      str.write('  @override\n');
      str.write(
          '  $className? createInstanceWithDefaultConstructor() => null;\n');
    }
    str.write('\n');

    var emptyConstructor = this.emptyConstructor;

    if (_canConstruct(emptyConstructor)) {
      str.write('  @override\n');
      str.write('  bool get hasEmptyConstructor => true;\n');

      str.write('  @override\n');
      var name = emptyConstructor!.name;
      str.write(
          '  $className? createInstanceWithEmptyConstructor() => $className.$name();\n');
    } else {
      str.write('  @override\n');
      str.write('  bool get hasEmptyConstructor => false;\n');

      str.write('  @override\n');
      str.write(
          '  $className? createInstanceWithEmptyConstructor() => null;\n');
    }

    var noRequiredArgsConstructor = this.noRequiredArgsConstructor;

    if (_canConstruct(noRequiredArgsConstructor)) {
      str.write('  @override\n');
      str.write('  bool get hasNoRequiredArgsConstructor => true;\n');

      str.write('  @override\n');
      var name = noRequiredArgsConstructor!.name;
      str.write(
          '  $className? createInstanceWithNoRequiredArgsConstructor() => $className.$name();\n');
    } else {
      str.write('  @override\n');
      str.write('  bool get hasNoRequiredArgsConstructor => false;\n');

      str.write('  @override\n');
      str.write(
          '  $className? createInstanceWithNoRequiredArgsConstructor() => null;\n');
    }

    str.write('\n');
  }

  void _buildField(StringBuffer str) {
    var entries = _toFieldEntries(fields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get fieldsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  FieldReflection<$className,T>? field<T>(String fieldName, [$className? obj]) {\n');
    str.write('    obj ??= object;\n\n');

    _buildSwitches(str, 'fieldName', entries.keys, (name) {
      var field = entries[name]!;

      if (verbose) {
        print(field);
      }

      var declaringType = field.declaringType!.typeNameResolvable;
      var typeCode = field.typeAsCode;
      var fullType = field.typeNameAsNullableCode;
      var nullable = field.nullable ? 'true' : 'false';
      var isFinal = field.isFinal ? 'true' : 'false';
      var getter = '(o) => () => o!.$name as T';
      var setter = !field.allowSetter
          ? 'null'
          : '(o) => (T? v) => o!.$name = v as $fullType';

      var annotations = field.annotationsAsListCode;

      return "FieldReflection<$className,T>(this, $declaringType, "
          "$typeCode, '$name', $nullable, "
          "$getter , $setter , "
          "obj, false, $isFinal, "
          "$annotations, "
          ")";
    });

    str.write('  }\n\n');
  }

  void _buildStaticField(StringBuffer str) {
    var entries = _toFieldEntries(staticFields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get staticFieldsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  FieldReflection<$className,T>? staticField<T>(String fieldName) {\n');

    _buildSwitches(str, 'fieldName', entries.keys, (name) {
      var field = entries[name]!;
      if (verbose) {
        print(field);
      }

      var declaringType = field.declaringType!.typeNameResolvable;
      var typeCode = field.typeAsCode;
      var fullType = field.typeNameAsNullableCode;
      var nullable = field.nullable ? 'true' : 'false';
      var isFinal = field.isFinal ? 'true' : 'false';
      var getter = '(o) => () => $className.$name as T';
      var setter = !field.allowSetter
          ? 'null'
          : '(o) => (T? v) => $className.$name = v as $fullType';

      return "FieldReflection<$className,T>(this, $declaringType, "
          "$typeCode, '$name', $nullable, "
          "$getter , $setter , "
          "null, true, $isFinal, "
          "${field.annotationsAsListCode}, "
          ")";
    });

    str.write('  }\n\n');
  }

  Map<String, _Field> _toFieldEntries(Set<FieldElement> fields) {
    return Map.fromEntries(fields.map((e) => MapEntry(e.name, _Field(e))));
  }

  void _buildCallMethodToJson(StringBuffer str) {
    var entries = _toMethodsEntries(methods);

    var toJsonMethod = entries.values
        .where((m) => m.name.toLowerCase() == 'tojson')
        .firstOrNull;

    if (toJsonMethod != null &&
        toJsonMethod.normalParameters.isEmpty &&
        !toJsonMethod.hasRequiredNamedParameter) {
      str.write('  @override\n');
      str.write('  bool get hasMethodToJson => true;\n\n');
      str.write('  @override\n');
      str.write(
          '  Object? callMethodToJson([$className? obj]) { obj ??= object ; return obj?.${toJsonMethod.name}();}\n\n');
    } else {
      str.write('  @override\n');
      str.write('  bool get hasMethodToJson => false;\n\n');
      str.write('  @override\n');
      str.write('  Object? callMethodToJson([$className? obj]) => null;\n\n');
    }
  }

  void _buildMethod(StringBuffer str) {
    var entries = _toMethodsEntries(methods);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get methodsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  MethodReflection<$className,R>? method<R>(String methodName, [$className? obj]) {\n');
    str.write('    obj ??= object;\n\n');

    _buildSwitches(str, 'methodName', entries.keys, (name) {
      var method = entries[name]!;
      if (verbose) {
        print(method);
      }

      var declaringType = method.declaringType!.typeNameResolvable;
      var returnTypeAsCode = method.returnTypeAsCode;
      var nullable = method.returnNullable ? 'true' : 'false';

      return "MethodReflection<$className,R>("
          "this, $declaringType, '$name', $returnTypeAsCode, $nullable, (o) => o!.$name , obj , false, "
          "${method.normalParametersAsCode} , "
          "${method.optionalParametersAsCode}, "
          "${method.namedParametersAsCode}, "
          "${method.annotationsAsListCode}"
          ")";
    });

    str.write('  }\n\n');
  }

  void _buildStaticMethod(StringBuffer str) {
    var entries = _toMethodsEntries(staticMethods);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get staticMethodsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  MethodReflection<$className,R>? staticMethod<R>(String methodName) {\n');

    _buildSwitches(str, 'methodName', entries.keys, (name) {
      var method = entries[name]!;
      if (verbose) {
        print(method);
      }

      var declaringType = method.declaringType!.typeNameResolvable;
      var returnTypeAsCode = method.returnTypeAsCode;
      var nullable = method.returnNullable ? 'true' : 'false';

      return "MethodReflection<$className,R>("
          "this, $declaringType, '$name', $returnTypeAsCode, $nullable, (o) => $className.$name , null , true, "
          "${method.normalParametersAsCode} , "
          "${method.optionalParametersAsCode}, "
          "${method.namedParametersAsCode}, "
          "${method.annotationsAsListCode}"
          ")";
    });

    str.write('  }\n\n');
  }

  Map<String, _Constructor> _toConstructorEntries(
      _ClassTree<T> classTree, Set<ConstructorElement> elements) {
    return Map.fromEntries(elements.map((c) {
      return MapEntry(c.name, _Constructor(classTree, c));
    }));
  }

  Map<String, _Method> _toMethodsEntries(Set<MethodElement> elements) {
    return Map.fromEntries(elements.map((m) {
      return MapEntry(m.name, _Method(m));
    }));
  }

  void _buildSwitches(StringBuffer str, String argName,
      Iterable<String> entriesNames, String Function(String name) caseReturn) {
    var namesLcConflicts = <String>{};

    var namesLC = <String, String>{};
    for (var m in entriesNames) {
      var mLC = m.toLowerCase();
      var prevM = namesLC[mLC];

      if (prevM != null) {
        namesLcConflicts.add(prevM);
        namesLcConflicts.add(m);
      } else {
        namesLC[mLC] = m;
      }
    }

    if (namesLcConflicts.isNotEmpty) {
      str.write('    switch($argName) {\n');

      for (var m in namesLcConflicts) {
        var ret = caseReturn(m);
        str.write("      case '$m': return $ret;\n");
        namesLC.remove(m);
      }

      str.write('      default: break;\n');

      str.write('    }\n\n');
    }

    if (namesLC.isNotEmpty) {
      str.write('    var lc = $argName.trim().toLowerCase();\n\n');

      str.write('    switch(lc) {\n');

      for (var m in namesLC.entries) {
        var ret = caseReturn(m.value);
        str.write("      case '${m.key}': return $ret;\n");
      }

      str.write('      default: return null;\n');
      str.write('    }\n');
    } else {
      str.write('    return null;\n');
    }
  }

  String buildReflectionExtension() {
    var str = StringBuffer();

    _buildExtension(str);

    return str.toString();
  }

  void _buildExtension(StringBuffer codeBuffer) {
    var str = StringBuffer();

    str.write('extension $reflectionExtension on $className {\n');

    var entriesCount = 0;

    if (!hasEntry('reflection')) {
      str.write(
          '  /// Returns a [ClassReflection] for type [$className]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  ClassReflection<$className> get reflection => $reflectionClass(this);\n');
      entriesCount++;
    }

    if (!hasEntry('toJson')) {
      str.write(
          '\n  /// Returns a JSON for type [$className]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  Object? toJson({bool duplicatedEntitiesAsID = false}) => reflection.toJson(null, null, duplicatedEntitiesAsID);\n');
      entriesCount++;
    }

    if (!hasEntry('toJsonMap')) {
      str.write(
          '\n  /// Returns a JSON [Map] for type [$className]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  Map<String,dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) => reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);\n');
      entriesCount++;
    }

    if (!hasEntry('toJsonEncoded')) {
      str.write(
          '\n  /// Returns an encoded JSON [String] for type [$className]. (Generated by [ReflectionFactory])\n');
      str.write(
          '  String toJsonEncoded({bool pretty = false, bool duplicatedEntitiesAsID = false}) => reflection.toJsonEncoded(pretty: pretty, duplicatedEntitiesAsID: duplicatedEntitiesAsID);\n');
      entriesCount++;
    }

    if (!hasEntry('toJsonFromFields')) {
      str.write(
          '\n  /// Returns a JSON for type [$className] using the class fields. (Generated by [ReflectionFactory])\n');
      str.write(
          '  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection.toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);\n');
      entriesCount++;
    }

    str.write('}\n\n');

    if (entriesCount > 0) {
      codeBuffer.write(str);
    }
  }

  String buildReflectionProxyClass(
      ClassElement proxyClass,
      bool alwaysReturnFuture,
      Set<DartObject> traverseReturnTypes,
      Set<DartObject> ignoreParametersTypes,
      Set<DartObject> ignoreMethods) {
    if (!_implementsType(proxyClass, 'ClassProxyListener')) {
      throw StateError(
          "`ClassProxy` is being used in a class that is not implementing `ClassProxyListener`: ${proxyClass.name}");
    }

    var str = StringBuffer();

    str.write('extension $reflectionProxyExtension on ${proxyClass.name} {\n');

    var typeProvider = proxyClass.library.typeProvider;

    _buildClassProxyMethods(
        str,
        alwaysReturnFuture,
        traverseReturnTypes.map((e) => e.toTypeValue()!).toSet(),
        ignoreParametersTypes.map((e) => e.toTypeValue()!).toSet(),
        ignoreMethods.map((e) => e.toStringValue()!).toSet(),
        typeProvider);

    str.write('}\n\n');

    return str.toString();
  }

  void _buildClassProxyMethods(
      StringBuffer codeBuffer,
      bool alwaysReturnFuture,
      Set<DartType> traverseReturnTypes,
      Set<DartType> ignoreParametersTypes,
      Set<String> ignoreMethods,
      TypeProvider typeProvider) {
    var str = StringBuffer();

    var traverseReturnInterfaceTypes =
        traverseReturnTypes.map((e) => e.interfaceType).whereNotNull().toSet();

    var entriesCount = 0;

    var methods = this.methods.where((e) => !e.isStatic).toList();

    for (var method in methods) {
      var methodName = method.name;
      if (methodName == 'toString' || ignoreMethods.contains(methodName)) {
        continue;
      }

      var proxyMethod = _ProxyMethod.fromMethodElement(method);

      if (proxyMethod.isReturningFuture) {
        var arg = proxyMethod.returnTypeArgument;

        if (arg != null &&
            (traverseReturnTypes.contains(arg) ||
                traverseReturnInterfaceTypes.contains(arg.interfaceType))) {
          proxyMethod = proxyMethod
              .traverseReturnType()
              .traverseReturnType()
              .returningFuture(typeProvider);
        }
      } else if (proxyMethod.isReturningFutureOr) {
        var arg = proxyMethod.returnTypeArgument;

        if (arg != null &&
            (traverseReturnTypes.contains(arg) ||
                traverseReturnInterfaceTypes.contains(arg.interfaceType))) {
          proxyMethod = proxyMethod
              .traverseReturnType()
              .traverseReturnType()
              .returningFutureOr(typeProvider);
        }
      } else if (traverseReturnTypes.contains(proxyMethod.returnType) ||
          traverseReturnInterfaceTypes
              .contains(proxyMethod.returnType.interfaceType)) {
        proxyMethod = proxyMethod.traverseReturnType();
      }

      if (alwaysReturnFuture && !proxyMethod.isReturningFuture) {
        if (proxyMethod.isReturningFutureOr) {
          proxyMethod =
              proxyMethod.traverseReturnType().returningFuture(typeProvider);
        } else {
          proxyMethod = proxyMethod.returningFuture(typeProvider);
        }
      }

      str.write(proxyMethod.signature(ignoreParametersTypes));

      str.write(' {\n');

      var returnTypeAsCode = proxyMethod.returnType.asTypeReflectionCode;

      var call = StringBuffer();

      call.write("onCall( this, '${proxyMethod.name}', <String,dynamic>{\n");
      for (var p in method.parameters) {
        if (ignoreParametersTypes.containsType(p.type)) continue;
        var name = p.name;
        call.write("  '${p.name}': $name,\n");
      }
      call.write("  }, $returnTypeAsCode );\n");

      if (!proxyMethod.isReturningVoid) {
        str.write('  var ret = ');
        str.write(call);

        if (proxyMethod.isReturningFuture) {
          var acceptsNull = proxyMethod.returnAcceptsNull;

          var futureType = proxyMethod.returnTypeArgument;

          var futureTypeStr = futureType != null && futureType.isVoid
              ? 'dynamic'
              : (futureType?.fullTypeNameResolvable() ?? 'dynamic');

          var returnTypeNullableStr = proxyMethod.returnTypeNameResolvable();

          var returnTypeStr = returnTypeNullableStr.endsWith('?')
              ? returnTypeNullableStr.substring(
                  0, returnTypeNullableStr.length - 1)
              : returnTypeNullableStr;

          if (acceptsNull) {
            str.write('  if (ret == null) return null;\n');
          }

          str.write(
              '  return ret is $returnTypeNullableStr ? ret as $returnTypeNullableStr : '
              '( ret is Future ? ret.then((v) => v as $futureTypeStr) : $returnTypeStr.value(ret as dynamic) '
              ');\n');
        } else {
          str.write('  return ret as dynamic ;\n');
        }
      } else {
        str.write(call);
      }

      str.write('}\n\n');

      entriesCount++;
    }

    if (entriesCount > 0) {
      codeBuffer.write(str);
    }
  }

  bool _implementsType(Object typeElement, String typeName) {
    List<InterfaceType> supertypes;

    if (typeElement is ClassElement) {
      supertypes = typeElement.allSupertypes;
    } else if (typeElement is InterfaceType) {
      supertypes = typeElement.allSupertypes;
    } else {
      return false;
    }

    if (supertypes.isEmpty) return false;

    if (supertypes.any((e) => e.typeName == typeName)) return true;

    return supertypes.any((e) => _implementsType(e, typeName));
  }
}

class _ProxyMethod {
  final String name;

  final DartType returnType;
  final List<ParameterElement> parameters;
  final List<TypeParameterElement> typeParameters;

  _ProxyMethod(
      this.name, this.returnType, this.parameters, this.typeParameters);

  factory _ProxyMethod.fromMethodElement(MethodElement method) {
    return _ProxyMethod(method.name, method.returnType,
        method.parameters.toList(), method.typeParameters.toList());
  }

  List<String> get typeParametersNames =>
      typeParameters.map((e) => e.name).toList();

  List<ParameterElement> get positionalParameters => parameters
      .where((p) => p.isPositional && !p.isOptionalPositional)
      .toList();

  List<ParameterElement> get positionalOptionalParameters =>
      parameters.where((p) => p.isOptionalPositional).toList();

  List<ParameterElement> get namedParameters =>
      parameters.where((p) => p.isNamed).toList();

  bool get returnAcceptsNull => returnType.isNullable;

  bool get isReturningVoid => returnType.isVoid;

  bool get isReturningFuture => returnType.isDartAsyncFuture;

  bool get isReturningFutureOr => returnType.isDartAsyncFutureOr;

  String get returnTypeAsString =>
      returnType.getDisplayString(withNullability: true);

  String returnTypeNameResolvable({bool withNullability = true}) =>
      returnType.fullTypeNameResolvable(
          withNullability: withNullability,
          typeParameters: typeParametersNames);

  DartType? get returnTypeArgument {
    if (!returnType.hasTypeArguments) return null;

    var args = returnType.resolvedTypeArguments;
    if (args.isEmpty) return null;

    return args[0];
  }

  String signature(Set<DartType> ignoreParametersTypes) {
    var typeParametersStr = typeParametersSignature();
    var parametersStr = parametersSignature(ignoreParametersTypes);
    var returnTypeStr = returnTypeNameResolvable();
    var methodStr = '$returnTypeStr $name$typeParametersStr($parametersStr)';
    return methodStr;
  }

  String typeParametersSignature() {
    var parametersStr = StringBuffer();

    for (var p in typeParameters) {
      var pStr = p.getDisplayString(withNullability: true);
      if (pStr.startsWith('{') || pStr.startsWith('[')) {
        pStr = pStr.substring(1, pStr.length - 1).trim();
      }
      parametersStr.write(pStr);
    }

    if (parametersStr.isEmpty) {
      return '';
    }

    return '<$parametersStr>';
  }

  String parametersSignature(Set<DartType> ignoreParametersTypes) {
    var positionalParameters = this.positionalParameters;
    var positionalOptionalParameters = this.positionalOptionalParameters;
    var namedParameters = this.namedParameters;

    var parametersStr = StringBuffer();

    if (positionalParameters.isNotEmpty) {
      _writeParameters(
          parametersStr, positionalParameters, ignoreParametersTypes);
    }

    if (positionalOptionalParameters.isNotEmpty) {
      if (parametersStr.isNotEmpty) {
        parametersStr.write(', ');
      }

      parametersStr.write('[ ');
      _writeParameters(
          parametersStr, positionalOptionalParameters, ignoreParametersTypes);
      parametersStr.write(' ]');
    }

    if (namedParameters.isNotEmpty) {
      if (parametersStr.isNotEmpty) {
        parametersStr.write(', ');
      }

      parametersStr.write('{ ');
      _writeParameters(parametersStr, namedParameters, ignoreParametersTypes);
      parametersStr.write(' }');
    }

    return parametersStr.toString();
  }

  void _writeParameters(StringBuffer parametersStr,
      List<ParameterElement> parameters, Set<DartType> ignoreParametersTypes) {
    for (int i = 0; i < parameters.length; i++) {
      var e = parameters[i];

      if (ignoreParametersTypes.containsType(e.type)) continue;

      if (i > 0) parametersStr.write(', ');
      var pStr = e.getDisplayString(withNullability: true);
      if (pStr.startsWith('{') || pStr.startsWith('[')) {
        pStr = pStr.substring(1, pStr.length - 1).trim();
      }
      parametersStr.write(pStr);
    }
  }

  _ProxyMethod returningFuture(TypeProvider typeProvider) {
    if (returnType.isDartAsyncFuture) return this;

    var retType = typeProvider.futureType(returnType);
    return _ProxyMethod(name, retType, parameters, typeParameters);
  }

  _ProxyMethod returningFutureOr(TypeProvider typeProvider) {
    if (returnType.isDartAsyncFutureOr) return this;

    var retType = typeProvider.futureOrType(returnType);
    return _ProxyMethod(name, retType, parameters, typeParameters);
  }

  _ProxyMethod traverseReturnType() {
    var arg = returnTypeArgument;
    if (arg == null) return this;
    return _ProxyMethod(name, arg, parameters, typeParameters);
  }

  @override
  String toString() {
    return '_ProxyMethod{name: $name, returnType: $returnType, parameters: $parameters, typeParameters: $typeParameters}';
  }
}

class _Element {
  final Element _element;

  _Element(this._element);

  DartType? get declaringType {
    var element = _element;
    if (element is ClassElement) {
      return null;
    }

    var enclosingElement = element.enclosingElement3;

    if (enclosingElement is ClassElement) {
      return enclosingElement.thisType;
    }

    return null;
  }

  List<ElementAnnotation> get annotations => _element.metadata;

  List<String> get annotationsAsCode {
    var element = _element;
    var metadata = List<ElementAnnotation>.from(element.metadata);

    if (element is FieldElement) {
      var getter = element.getter;
      if (getter != null) {
        metadata.addAll(getter.metadata);
      }

      var setter = element.setter;
      if (setter != null) {
        metadata.addAll(setter.metadata);
      }
    }

    return metadata
        .map((e) => e.toSource())
        .where((src) =>
            !src.startsWith('@EnableReflection(') &&
            !src.startsWith('@ReflectionBridge('))
        .map((src) {
      if (src.startsWith('@')) {
        src = src.substring(1);
      }
      return src;
    }).toList();
  }

  String get annotationsAsListCode {
    var codes = annotationsAsCode;
    return codes.isEmpty ? 'null' : '[${codes.join(',')}]';
  }
}

class _Parameter extends _Element {
  final ParameterElement parameterElement;
  final int parameterIndex;

  final DartType type;
  final String name;

  final bool nullable;

  final bool required;

  _Parameter(this.parameterElement, this.parameterIndex, this.type, this.name,
      this.nullable, this.required)
      : super(parameterElement);

  bool get isNullable => nullable || type.isDynamic;

  String? get defaultValue => parameterElement.defaultValueCode;

  bool get hasDefaultValue {
    var valCode = defaultValue;
    return valCode != null && valCode.isNotEmpty;
  }

  @override
  String toString() {
    return '_Parameter{type: $type, name: $name, nullable: $nullable, required: $required, parameterElement: $parameterElement, parameterIndex: $parameterIndex}';
  }
}

class _Constructor<T> extends _Element {
  final _ClassTree<T> classTree;

  final ConstructorElement constructorElement;

  _Constructor(this.classTree, this.constructorElement)
      : super(constructorElement);

  String get name => constructorElement.name;

  bool get returnNullable => constructorElement.returnType.isNullable;

  bool get isStatic => constructorElement.isStatic;

  String get returnTypeNameAsCode =>
      constructorElement.returnType.typeNameAsCode;

  String get returnTypeAsCode =>
      constructorElement.returnType.asTypeReflectionCode;

  List<_Parameter> get normalParameters =>
      constructorElement.type.normalParameters;

  List<_Parameter> get optionalParameters =>
      constructorElement.type.optionalParameters;

  Map<String, _Parameter> get namedParameters =>
      constructorElement.type.namedParameters;

  String get normalParametersAsCode =>
      _buildParameterReflectionList(normalParameters,
          nullOnEmpty: true, required: true);

  String get optionalParametersAsCode =>
      _buildParameterReflectionList(optionalParameters,
          nullOnEmpty: true, required: false);

  String get namedParametersAsCode =>
      _buildNamedParameterReflectionMap(namedParameters, nullOnEmpty: true);

  String get asCallerCode {
    var s = StringBuffer();

    var normalParameters = constructorElement.normalParameters;
    var optionalParameters = constructorElement.optionalParameters;
    var namedParameters = constructorElement.namedParameters;

    s.write('(');

    for (var i = 0; i < normalParameters.length; ++i) {
      var p = normalParameters[i];
      if (i > 0) s.write(', ');

      s.write(p.type.typeNameAsNullableCode);
      s.write(' ');
      s.write(p.name);
    }

    if (optionalParameters.isNotEmpty) {
      if (normalParameters.isNotEmpty) s.write(', ');

      s.write('[');

      for (var i = 0; i < optionalParameters.length; ++i) {
        var p = optionalParameters[i];
        if (i > 0) s.write(',');
        s.write(p.type.typeNameAsNullableCode);
        s.write(' ');
        s.write(p.name);
        var defVal = p.defaultValue;
        if (defVal != null) {
          s.write(' = ');
          s.write(defVal);
        }
      }
      s.write(']');
    } else if (namedParameters.isNotEmpty) {
      if (normalParameters.isNotEmpty) s.write(', ');

      s.write('{');
      var i = 0;
      for (var e in namedParameters.entries) {
        var p = e.value;
        if (i > 0) s.write(', ');

        if (p.required) {
          s.write('required ');
        }

        s.write(p.type.typeNameAsNullableCode);
        s.write(' ');
        s.write(p.name);
        var defVal = p.defaultValue;
        if (defVal != null) {
          s.write(' = ');
          s.write(defVal);
        }
        i++;
      }
      s.write('}');
    }

    s.write(') => ');

    s.write(classTree.className);
    if (name.isNotEmpty) {
      s.write('.');
      s.write(name);
    }

    s.write('(');

    for (var i = 0; i < normalParameters.length; ++i) {
      var p = normalParameters[i];
      if (i > 0) s.write(',');
      s.write(p.name);
    }

    if (optionalParameters.isNotEmpty) {
      if (normalParameters.isNotEmpty) s.write(', ');

      for (var i = 0; i < optionalParameters.length; ++i) {
        var p = optionalParameters[i];
        if (i > 0) s.write(',');
        s.write(p.name);
      }
    } else if (namedParameters.isNotEmpty) {
      if (normalParameters.isNotEmpty) s.write(', ');

      var i = 0;
      for (var e in namedParameters.entries) {
        var k = e.key;
        var p = e.value;
        if (i > 0) s.write(',');
        s.write(k);
        s.write(': ');
        s.write(p.name);
        i++;
      }
    }

    s.write(') ');

    return s.toString();
  }

  @override
  String toString() {
    return '_Constructor{ '
        'name: $name, '
        'static: $isStatic, '
        'return: $returnTypeNameAsCode '
        '}( '
        'normal: $normalParameters, '
        'optional: $optionalParameters, '
        'named: $namedParameters '
        ')<$constructorElement>';
  }
}

class _Method extends _Element {
  final MethodElement methodElement;

  _Method(this.methodElement) : super(methodElement);

  String get name => methodElement.name;

  bool get returnNullable => methodElement.returnType.isNullable;

  bool get isStatic => methodElement.isStatic;

  String get returnTypeNameAsCode => methodElement.returnType.typeNameAsCode;

  String get returnTypeAsCode => methodElement.returnType.asTypeReflectionCode;

  List<_Parameter> get normalParameters => methodElement.type.normalParameters;

  List<_Parameter> get optionalParameters =>
      methodElement.type.optionalParameters;

  Map<String, _Parameter> get namedParameters =>
      methodElement.type.namedParameters;

  bool get hasRequiredNamedParameter => namedParameters.values
      .where((m) => m.required || (!m.isNullable && !m.hasDefaultValue))
      .isNotEmpty;

  String get normalParametersAsCode =>
      _buildParameterReflectionList(normalParameters,
          nullOnEmpty: true, required: true);

  String get optionalParametersAsCode =>
      _buildParameterReflectionList(optionalParameters,
          nullOnEmpty: true, required: false);

  String get namedParametersAsCode =>
      _buildNamedParameterReflectionMap(namedParameters, nullOnEmpty: true);

  @override
  String toString() {
    return '_Method{ '
        'name: $name, '
        'static: $isStatic, '
        'return: $returnTypeNameAsCode '
        '}( '
        'normal: $normalParameters, '
        'optional: $optionalParameters, '
        'named: $namedParameters '
        ')<$methodElement>';
  }
}

class _Field extends _Element {
  final FieldElement fieldElement;

  _Field(this.fieldElement) : super(fieldElement);

  String get name => fieldElement.name;

  bool get nullable => fieldElement.type.isNullable;

  bool get isStatic => fieldElement.isStatic;

  bool get isFinal => fieldElement.isFinal;

  bool get isConst => fieldElement.isConst;

  bool get allowSetter => !isFinal && !isConst && fieldElement.setter != null;

  String get typeNameAsCode => fieldElement.type.typeNameAsCode;

  String get typeNameAsNullableCode => fieldElement.type.typeNameAsNullableCode;

  String get typeAsCode => fieldElement.type.asTypeReflectionCode;

  @override
  String toString() {
    return '_Field{ '
        'name: $name, '
        'static: $isStatic, '
        'final: $isFinal, '
        'const: $isConst, '
        'allowSetter: $allowSetter '
        '}<$fieldElement>';
  }
}

extension _IterableExtension on Iterable<DartType> {
  bool containsType(DartType dartType) {
    var dartTypeName = dartType.typeName;

    for (var t in this) {
      if (!t.isResolvableType) continue;

      if (t.typeName == dartTypeName) {
        return true;
      }
    }

    return false;
  }
}

extension _ListDartTypeExtension on List<DartType> {
  List<String> get typesNamesResolvable =>
      map((a) => a.typeNameResolvable).toList();

  String get toListOfConstTypeCode {
    var listConstTypeReflection =
        map((e) => e.asConstTypeReflectionCode).toList(growable: false);
    if (listConstTypeReflection.every((e) => e != null)) {
      return '<TypeReflection>[${listConstTypeReflection.join(',')}]';
    }

    var listConstTypeInfo =
        map((e) => e.asConstTypeInfoCode).toList(growable: false);
    if (listConstTypeInfo.every((e) => e != null)) {
      return '<TypeInfo>[${listConstTypeInfo.join(',')}]';
    }

    var listTypeReflection =
        map((e) => e.asTypeReflectionCode).toList(growable: false);
    return '<TypeReflection>[${listTypeReflection.join(',')}]';
  }

  String get typesNames =>
      map((e) => e.fullTypeNameResolvable(withNullability: true)).join(', ');
}

extension _DartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;

  bool get isParameterType => this is TypeParameterType;

  bool get isResolvableType => !isParameterType;

  String get typeNameResolvable => resolveTypeName();

  String resolveTypeName({Iterable<String>? typeParameters}) {
    if (typeParameters != null &&
        isParameterType &&
        typeParameters.isNotEmpty) {
      var name = typeName;
      var nameResolved = typeParameters.contains(name) ? name : 'dynamic';
      return nameResolved;
    }

    var name = !isResolvableType ? 'dynamic' : typeName;
    return name;
  }

  String fullTypeNameResolvable(
      {bool withNullability = true, Iterable<String>? typeParameters}) {
    var name = resolveTypeName(typeParameters: typeParameters);

    if (!hasTypeArguments) {
      return withNullability && isNullable ? '$name?' : name;
    }

    var args = resolvedTypeArguments
        .map((e) => e.fullTypeNameResolvable(
            withNullability: withNullability, typeParameters: typeParameters))
        .join(',');

    return withNullability && isNullable ? '$name<$args>?' : '$name<$args>';
  }

  String get typeName {
    var name = elementDeclaration?.name;

    if (name == null) {
      name = getDisplayString(withNullability: false);

      var idx = name.indexOf('Function(');

      if (idx == 0 ||
          (idx > 0 && name.substring(idx - 1, idx).trim().isEmpty)) {
        name = 'Function';
      } else {
        idx = name.indexOf('<');
        if (idx > 0) {
          name = name.substring(0, idx);
        }
      }
    }

    return name;
  }

  InterfaceType? get interfaceType {
    var element = elementDeclaration;
    if (element is ClassElement) {
      return element.thisType;
    }
    return null;
  }

  bool get hasTypeArguments {
    var self = this;
    if (self is ParameterizedType) {
      return self.typeArguments.isNotEmpty;
    } else {
      return false;
    }
  }

  bool get hasSimpleTypeArguments {
    var self = this;

    if (self is ParameterizedType && self.typeArguments.isNotEmpty) {
      return self.typeArguments.where((e) => !e.hasTypeArguments).length ==
          self.typeArguments.length;
    }

    return false;
  }

  List<DartType> get resolvedTypeArguments {
    var self = this;
    if (self is ParameterizedType) {
      return self.typeArguments;
    } else {
      return <DartType>[];
    }
  }

  String get typeNameAsCode {
    var self = this;
    if (self is VoidType) {
      return 'void';
    }

    if (self is FunctionType) {
      var alias = self.alias;
      if (alias != null && alias.typeArguments.isEmpty) {
        var name = alias.element.name;
        return name;
      } else {
        var functionType = self.getDisplayString(withNullability: false);
        return functionType;
      }
    }

    var name = typeNameResolvable;
    var arguments = resolvedTypeArguments;

    if (arguments.isNotEmpty) {
      return '$name<${arguments.map((e) => e.typeNameAsCode).join(', ')}>';
    } else {
      return name;
    }
  }

  String get typeNameAsNullableCode =>
      isNullable && !isDynamic && isResolvableType
          ? '$typeNameAsCode?'
          : typeNameAsCode;

  String? get asConstTypeReflectionCode {
    var self = this;

    if (self is VoidType) {
      return 'TypeReflection.tVoid';
    }

    if (self is FunctionType) {
      var alias = self.alias;
      if (alias != null) {
        return null;
      } else {
        return 'TypeReflection.tFunction';
      }
    }

    var name = typeNameResolvable;
    var arguments = resolvedTypeArguments;

    if (arguments.isNotEmpty) {
      if (hasSimpleTypeArguments) {
        var typeArgs = arguments.typesNamesResolvable;

        var constName = TypeReflection.getConstantName(name, typeArgs);
        if (constName != null) {
          return 'TypeReflection.$constName';
        }
      }

      return null;
    } else {
      var constName = _getTypeReflectionConstantName(name);
      if (constName != null) {
        return 'TypeReflection.$constName';
      } else if (this is TypeParameterType) {
        return 'TypeReflection.tDynamic';
      }

      return null;
    }
  }

  String get asTypeReflectionCode {
    var self = this;

    if (self is VoidType) {
      return 'TypeReflection.tVoid';
    }

    if (self is FunctionType) {
      var alias = self.alias;
      if (alias != null) {
        var name = alias.element.name;
        List<DartType> arguments = alias.typeArguments;

        if (arguments.isEmpty) {
          return 'TypeReflection<$name>($name)';
        } else {
          return 'TypeReflection<$name<${arguments.typesNames}>>($name, ${arguments.toListOfConstTypeCode})';
        }
      } else {
        return 'TypeReflection.tFunction';
      }
    }

    var name = typeNameResolvable;
    var arguments = resolvedTypeArguments;

    if (arguments.isNotEmpty) {
      if (hasSimpleTypeArguments) {
        var typeArgs = arguments.typesNamesResolvable;

        var constName = TypeReflection.getConstantName(name, typeArgs);
        if (constName != null) {
          return 'TypeReflection.$constName';
        }
      }

      var argsT = arguments.typesNames;
      var argsCode = arguments.toListOfConstTypeCode;

      return 'TypeReflection<$name<$argsT>>($name, $argsCode)';
    } else {
      var constName = _getTypeReflectionConstantName(name);
      if (constName != null) {
        return 'TypeReflection.$constName';
      } else {
        if (this is TypeParameterType) {
          return 'TypeReflection.tDynamic';
        } else {
          return 'TypeReflection<$name>($name)';
        }
      }
    }
  }

  String? _getTypeReflectionConstantName([String? name, List<String>? args]) {
    if (isDartCoreObject) {
      return 'tObject';
    } else if (isDartCoreString) {
      return 'tString';
    } else if (isDartCoreInt) {
      return 'tInt';
    } else if (isDartCoreDouble) {
      return 'tDouble';
    } else if (isDartCoreNum) {
      return 'tNum';
    } else if (isDartCoreBool) {
      return 'tBool';
    } else if (this is VoidType) {
      return 'tVoid';
    }

    name ??= typeNameResolvable;
    args ??= resolvedTypeArguments.typesNamesResolvable;
    return TypeReflection.getConstantName(name, args);
  }

  String? get asConstTypeInfoCode {
    var constName = _getTypeReflectionConstantName();
    return constName == null ? null : 'TypeInfo.$constName';
  }
}

extension _ConstructorElementExtension on ConstructorElement {
  List<_Parameter> parametersWhere(bool Function(ParameterElement p) filter) {
    var list = <_Parameter>[];
    var i = 0;
    for (var p in parameters) {
      if (filter(p)) {
        var param = _Parameter(
            p, i, p.type, p.name, p.type.isNullable, p.isRequiredNamed);
        list.add(param);
      }
      i++;
    }
    return list;
  }

  List<_Parameter> get normalParameters =>
      parametersWhere((p) => !p.isOptionalPositional && !p.isNamed);

  List<_Parameter> get optionalParameters =>
      parametersWhere((p) => p.isOptionalPositional);

  Map<String, _Parameter> get namedParameters =>
      Map<String, _Parameter>.fromEntries(
          parametersWhere((p) => p.isNamed).map((e) => MapEntry(e.name, e)));
}

extension _FunctionTypeExtension on FunctionType {
  List<_Parameter> get normalParameters {
    return List<_Parameter>.generate(normalParameterNames.length, (i) {
      var n = normalParameterNames[i];
      var t = normalParameterTypes[i];
      var p = parameters[i];
      return _Parameter(p, i, t, n, t.isNullable, true);
    });
  }

  List<_Parameter> get optionalParameters {
    return List<_Parameter>.generate(optionalParameterNames.length, (i) {
      var n = optionalParameterNames[i];
      var t = optionalParameterTypes[i];
      var idx = normalParameterNames.length + i;
      var p = parameters[idx];
      return _Parameter(p, idx, t, n, t.isNullable, false);
    });
  }

  Map<String, _Parameter> get namedParameters {
    var map = <String, _Parameter>{};
    var normalParametersLength = normalParameterNames.length;
    var namedParametersLength = namedParameterTypes.length;

    for (var i = 0; i < namedParametersLength; ++i) {
      var idx = normalParametersLength + i;
      var p = parameters[idx];
      var key = p.name;
      var type = p.type;
      var required = p.isRequiredNamed;
      var parameter = _Parameter(p, idx, type, key, type.isNullable, required);
      map[key] = parameter;
    }

    return map;
  }
}

String _buildStringListCode(Iterable? o,
    {bool sorted = false, bool nullOnEmpty = false}) {
  if (o == null || o.isEmpty) {
    return nullOnEmpty ? 'null' : 'const <String>[]';
  } else {
    if (sorted) {
      var l = o.toList();
      l.sort();
      o = l;
    }
    return 'const <String>[${o.map((e) => "'$e'").join(', ')}]';
  }
}

String _buildParameterReflectionList(Iterable<_Parameter>? o,
    {required bool nullOnEmpty, required bool required}) {
  if (o == null || o.isEmpty) {
    return nullOnEmpty ? 'null' : 'const <ParameterReflection>[]';
  } else {
    var parameters = o
        .map((e) => "ParameterReflection( "
            "${e.type.asTypeReflectionCode} , "
            "'${e.name}' , "
            "${e.isNullable ? 'true' : 'false'} , "
            "$required , "
            "${e.defaultValue ?? 'null'} , "
            "${e.annotationsAsListCode}"
            ")")
        .join(', ');
    return 'const <ParameterReflection>[$parameters]';
  }
}

String _buildNamedParameterReflectionMap(Map<String, _Parameter>? o,
    {bool nullOnEmpty = false}) {
  if (o == null || o.isEmpty) {
    return nullOnEmpty ? 'null' : 'const <String,Type>{}}';
  } else {
    var parameters = o.entries.map((e) {
      var key = e.key;
      var value = e.value;
      return "'$key': ParameterReflection( "
          "${value.type.asTypeReflectionCode} , "
          "'${e.value.name}' , "
          "${e.value.isNullable ? 'true' : 'false'} , "
          "${e.value.required ? 'true' : 'false'} , "
          "${e.value.defaultValue ?? 'null'} , "
          "${e.value.annotationsAsListCode}"
          ")";
    }).join(', ');
    return 'const <String,ParameterReflection>{$parameters}';
  }
}
