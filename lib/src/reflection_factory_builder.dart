import 'dart:collection';
import 'dart:io';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/visitor2.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:reflection_factory/reflection_factory.dart';
import 'package:logging/logging.dart' show Logger;

import 'analyzer/input_analyzer.dart';
import 'analyzer/library.dart';
import 'analyzer/type_checker.dart';

/// The reflection builder.
class ReflectionBuilder implements Builder {
  /// The [ReflectionBuilder] global [Logger].
  static Logger get logger => log;

  /// If `true` builds the reflection code in verbose mode.
  final bool verbose;

  /// If `true` will process the [BuildStep]s sequentially. See [build].
  final bool sequential;

  /// The sequential [BuildStep] timeout (default: 30 sec). See [build].
  final Duration buildStepTimeout;

  ReflectionBuilder({
    this.verbose = false,
    bool sequential = true,
    this.buildStepTimeout = const Duration(seconds: 30),
  }) : sequential = sequential && buildStepTimeout.inMilliseconds > 0;

  /// The [ReflectionFactory.VERSION].
  String get version => ReflectionFactory.VERSION;

  @override
  String toString({
    bool verbose = false,
    bool multiline = false,
    String indent = '',
  }) {
    if (!verbose) {
      return 'ReflectionBuilder[$version]';
    }

    var dartVersion = Platform.version;

    if (!multiline) {
      var parts = dartVersion.split(RegExp(r'\s+'));
      if (parts.length > 2) {
        parts = parts.sublist(0, 2);
      }
      dartVersion = parts.join(' ');
    }

    var infos = [
      'Dart: $dartVersion',
      'verbose: $verbose',
      'sequential: $sequential',
      'buildStepTimeout: ${buildStepTimeout.toHumanReadable()}',
    ].join(multiline ? '\n$indent» ' : ', ');

    if (multiline) {
      infos = '\n$indent» $infos\n$indent';
    }

    return '${indent}ReflectionBuilder[$version]{$infos}';
  }

  @override
  final buildExtensions = const {
    '{{dir}}/{{file}}.dart': [
      '{{dir}}/reflection/{{file}}.g.dart',
      '{{dir}}/{{file}}.reflection.g.dart',
    ],
  };

  static const TypeChecker typeReflectionBridge = TypeChecker.fromRuntime(
    ReflectionBridge,
  );

  static const TypeChecker typeEnableReflection = TypeChecker.fromRuntime(
    EnableReflection,
  );

  static const TypeChecker typeClassProxy = TypeChecker.fromRuntime(ClassProxy);

  Future<void> _buildChain = Future<void>.value();

  /// If [sequential] is `true` every [BuildStep] is processed sequentially (only one at a time):
  /// - The default timeout to process a [BuildStep] is 30 sec ([buildStepTimeout]).
  ///   If the timeout is reached the next [BuildStep] starts to be processed.
  /// - `build_runner` will wait for ALL the [BuildStep]s to complete (regardless of any timeout).
  @override
  Future<void> build(BuildStep buildStep) {
    // Skip code from `reflection_factory` library.
    if (_isReflectionFactoryLibraryCode(buildStep.inputId)) {
      return Future<void>.value();
    }

    if (!sequential) {
      return _buildImpl(buildStep);
    }

    var buildChain = _buildChain;

    var buildTimeout = Completer<void>();
    void complete(_) => buildTimeout.complete();

    Future<void> callBuildImpl(_) {
      var future = _buildImpl(buildStep);

      unawaited(
        future
            .timeout(
              buildStepTimeout,
              onTimeout: () => _onBuildTimeout(buildStep),
            )
            .then(complete, onError: complete),
      );

      return future;
    }

    var build = buildChain.then(callBuildImpl, onError: callBuildImpl);

    // The chain wil have a scheduled timeout only
    // for the last running [BuildStep].
    _buildChain = buildTimeout.future;

    // Return the call without timeout for the `build_runner`.
    return build;
  }

  bool _isReflectionFactoryLibraryCode(AssetId assetId) {
    if (assetId.package == 'reflection_factory') {
      if (!assetId.path.startsWith('example/') &&
          !assetId.path.startsWith('test/')) {
        return true;
      }
    }
    return false;
  }

  void _onBuildTimeout(BuildStep buildStep) {
    log.warning(
      'Build timeout (${buildStepTimeout.toHumanReadable()}): ${buildStep.inputId} » Will continue with the next `BuildStep`...',
    );
  }

  Future<void> _buildImpl(BuildStep buildStep) async {
    final initTime = DateTime.now();

    log.info(" analyzing...");

    try {
      var inputAnalyzer = await InputAnalyzer(buildStep).resolved();

      final inputPartOf = inputAnalyzer.inputCompilationUnitPartOf();
      final isPart = inputPartOf != null;
      if (isPart) {
        final elapsedTime = DateTime.now().difference(initTime);
        log.info(
          " skipping `part` compilation unit. (${elapsedTime.inMilliseconds} ms)",
        );
        return;
      }

      final inputParts = inputAnalyzer.inputCompilationUnitParts();
      if (inputParts.isEmpty) {
        var reflectionAnnotations =
            await inputAnalyzer.inputReflectionAnnotations();

        if (reflectionAnnotations.isEmpty) {
          final elapsedTime = DateTime.now().difference(initTime);
          log.info(
            "No `part` directive or reflection annotations found, no reflection to generate. (${elapsedTime.inMilliseconds} ms)",
          );
          return;
        }
      }

      final genPart = await buildStep.trackStage(
        'Resolving `part` to generate',
        () => inputAnalyzer.resolveGeneratedPart(),
      );

      if (genPart == null) {
        final elapsedTime = DateTime.now().difference(initTime);
        log.info(
          " no reflection to generate. (${elapsedTime.inMilliseconds} ms)",
        );
        return;
      }

      final libraryReader = await inputAnalyzer.libraryReader;

      final inputLib = libraryReader.element;
      var inputLibName = inputLib.libraryName;

      if (inputLibName == 'reflection_factory' ||
          inputLibName.startsWith('reflection_factory.') ||
          inputLibName.startsWith('reflection_factory_') ||
          inputLibName.startsWith('package:reflection_factory/')) {
        return;
      }

      final typeAliasTable = _TypeAliasTable.fromLibraryReader(libraryReader);

      final codeTable = await buildStep.trackStage(
        'Generating reflection code',
        () => _buildCodeTable(inputAnalyzer, typeAliasTable),
      );

      if (codeTable.isEmpty) {
        throw StateError("Generated code expected for: ${buildStep.inputId}");
      }

      await buildStep.trackStage(
        'Writing generated code',
        () => _writeFullCode(buildStep, genPart, codeTable, initTime),
      );
    } finally {
      final resolver = buildStep.resolver;
      if (resolver is ReleasableResolver) {
        resolver.release();
      }
    }
  }

  Future<void> _writeFullCode(
    BuildStep buildStep,
    GeneratedPart genPart,
    _CodeTable codeTable,
    DateTime initTime,
  ) async {
    var fullCode = StringBuffer();

    fullCode.write('// \n');
    fullCode.write('// GENERATED CODE - DO NOT MODIFY BY HAND!\n');
    fullCode.write(
      '// BUILDER: reflection_factory/${ReflectionFactory.VERSION}\n',
    );
    fullCode.write('// BUILD COMMAND: dart run build_runner build\n');
    fullCode.write('// \n\n');

    fullCode.write('// coverage:ignore-file\n');
    fullCode.write('// ignore_for_file: unused_element\n');
    fullCode.write(
      '// ignore_for_file: no_leading_underscores_for_local_identifiers\n',
    );
    fullCode.write('// ignore_for_file: camel_case_types\n');
    fullCode.write('// ignore_for_file: camel_case_extensions\n');
    fullCode.write('// ignore_for_file: deprecated_member_use\n');
    fullCode.write(
      '// ignore_for_file: deprecated_member_use_from_same_package\n',
    );
    fullCode.write('// ignore_for_file: unnecessary_const\n');
    fullCode.write('// ignore_for_file: unnecessary_cast\n');
    fullCode.write('// ignore_for_file: unnecessary_type_check\n\n');

    fullCode.write("part of '${genPart.partOf}';\n\n");

    fullCode.write(codeTable.typeAliasTable.code);
    fullCode.write('\n');

    fullCode.write(codeTable.codeReflectionMixin);
    fullCode.write('\n');
    fullCode.write(codeTable.codeSymbolsTable);

    var codeKeys = codeTable.allKeys.toList();
    _sortCodeKeys(codeKeys);

    for (var key in codeKeys) {
      var code = codeTable.get(key)!;
      if (code.trim().isNotEmpty) {
        fullCode.write(code);
      }
    }

    fullCode.write(codeTable.codeSiblingsClassReflection);

    var generatedCode = fullCode.toString();

    var languageVersion = codeTable.resolveLanguageVersion();

    log.info(" Resolved languageVersion: $languageVersion");

    await _writeGeneratedCode(
      buildStep,
      genPart,
      generatedCode,
      initTime,
      languageVersion,
      codeKeys,
    );
  }

  Future<void> _writeGeneratedCode(
    BuildStep buildStep,
    GeneratedPart genPart,
    String generatedCode,
    DateTime initTime,
    Version? languageVersion, [
    List<String>? codeKeys,
  ]) async {
    languageVersion ??= DartFormatter.latestLanguageVersion;

    var dartFormatter = DartFormatter(languageVersion: languageVersion);

    String formattedCode;
    try {
      formattedCode = dartFormatter.format(generatedCode);
    } catch (e, s) {
      log.severe("Error formatting generated code> $e\n$generatedCode", s);
      rethrow;
    }

    var genId = genPart.genId;

    await buildStep.writeAsString(genId, formattedCode);

    final elapsedTime = DateTime.now().difference(initTime);

    if (codeKeys != null) {
      log.info(
        ' » GENERATED:\n'
        '  -- Elements: $codeKeys\n'
        '  -- File: $genId\n'
        '  -- Time: ${elapsedTime.inMilliseconds} ms\n\n',
      );
    } else {
      log.info(
        ' » CACHED:\n'
        '  -- File: $genId\n'
        '  -- Time: ${elapsedTime.inMilliseconds} ms\n\n',
      );
    }

    if (verbose) {
      log.info('<<<<<<\n$formattedCode\n>>>>>>\n');
    }
  }

  Future<_CodeTable> _buildCodeTable(
    InputAnalyzerResolved inputAnalyzer,
    _TypeAliasTable typeAliasTable,
  ) async {
    final libraryReader = await inputAnalyzer.libraryReader;

    final allAnnotatedElements = libraryReader
        .allAnnotatedElements(classes: true, enums: true)
        .toList(growable: false);

    final allAnnotatedClasses = allAnnotatedElements
        .where((e) => e.kind == ElementKind.CLASS)
        .toList(growable: false);

    final codeTable = _CodeTable(typeAliasTable);

    var annotatedClassProxy = allAnnotatedClasses
        .annotatedWith(typeClassProxy)
        .toList(growable: false);

    for (var annotated in annotatedClassProxy) {
      var codes = await _classProxy(inputAnalyzer, annotated, typeAliasTable);
      codeTable.addProxies(codes);
    }

    if (!codeTable.reflectionProxiesIsEmpty) {
      var codes = _classProxyFunctions(inputAnalyzer, typeAliasTable);
      codeTable.addFunctions(codes);
    }

    var annotatedReflectionBridge = allAnnotatedClasses
        .annotatedWith(typeReflectionBridge)
        .toList(growable: false);

    for (var annotated in annotatedReflectionBridge) {
      var codes = await _reflectionBridge(
        inputAnalyzer,
        annotated,
        typeAliasTable,
      );
      codeTable.addAllClasses(codes);
    }

    var annotatedEnableReflection = allAnnotatedElements
        .annotatedWith(typeEnableReflection)
        .toList(growable: false);

    for (var annotated in annotatedEnableReflection) {
      var annotation = annotated.annotation;
      var reflectionClassName =
          annotation.peek('reflectionClassName')!.stringValue;
      var reflectionExtensionName =
          annotated.annotation.peek('reflectionExtensionName')!.stringValue;
      var optimizeReflectionInstances =
          annotated.annotation.peek('optimizeReflectionInstances')!.boolValue;

      if (annotated.element.kind == ElementKind.CLASS) {
        var classElement = annotated.element as ClassElement;

        var genReflection = await _enableReflectionClass(
          inputAnalyzer,
          classElement,
          reflectionClassName,
          reflectionExtensionName,
          optimizeReflectionInstances,
          typeAliasTable,
        );

        codeTable.addAllClasses(genReflection.codes);

        codeTable.fieldsTypesWithReflection.addAll(
          genReflection.fieldsTypesWithReflection,
        );

        codeTable.staticFieldsTypesWithReflection.addAll(
          genReflection.staticFieldsTypesWithReflection,
        );
      } else if (annotated.element.kind == ElementKind.ENUM) {
        var enumElement = annotated.element;

        var codes = await _enableReflectionEnum(
          inputAnalyzer,
          enumElement,
          reflectionClassName,
          reflectionExtensionName,
          optimizeReflectionInstances,
          typeAliasTable,
        );

        codeTable.addAllClasses(codes);
      }
    }

    _buildReflectionMixin(codeTable);

    _buildSymbolsTable(codeTable);

    _buildSiblingsClassReflection(codeTable);

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

  Map<String, String> _classProxyFunctions(
    InputAnalyzerResolved inputAnalyzer,
    _TypeAliasTable typeAliasTable,
  ) {
    var fReturnValue = typeAliasTable.fReturnValue;
    var fReturnFuture = typeAliasTable.fReturnFuture;
    var fReturnFutureOr = typeAliasTable.fReturnFutureOr;

    var fReturnValueCode =
        '\nT $fReturnValue<T>(Object? o) => ClassProxy.returnValue<T>(o);\n\n';

    var fReturnFutureCode =
        '\nFuture<T> $fReturnFuture<T>(Object? o) => ClassProxy.returnFuture<T>(o);\n\n';

    var fReturnFutureOrCode =
        '\nFutureOr<T> $fReturnFutureOr<T>(Object? o) => ClassProxy.returnFutureOr<T>(o);\n\n';

    return {
      if (typeAliasTable.fReturnValueUseCount > 0)
        fReturnValue: fReturnValueCode,
      if (typeAliasTable.fReturnFutureUseCount > 0)
        fReturnFuture: fReturnFutureCode,
      if (typeAliasTable.fReturnFutureOrUseCount > 0)
        fReturnFutureOr: fReturnFutureOrCode,
    };
  }

  Future<Map<String, String>> _classProxy(
    InputAnalyzerResolved inputAnalyzer,
    AnnotatedElement annotated,
    _TypeAliasTable typeAliasTable,
  ) async {
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

    var ignoreMethods1 = annotation.peek('ignoreMethods')!.setValue;
    var ignoreMethods2 = annotation.peek('ignoreMethods2')!.setValue;
    var ignoreMethods = {...ignoreMethods1, ...ignoreMethods2};

    if (reflectionProxyName.isEmpty) {
      reflectionProxyName =
          annotatedClass.name ??
          (throw StateError(
            "Can't determine `reflectionProxyName`: $annotatedClass",
          ));
    }

    log.info(
      ' <ClassProxy>\n'
      '  -- Target Class Name: $className\n'
      '  -- Always Return Future: $alwaysReturnFuture\n'
      '  -- reflectionProxyName: $reflectionProxyName\n'
      '  -- traverseReturnTypes: $traverseReturnTypes\n'
      '  -- ignoreParametersTypes: $ignoreParametersTypes\n\n',
    );

    var codeTable = <String, String>{};

    var candidateClasses = await inputAnalyzer.findCandidateClassElements(
      className,
      libraryName,
      libraryPath,
    );

    if (candidateClasses.isEmpty) {
      throw StateError(
        "** Can't find a class with name `$className` to generate a `ClassProxy`! libraryName: `$libraryName` ; libraryPath: `$libraryPath`.",
      );
    } else if (candidateClasses.length > 1) {
      throw StateError(
        "** Found many candidate classes with name `$className`: $candidateClasses",
      );
    }

    var classElement = candidateClasses.first;

    var (classLibrary, classLibraryAssetId) = await inputAnalyzer
        .getElementLibrary(classElement);

    var classAssetCanRead = await inputAnalyzer.buildStep.canRead(
      classLibraryAssetId,
    );
    if (classAssetCanRead) {
      // Force library dependency
      await inputAnalyzer.buildStep.readAsBytes(classLibraryAssetId);
    }

    var languageVersion = classLibrary.languageVersion.effective;
    typeAliasTable.addLanguageVersion(languageVersion);

    var classTree = _ClassTree(
      typeAliasTable,
      classElement,
      '?%',
      '?%',
      reflectionProxyName,
      false,
      languageVersion,
      verbose: verbose,
    );

    if (verbose) {
      log.info(' >> $classTree');
    }

    codeTable.putIfAbsent(
      classTree.reflectionProxyExtension,
      () => classTree.buildReflectionProxyClass(
        annotatedClass,
        alwaysReturnFuture,
        traverseReturnTypes,
        ignoreParametersTypes,
        ignoreMethods,
        typeAliasTable,
      ),
    );

    return codeTable;
  }

  Future<Map<String, String>> _reflectionBridge(
    InputAnalyzerResolved inputAnalyzer,
    AnnotatedElement annotated,
    _TypeAliasTable typeAliasTable,
  ) async {
    var annotation = annotated.annotation;
    var annotatedClass = annotated.element as ClassElement;

    var classesTypes =
        annotation
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
    var optimizeReflectionInstances =
        annotated.annotation.peek('optimizeReflectionInstances')!.boolValue;

    log.info(
      ' <ReflectionBridge>\n'
      '  -- classesTypes: $classesTypes\n'
      '  -- bridgeExtensionName: $bridgeExtensionName\n'
      '  -- reflectionClassNames: $reflectionClassNames\n'
      '  -- reflectionExtensionNames: $reflectionExtensionNames\n'
      '  -- optimizeReflectionInstances: $optimizeReflectionInstances\n\n',
    );

    var codeTable = <String, String>{};

    for (var classType in classesTypes) {
      var classElement = classType.elementDeclaration;
      if (classElement == null || classElement is! ClassElement) {
        continue;
      }

      var (classLibrary, classLibraryAssetId) = await inputAnalyzer
          .getElementLibrary(classElement);

      var reflectionClassName = reflectionClassNames[classType] ?? '';
      var reflectionExtensionName = reflectionExtensionNames[classType] ?? '';

      var languageVersion = classLibrary.languageVersion.effective;
      typeAliasTable.addLanguageVersion(languageVersion);

      var classTree = _ClassTree(
        typeAliasTable,
        classElement,
        reflectionClassName,
        reflectionExtensionName,
        '?%',
        optimizeReflectionInstances,
        languageVersion,
        verbose: verbose,
      );

      if (verbose) {
        log.info(' >> $classTree');
      }

      codeTable.putIfAbsent(
        classTree.classGlobalFunction('_'),
        () => classTree.buildClassGlobalFunctions(),
      );
      codeTable.putIfAbsent(
        classTree.reflectionClass,
        () => classTree.buildReflectionClass(typeAliasTable),
      );
      codeTable.putIfAbsent(
        classTree.reflectionExtension,
        () => classTree.buildReflectionExtension(),
      );
    }

    codeTable.addAll(
      _reflectionBridgeExtension(
        annotatedClass,
        classesTypes,
        bridgeExtensionName,
        reflectionClassNames,
      ),
    );

    return codeTable;
  }

  Map<String, String> _reflectionBridgeExtension(
    ClassElement annotatedClass,
    List<DartType> classesTypes,
    String reflectionBridgeExtensionName,
    Map<DartType, String> reflectionClassNames,
  ) {
    var bridgeClassName =
        annotatedClass.name ??
        (throw StateError("Can't define `bridgeClassName`: $annotatedClass"));

    var bridgeExtensionName = _buildReflectionExtensionName(
      bridgeClassName,
      reflectionBridgeExtensionName,
    );

    var str = StringBuffer();

    str.write('extension $bridgeExtensionName on $bridgeClassName {\n');

    str.write(
      '  /// Returns a [ClassReflection] for type [T] or [obj]. (Generated by [ReflectionFactory])\n',
    );
    str.write('  ClassReflection<T> reflection<T>([T? obj]) {\n');

    str.write('    switch (T) {\n');

    for (var classType in classesTypes) {
      var bridgeReflectionClassName = reflectionClassNames[classType] ?? '';
      var className = classType.elementDeclaration!.name!;

      var reflectionClassName = _buildReflectionClassName(
        className,
        bridgeReflectionClassName,
      );
      str.write(
        '      case const ($className): return $reflectionClassName(obj as $className?) as ClassReflection<T>;\n',
      );
    }

    str.write(
      "      default: throw UnsupportedError('<\$runtimeType> No reflection for Type: \$T');\n",
    );
    str.write('    }\n');

    str.write('  }\n\n');

    str.write('}\n\n');

    var code = str.toString();

    return {bridgeExtensionName: code};
  }

  Future<Map<String, String>> _enableReflectionEnum(
    InputAnalyzerResolved inputAnalyzer,
    Element enumElement,
    String reflectionClassName,
    String reflectionExtensionName,
    bool optimizeReflectionInstances,
    _TypeAliasTable typeAliasTable,
  ) async {
    var (enumLibrary, enumLibraryAssetId) = await inputAnalyzer
        .getElementLibrary(enumElement);

    var languageVersion = enumLibrary.languageVersion.effective;
    typeAliasTable.addLanguageVersion(languageVersion);

    var enumTree = _EnumTree(
      enumElement,
      reflectionClassName,
      reflectionExtensionName,
      optimizeReflectionInstances,
      languageVersion,
      verbose: verbose,
    );

    if (verbose) {
      log.info(' >> $enumTree');
    }

    var enumGlobalFunctions = enumTree.buildEnumGlobalFunctions();
    var reflectionClassCode = enumTree.buildReflectionEnum(typeAliasTable);
    var reflectionExtensionCode = enumTree.buildReflectionExtension();

    return {
      enumTree.classGlobalFunction('_'): enumGlobalFunctions,
      enumTree.reflectionClass: reflectionClassCode,
      enumTree.reflectionExtension: reflectionExtensionCode,
    };
  }

  Future<
    ({
      Map<String, String> codes,
      Set<DartType> fieldsTypesWithReflection,
      Set<DartType> staticFieldsTypesWithReflection,
    })
  >
  _enableReflectionClass(
    InputAnalyzerResolved inputAnalyzer,
    ClassElement classElement,
    String reflectionClassName,
    String reflectionExtensionName,
    bool optimizeReflectionInstances,
    _TypeAliasTable typeAliasTable,
  ) async {
    var (classLibrary, classLibraryAssetId) = await inputAnalyzer
        .getElementLibrary(classElement);

    var languageVersion = classLibrary.languageVersion.effective;
    typeAliasTable.addLanguageVersion(languageVersion);

    var classTree = _ClassTree(
      typeAliasTable,
      classElement,
      reflectionClassName,
      reflectionExtensionName,
      '?%',
      optimizeReflectionInstances,
      languageVersion,
      verbose: verbose,
    );

    if (verbose) {
      log.info(' >> $classTree');
    }

    var classGlobalFunctions = classTree.buildClassGlobalFunctions();
    var reflectionClassCode = classTree.buildReflectionClass(typeAliasTable);
    var reflectionExtensionCode = classTree.buildReflectionExtension();

    return (
      codes: {
        classTree.classGlobalFunction('_'): classGlobalFunctions,
        classTree.reflectionClass: reflectionClassCode,
        classTree.reflectionExtension: reflectionExtensionCode,
      },
      fieldsTypesWithReflection: classTree.fieldsTypesWithEnableReflection,
      staticFieldsTypesWithReflection:
          classTree.staticFieldsTypesWithEnableReflection,
    );
  }

  void _buildReflectionMixin(_CodeTable codeTable) {
    if (codeTable.reflectionClassesIsEmpty) return;

    var str = StringBuffer();

    str.write('mixin ${codeTable.typeAliasTable.reflectionMixinName} {\n');

    str.write(
      "  static final Version _version = Version.parse('${ReflectionFactory.VERSION}');\n\n",
    );

    str.write("  Version get reflectionFactoryVersion => _version;\n\n");

    str.write(
      '  List<Reflection> siblingsReflection() => _siblingsReflection();\n\n',
    );

    str.write('}\n\n');

    codeTable.codeReflectionMixin = str.toString();
  }

  void _buildSiblingsClassReflection(_CodeTable codeTable) {
    if (codeTable.reflectionClassesIsEmpty) return;

    var str = StringBuffer();

    str.write('List<Reflection> _listSiblingsReflection() => ');
    str.write('<Reflection>[');

    var classesReflections =
        codeTable.reflectionClassesKeys
            .where((e) => e.endsWith(r'$reflection'))
            .toList();

    classesReflections.sort();

    for (var c in classesReflections) {
      str.write(c);
      str.write('(),\n');
    }

    if (codeTable.fieldsTypesWithReflection.isNotEmpty ||
        codeTable.staticFieldsTypesWithReflection.isNotEmpty) {
      var allFieldsTypesWithReflection = CombinedIterableView([
        codeTable.fieldsTypesWithReflection,
        codeTable.staticFieldsTypesWithReflection,
      ]);

      var extraReflections =
          allFieldsTypesWithReflection
              .map((t) => '${t.typeName}\$reflection')
              .toSet()
              .where((c) => !classesReflections.contains(c))
              .toList();

      if (extraReflections.isNotEmpty) {
        extraReflections.sort();

        str.write("      // Dependency reflections:\n");

        for (var c in extraReflections) {
          str.write(c);
          str.write('(),\n');
        }
      }
    }

    str.write('];\n\n');

    str.write('List<Reflection>? _siblingsReflectionList;\n');
    str.write('List<Reflection> _siblingsReflection() => ');
    str.write(
      '_siblingsReflectionList ??= List<Reflection>.unmodifiable( _listSiblingsReflection() );\n\n',
    );

    str.write('bool _registerSiblingsReflectionCalled = false;\n');
    str.write('void _registerSiblingsReflection() {\n');
    str.write('  if (_registerSiblingsReflectionCalled) return ;\n');
    str.write('  _registerSiblingsReflectionCalled = true ;\n');
    str.write('  var length = _listSiblingsReflection().length;\n');
    str.write('  assert(length > 0);\n');
    str.write('}\n\n');

    codeTable.codeSiblingsClassReflection = str.toString();
  }

  void _buildSymbolsTable(_CodeTable codeTable) {
    var str = StringBuffer();

    var namedParameters = codeTable.typeAliasTable.namedParameters;
    namedParameters.sort();

    str.write('Symbol? _getSymbol(String? key) ');

    if (namedParameters.isEmpty) {
      str.write(' => null;\n');
    } else {
      str.write('{\n');

      str.write(' if (key == null) return null;\n\n');

      str.write(' switch(key) {\n');

      for (var n in namedParameters) {
        assert(!n.contains("'"));
        assert(!n.contains('"'));
        assert(!n.contains(r'\'));

        var nQ = 'r"$n"';
        str.write('   case $nQ: return const Symbol($nQ);\n');
      }

      str.write('   default: return null;\n');
      str.write(' }\n');

      str.write('}\n');
    }

    codeTable.codeSymbolsTable = str.toString();
  }
}

class _TypeAliasTable {
  late final String trName;
  late final String tiName;
  late final String prName;
  late final String reflectionMixinName;
  late final String fReturnValue;
  late final String fReturnFuture;
  late final String fReturnFutureOr;
  late final StringBuffer code;

  int fReturnValueUseCount = 0;

  int fReturnFutureUseCount = 0;

  int fReturnFutureOrUseCount = 0;

  factory _TypeAliasTable.fromLibraryReader(LibraryReader libraryReader) {
    var privateNames =
        libraryReader.elementsNames.where((e) => e.startsWith('_')).toList();
    return _TypeAliasTable(privateNames);
  }

  final List<String> privateNames;

  _TypeAliasTable(this.privateNames) {
    trName = _buildAliasName('__TR', privateNames);
    tiName = _buildAliasName('__TI', privateNames);
    prName = _buildAliasName('__PR', privateNames);

    reflectionMixinName = _buildAliasName('__ReflectionMixin', privateNames);
    fReturnValue = _buildAliasName('__retVal\$', privateNames);
    fReturnFuture = _buildAliasName('__retFut\$', privateNames);
    fReturnFutureOr = _buildAliasName('__retFutOr\$', privateNames);

    code = StringBuffer();

    code.write('typedef $trName<T> = TypeReflection<T>;\n');
    code.write('typedef $tiName<T> = TypeInfo<T>;\n');
    code.write('typedef $prName = ParameterReflection;\n\n');
  }

  final Map<String, String> _recordsAliases = {};

  String aliasForRecordType(String recordDeclaration) {
    var alias = _recordsAliases[recordDeclaration];
    if (alias != null) return alias;

    var nextID = _recordsAliases.length + 1;
    alias = _buildAliasName('__RCD$nextID', privateNames);

    _recordsAliases[recordDeclaration] = alias;

    code.write('typedef $alias = $recordDeclaration;\n');

    return alias;
  }

  String _buildAliasName(String prefix, Iterable<String> usedNames) {
    if (!usedNames.contains(prefix)) return prefix;

    var i = 0;
    while (true) {
      var name = '$prefix$i';
      if (!usedNames.contains(name)) return name;
    }
  }

  final Set<String> _namedParameters = {};

  List<String> get namedParameters => _namedParameters.toList();

  void addNamedParameter(String namedParameter) =>
      _namedParameters.add(namedParameter);

  void addAllNamedParameters(Iterable<String> namedParameters) {
    for (var n in namedParameters) {
      addNamedParameter(n);
    }
  }

  final Set<Version> _languageVersions = {};

  void addLanguageVersion(Version languageVersion) =>
      _languageVersions.add(languageVersion);

  Version? resolveLanguageVersion() {
    var versions = _languageVersions.toList();
    if (versions.isEmpty) return null;
    versions.sort();
    return versions.last;
  }
}

class _CodeTable {
  final _TypeAliasTable typeAliasTable;

  String codeReflectionMixin = '';
  String codeSiblingsClassReflection = '';
  String codeSymbolsTable = '';

  _CodeTable(this.typeAliasTable);

  final Set<DartType> fieldsTypesWithReflection = <DartType>{};
  final Set<DartType> staticFieldsTypesWithReflection = <DartType>{};

  final Map<String, String> _reflectionClasses = <String, String>{};
  final Map<String, String> _reflectionProxies = <String, String>{};
  final Map<String, String> _functions = <String, String>{};

  bool get reflectionClassesIsEmpty => _reflectionClasses.isEmpty;

  bool get reflectionProxiesIsEmpty => _reflectionProxies.isEmpty;

  bool get functionsIsEmpty => _functions.isEmpty;

  bool get isEmpty =>
      _reflectionClasses.isEmpty &&
      _reflectionProxies.isEmpty &&
      _functions.isEmpty;

  Iterable<String> get reflectionClassesKeys => _reflectionClasses.keys;

  Iterable<String> get reflectionProxiesKeys => _reflectionProxies.keys;

  Iterable<String> get functionsKeys => _functions.keys;

  Iterable<String> get allKeys => <String>[
    ..._reflectionClasses.keys,
    ..._reflectionProxies.keys,
    ..._functions.keys,
  ];

  void _checkKey(String key) {
    var code = get(key);
    if (code != null) {
      throw StateError("Key `$key` already exists in the code table!");
    }
  }

  String? get(String key) =>
      _reflectionClasses[key] ?? _reflectionProxies[key] ?? _functions[key];

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

  void addFunction(String key, String code) {
    _checkKey(key);
    _functions[key] = code;
  }

  void addFunctions(Map<String, String> codes) {
    for (var e in codes.entries) {
      addFunction(e.key, e.value);
    }
  }

  Version? resolveLanguageVersion() => typeAliasTable.resolveLanguageVersion();
}

String _buildClassGlobalFunction(
  String className,
  String reflectionClassName,
  String functionName, {
  String delimiter = '\$',
}) {
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
  String className,
  String reflectionExtensionName,
) {
  reflectionExtensionName = reflectionExtensionName.trim();
  if (reflectionExtensionName.isNotEmpty) {
    return reflectionExtensionName;
  }

  return '$className\$reflectionExtension';
}

class _EnumTree<T> extends RecursiveElementVisitor2<T> {
  final Element _enumElement;

  final String reflectionClassName;
  final String reflectionExtensionName;

  final bool optimizeReflectionInstances;

  final Version languageVersion;

  final bool verbose;

  final String enumName;

  _EnumTree(
    this._enumElement,
    this.reflectionClassName,
    this.reflectionExtensionName,
    this.optimizeReflectionInstances,
    this.languageVersion, {
    this.verbose = false,
  }) : enumName = _enumElement.name! {
    _enumElement.visitChildren(this);
  }

  DartType? get thisType {
    var e = _enumElement;
    if (e is InterfaceElement) {
      return e.thisType;
    }
    return null;
  }

  String classGlobalFunction(String functionName) =>
      _buildClassGlobalFunction(enumName, reflectionClassName, functionName);

  String get reflectionClass =>
      _buildReflectionClassName(enumName, reflectionClassName);

  String get reflectionExtension =>
      _buildReflectionExtensionName(enumName, reflectionExtensionName);

  final Set<FieldElement> staticFields = <FieldElement>{};

  final Set<FieldElement> fields = <FieldElement>{};

  @override
  T? visitFieldElement(FieldElement element) {
    var name = element.name;

    if (name == 'index' || name == 'values') {
      return null;
    }

    if (element.isStatic) {
      _addWithUniqueName(staticFields, element);
    } else {
      _addWithUniqueName(fields, element);
    }

    return null;
  }

  List<String> get staticFieldsNames =>
      staticFields.map((e) => e.name).nonNulls.toList();

  List<String> get fieldsNames => fields.map((e) => e.name).nonNulls.toList();

  bool hasStaticField(String filedName) =>
      staticFields.where((m) => m.name == filedName).isNotEmpty;

  bool hasField(String filedName) =>
      fields.where((m) => m.name == filedName).isNotEmpty;

  @override
  String toString() {
    return '_EnumTree{ '
        'enumName: $enumName, '
        'languageVersion: $languageVersion, '
        'staticFieldsNames: $staticFieldsNames '
        'fields: $fieldsNames '
        '}';
  }

  String buildEnumGlobalFunctions() {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    var from = classGlobalFunction('from');

    str.write('// ignore: non_constant_identifier_names\n');
    str.write(
      '$enumName? $from(Object? o) => $reflectionClass.staticInstance.from(o);\n',
    );

    return str.toString();
  }

  String buildReflectionEnum(_TypeAliasTable typeAliasTable) {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    str.write(
      'class $reflectionClass extends EnumReflection<$enumName> with ${typeAliasTable.reflectionMixinName} {\n\n',
    );

    if (optimizeReflectionInstances) {
      str.write(
        '  static final Expando<$reflectionClass> _objectReflections = Expando();\n\n',
      );

      str.write('  factory $reflectionClass([$enumName? object]) {\n');
      str.write('  if (object == null) return staticInstance;\n');
      str.write(
        '  return _objectReflections[object] ??= $reflectionClass._(object);\n',
      );
      str.write('}\n\n');
    } else {
      str.write(
        '  $reflectionClass([$enumName? object]) : this._(object);\n\n',
      );
    }

    str.write(
      '  $reflectionClass._([$enumName? object]) : super($enumName, r\'$enumName\', object);\n\n',
    );

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
      "  Version get languageVersion => Version.parse('$languageVersion');\n\n",
    );

    str.write('  @override\n');
    str.write(
      '  $reflectionClass withObject([$enumName? obj]) => $reflectionClass(obj);\n\n',
    );

    str.write('  static $reflectionClass? _withoutObjectInstance;\n');
    str.write('  @override\n');
    str.write(
      '  $reflectionClass withoutObjectInstance() => staticInstance;\n\n',
    );

    str.write('\n');
    str.write('@override\n');
    str.write('Symbol? getSymbol(String? key) => _getSymbol(key);\n');
    str.write('\n\n');

    str.write(
      '  static $reflectionClass get staticInstance => _withoutObjectInstance ??= $reflectionClass._();\n\n',
    );

    str.write('  @override\n');
    str.write(
      '   $reflectionClass getStaticInstance() => staticInstance ;\n\n',
    );

    str.write(
      '  static bool _boot = false;'
      '  static void boot() {\n'
      '    if (_boot) return;\n'
      '    _boot = true;\n'
      '    $reflectionClass.staticInstance ;\n'
      '}',
    );

    var classElement = _Element(_enumElement);

    var classAnnotationListCode = classElement.annotationsAsListCode;
    if (classAnnotationListCode == 'null') {
      classAnnotationListCode = '<Object>[]';
    }

    str.write(
      '  static const List<Object> _classAnnotations = $classAnnotationListCode; \n\n',
    );

    str.write('  @override\n');
    str.write('  List<Object> get classAnnotations => _classAnnotations;\n\n');

    _buildStaticFields(str);
    _buildFields(str);

    str.write('}\n\n');

    return str.toString();
  }

  void _buildStaticFields(StringBuffer str) {
    var entries = _toFieldEntries(staticFields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _staticFieldsNames = $names;\n\n');

    str.write('  @override\n');
    str.write(
      '  List<String> get staticFieldsNames => _staticFieldsNames;\n\n',
    );

    str.write(
      '  static const Map<String,$enumName> _valuesByName = const <String,$enumName>{\n',
    );

    final enumType = thisType;

    var enumsEntries =
        entries.entries
            .where((e) => e.value.thisType == enumType)
            .sortedBy((e) => e.key)
            .toList();

    for (var e in enumsEntries) {
      var name = e.key;
      str.write("  '$name': $enumName.$name,\n");
    }

    str.write('  };\n\n');

    str.write('  @override\n');
    str.write('  Map<String,$enumName> get valuesByName => _valuesByName;\n');

    str.write('  @override\n');
    str.write('  List<$enumName> get values => $enumName.values;\n\n');
  }

  void _buildFields(StringBuffer str) {
    var entries = _toFieldEntries(fields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _fieldsNames = $names;\n\n');

    str.write('  @override\n');
    str.write('  List<String> get fieldsNames => _fieldsNames;\n\n');
  }

  Map<String, _Field> _toFieldEntries(Set<FieldElement> fields) {
    return Map.fromEntries(fields.map((e) => MapEntry(e.name!, _Field(e))));
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
        '  /// Returns a [EnumReflection] for type [$enumName]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  EnumReflection<$enumName> get reflection => $reflectionClass(this);\n',
      );
      entriesCount++;
    }

    if (!hasField('enumName')) {
      str.write(
        '  /// Returns the name of the [$enumName] instance. (Generated by [ReflectionFactory])\n',
      );
      str.write('  String get enumName => $reflectionClass(this).name()!;\n');
      entriesCount++;
    }

    if (!hasField('toJson')) {
      str.write(
        '\n  /// Returns a JSON for type [$enumName]. (Generated by [ReflectionFactory])\n',
      );
      str.write('  String? toJson() => reflection.toJson();\n');
      entriesCount++;
    }

    if (!hasField('toJsonMap')) {
      str.write(
        '\n  /// Returns a JSON [Map] for type [$enumName]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  Map<String,Object>? toJsonMap() => reflection.toJsonMap();\n',
      );
      entriesCount++;
    }

    if (!hasField('toJsonEncoded')) {
      str.write(
        '\n  /// Returns an encoded JSON [String] for type [$enumName]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  String toJsonEncoded({bool pretty = false}) => reflection.toJsonEncoded(pretty: pretty);\n',
      );
      entriesCount++;
    }

    str.write('}\n\n');

    if (entriesCount > 0) {
      codeBuffer.write(str);
    }
  }
}

class _ClassTree<T> extends RecursiveElementVisitor2<T> {
  final _TypeAliasTable typeAliasTable;

  final ClassElement _classElement;

  final String reflectionClassName;
  final String reflectionExtensionName;
  final String reflectionProxyName;

  final bool optimizeReflectionInstances;

  final Version languageVersion;

  final bool verbose;

  final String className;

  _ClassTree(
    this.typeAliasTable,
    this._classElement,
    this.reflectionClassName,
    this.reflectionExtensionName,
    this.reflectionProxyName,
    this.optimizeReflectionInstances,
    this.languageVersion, {
    this.verbose = false,
  }) : className = _classElement.name! {
    scan(_classElement);
  }

  final Set<InterfaceElement> supperTypes = <InterfaceElement>{};

  final Queue<InterfaceElement> _visitingTypeStack = Queue<InterfaceElement>();

  InterfaceElement? get _visitingType => _visitingTypeStack.last;

  bool get _isVisitingSupperType => _visitingType != _classElement;

  void scan(InterfaceElement interfaceElement) {
    try {
      _visitingTypeStack.addLast(interfaceElement);

      if (interfaceElement != _classElement) {
        supperTypes.add(interfaceElement);
      }

      interfaceElement.visitChildren(this);

      for (var t in interfaceElement.allSupertypes) {
        var superClass = t.element;

        if (superClass is ClassElement && superClass.isDartCoreObject) {
          continue;
        }

        scan(superClass);
      }
    } finally {
      var c = _visitingTypeStack.removeLast();
      if (c != interfaceElement) {
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
    var noArgsConstructors =
        constructors
            .where((e) => e.codeName.isNotEmpty && e.formalParameters.isEmpty)
            .toList();

    if (noArgsConstructors.isEmpty) {
      return null;
    } else if (noArgsConstructors.length == 1) {
      return noArgsConstructors[0];
    } else {
      var found = noArgsConstructors.firstWhereOrNull((e) {
        var name = e.codeName.toLowerCase();
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
    var noArgsConstructors =
        constructors
            .where(
              (e) =>
                  e.codeName.isNotEmpty &&
                  e.normalParameters.isEmpty &&
                  e.optionalParameters.where((p) => p.required).isEmpty &&
                  e.namedParameters.values.where((p) => p.required).isEmpty,
            )
            .toList();

    if (noArgsConstructors.isEmpty) {
      return null;
    } else if (noArgsConstructors.length == 1) {
      return noArgsConstructors[0];
    } else {
      var found = noArgsConstructors.firstWhereOrNull((e) {
        var name = e.codeName.toLowerCase();
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
    if (element.isPrivate || !isValidMethodName(element.codeName)) {
      return super.visitConstructorElement(element);
    }

    if (!_isVisitingSupperType) {
      _addWithUniqueName(constructors, element);
    }

    return null;
  }

  final Set<MethodElement> staticMethods = <MethodElement>{};

  List<String> get staticMethodsNames =>
      staticMethods.map((e) => e.name).nonNulls.toList();

  final Set<MethodElement> methods = <MethodElement>{};

  List<String> get methodsNames => methods.map((e) => e.name).nonNulls.toList();

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
    if (element.isPrivate || !isValidMethodName(element.name ?? '')) {
      return super.visitMethodElement(element);
    }

    if (element.isStatic) {
      if (!_isVisitingSupperType) {
        _addWithUniqueName(staticMethods, element);
      }
    } else {
      _addWithUniqueName(methods, element);
    }

    return super.visitMethodElement(element);
  }

  final Set<FieldElement> staticFields = <FieldElement>{};

  List<String> get staticFieldsNames =>
      staticFields.map((e) => e.name).nonNulls.toList();

  final Set<FieldElement> fields = <FieldElement>{};

  List<String> get fieldsNames => fields.map((e) => e.name).nonNulls.toList();

  bool hasField(String filedName) =>
      fields.where((m) => m.name == filedName).isNotEmpty;

  bool hasStaticField(String filedName) =>
      staticFields.where((m) => m.name == filedName).isNotEmpty;

  bool hasEntry(String name) =>
      hasMethod(name) ||
      hasStaticMethod(name) ||
      hasField(name) ||
      hasStaticField(name);

  final Set<DartType> fieldsTypesWithEnableReflection = <DartType>{};

  final Set<DartType> staticFieldsTypesWithEnableReflection = <DartType>{};

  @override
  T? visitFieldElement(FieldElement element) {
    if (element.isPrivate) {
      return super.visitFieldElement(element);
    }

    if (element.isStatic) {
      if (!_isVisitingSupperType) {
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
      '$className $fromJsonName(Map<String,Object?> map) => $reflectionClass.staticInstance.fromJson(map);\n',
    );

    var fromJsonEncodedName = classGlobalFunction('fromJsonEncoded');

    str.write('// ignore: non_constant_identifier_names\n');
    str.write(
      '$className $fromJsonEncodedName(String jsonEncoded) => $reflectionClass.staticInstance.fromJsonEncoded(jsonEncoded);\n',
    );

    return str.toString();
  }

  String buildReflectionClass(_TypeAliasTable typeAliasTable) {
    var str = StringBuffer();

    var reflectionClass = this.reflectionClass;

    str.write(
      'class $reflectionClass extends ClassReflection<$className> with ${typeAliasTable.reflectionMixinName} {\n\n',
    );

    if (optimizeReflectionInstances) {
      str.write(
        '  static final Expando<$reflectionClass> _objectReflections = Expando();\n\n',
      );

      str.write('  factory $reflectionClass([$className? object]) {\n');
      str.write('  if (object == null) return staticInstance;\n');
      str.write(
        '  return _objectReflections[object] ??= $reflectionClass._(object);\n',
      );
      str.write('}\n\n');
    } else {
      str.write(
        '  $reflectionClass([$className? object]) : this._(object);\n\n',
      );
    }

    str.write(
      '  $reflectionClass._([$className? object]) : super($className, r\'$className\', object);\n\n',
    );

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
      "  Version get languageVersion => Version.parse('$languageVersion');\n\n",
    );

    str.write('  @override\n');
    str.write(
      '  $reflectionClass withObject([$className? obj]) => $reflectionClass(obj)..setupInternalsWith(this);\n\n',
    );

    str.write('  static $reflectionClass? _withoutObjectInstance;\n');
    str.write('  @override\n');
    str.write(
      '  $reflectionClass withoutObjectInstance() => staticInstance;\n\n',
    );

    str.write('\n');
    str.write('@override\n');
    str.write('Symbol? getSymbol(String? key) => _getSymbol(key);\n');
    str.write('\n\n');

    str.write(
      '  static $reflectionClass get staticInstance => _withoutObjectInstance ??= $reflectionClass._();\n\n',
    );

    str.write('  @override\n');
    str.write(
      '   $reflectionClass getStaticInstance() => staticInstance ;\n\n',
    );

    str.write(
      '  static bool _boot = false;'
      '  static void boot() {\n'
      '    if (_boot) return;\n'
      '    _boot = true;\n'
      '    $reflectionClass.staticInstance ;\n'
      '}',
    );

    _buildConstructors(str);

    var classElement = _Element(_classElement);

    var classAnnotationListCode = classElement.annotationsAsListCode;
    if (classAnnotationListCode == 'null') {
      classAnnotationListCode = '<Object>[]';
    }

    str.write(
      '  static const List<Object> _classAnnotations = $classAnnotationListCode; \n\n',
    );

    str.write('  @override\n');
    str.write('  List<Object> get classAnnotations => _classAnnotations;\n\n');

    str.write(
      '  static const List<Type> _supperTypes = const <Type>[${supperTypes.map((e) => e.name).join(', ')}];\n\n',
    );

    str.write('\n  @override\n');
    str.write('  List<Type> get supperTypes => _supperTypes;\n\n');

    _buildCallMethodToJson(str);

    _buildFields(str);
    _buildStaticFields(str);

    _buildMethods(str);
    _buildStaticMethods(str);

    str.write('}\n\n');

    return str.toString();
  }

  void _buildConstructors(StringBuffer str) {
    _buildDefaultConstructor(str);

    var entries = _toConstructorEntries(
      this,
      constructors.where(_canConstruct).toSet(),
    );
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _constructorsNames = $names;\n\n');

    str.write('  @override\n');
    str.write(
      '  List<String> get constructorsNames => _constructorsNames;\n\n',
    );

    str.write(
      '  static final Map<String,ConstructorReflection<$className>> _constructors = {};\n\n',
    );

    str.write('  @override\n');
    str.write(
      '  ConstructorReflection<$className>? constructor(String constructorName) {\n',
    );

    //str.write('    return _constructorImpl(constructorName);\n');

    str.write('    var c = _constructors[constructorName];\n');
    str.write('    if (c != null) return c;\n');
    str.write('    c = _constructorImpl(constructorName);\n');
    str.write('    if (c == null) return null;\n');
    str.write('    _constructors[constructorName] = c;\n');
    str.write('    return c ;\n');

    str.write('  }\n\n');

    str.write(
      '  ConstructorReflection<$className>? _constructorImpl(String constructorName) {\n',
    );

    _buildSwitches(str, 'constructorName', entries.keys, (name) {
      var constructor = entries[name]!;
      if (verbose) {
        log.info('[CONSTRUCTOR] $constructor');
      }

      typeAliasTable.addAllNamedParameters(constructor.namedParameters.keys);

      var declaringType = constructor.declaringType!.typeNameResolvable;
      var fullName = constructor.fullName;

      return "ConstructorReflection<$className>("
          "this, $declaringType, '$name', () => $fullName , "
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
        '  $className? createInstanceWithDefaultConstructor() => $className();\n',
      );
    } else {
      str.write('  @override\n');
      str.write('  bool get hasDefaultConstructor => false;\n');

      str.write('  @override\n');
      str.write(
        '  $className? createInstanceWithDefaultConstructor() => null;\n',
      );
    }
    str.write('\n');

    var emptyConstructor = this.emptyConstructor;

    if (_canConstruct(emptyConstructor)) {
      str.write('  @override\n');
      str.write('  bool get hasEmptyConstructor => true;\n');

      str.write('  @override\n');
      var name = emptyConstructor!.name;
      str.write(
        '  $className? createInstanceWithEmptyConstructor() => $className.$name();\n',
      );
    } else {
      str.write('  @override\n');
      str.write('  bool get hasEmptyConstructor => false;\n');

      str.write('  @override\n');
      str.write(
        '  $className? createInstanceWithEmptyConstructor() => null;\n',
      );
    }

    var noRequiredArgsConstructor = this.noRequiredArgsConstructor;

    if (_canConstruct(noRequiredArgsConstructor)) {
      str.write('  @override\n');
      str.write('  bool get hasNoRequiredArgsConstructor => true;\n');

      str.write('  @override\n');
      var name = noRequiredArgsConstructor!.name;
      str.write(
        '  $className? createInstanceWithNoRequiredArgsConstructor() => $className.$name();\n',
      );
    } else {
      str.write('  @override\n');
      str.write('  bool get hasNoRequiredArgsConstructor => false;\n');

      str.write('  @override\n');
      str.write(
        '  $className? createInstanceWithNoRequiredArgsConstructor() => null;\n',
      );
    }

    str.write('\n');
  }

  void _buildFields(StringBuffer str) {
    var entries = _toFieldEntries(fields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _fieldsNames = $names;\n\n');

    str.write('  @override\n');
    str.write('  List<String> get fieldsNames => _fieldsNames;\n\n');

    // No fields in class:
    if (entries.isEmpty) {
      str.write('  @override\n');
      str.write(
        '  FieldReflection<$className,T>? field<T>(String fieldName, [$className? obj]) => null;\n\n',
      );

      str.write('  @override\n');
      str.write(
        '  Map<String,dynamic> getFieldsValues($className? obj, {bool withHashCode = false}) => {\n'
        "  if (withHashCode) 'hashCode': obj?.hashCode,"
        '};\n\n',
      );

      return;
    }

    str.write(
      '  static final Map<String,FieldReflection<$className,dynamic>> _fieldsNoObject = {};\n\n',
    );

    str.write(
      '  final Map<String,FieldReflection<$className,dynamic>> _fieldsObject = {};\n\n',
    );

    str.write('  @override\n');
    str.write(
      '  FieldReflection<$className,T>? field<T>(String fieldName, [$className? obj]) {\n',
    );

    //str.write('    return _fieldImpl<T>(fieldName, obj);\n');

    str.write('    if (obj == null) {\n');
    str.write('      if (object != null) {\n');
    str.write('        return _fieldObjectImpl<T>(fieldName);\n');
    str.write('      } else {\n');
    str.write('        return _fieldNoObjectImpl<T>(fieldName);\n');
    str.write('      }\n');
    str.write('    } else if (identical(obj, object)) {\n');
    str.write('        return _fieldObjectImpl<T>(fieldName);\n');
    str.write('    }\n');
    str.write(
      '    return _fieldNoObjectImpl<T>(fieldName)?.withObject(obj);\n',
    );

    str.write('  }\n\n');

    str.write(
      '  FieldReflection<$className,T>? _fieldNoObjectImpl<T>(String fieldName) {\n',
    );
    str.write('      final f = _fieldsNoObject[fieldName];\n');
    str.write(
      '      if (f != null) {return f as FieldReflection<$className, T>;}\n',
    );
    str.write('      final f2 = _fieldImpl(fieldName, null);\n');
    str.write('      if (f2 == null) return null;\n');
    str.write('      _fieldsNoObject[fieldName] = f2;\n');
    str.write('      return f2 as FieldReflection<$className, T>;\n');
    str.write('  }\n\n');

    str.write(
      '  FieldReflection<$className,T>? _fieldObjectImpl<T>(String fieldName) {\n',
    );
    str.write('      final f = _fieldsObject[fieldName];\n');
    str.write(
      '      if (f != null) {return f as FieldReflection<$className, T>;}\n',
    );
    str.write('      var f2 = _fieldNoObjectImpl<T>(fieldName);\n');
    str.write('      if (f2 == null) return null;\n');
    str.write('      f2 = f2.withObject(object!);\n');
    str.write('      _fieldsObject[fieldName] = f2;\n');
    str.write('      return f2 ;\n');
    str.write('  }\n\n');

    str.write(
      '  FieldReflection<$className,dynamic>? _fieldImpl(String fieldName, $className? obj) {\n',
    );
    str.write('    obj ??= object;\n\n');

    _buildSwitches(str, 'fieldName', entries.keys, (name) {
      var field = entries[name]!;

      if (verbose) {
        log.info('[FIELD] $field');
      }

      var fieldDeclaringType = field.declaringType;

      if (fieldDeclaringType == null) {
        throw StateError(
          "Can't determine `declaringType` for field `$name`: $field",
        );
      }

      if (field.isTypeWithReflection) {
        fieldsTypesWithEnableReflection.addAll(field.getTypesWithReflection());
      }

      var declaringType = fieldDeclaringType.typeNameResolvable;
      var typeCode = field.typeAsCode(typeAliasTable);
      var fullType = field.typeNameAsNullableCode;
      var nullable = field.nullable ? 'true' : 'false';
      var isFinal = field.isFinal ? 'true' : 'false';
      var getter = '(o) => () => o!.$name';
      var setter = !field.allowSetter ? 'null' : '(o) => (v) => o!.$name = v';

      var annotations = field.annotationsAsListCode;

      return "FieldReflection<$className,$fullType>(this, $declaringType, "
          "$typeCode, '$name', $nullable, "
          "$getter , $setter , "
          "obj, $isFinal, "
          "${annotations != 'null' ? '$annotations, ' : ''} "
          ")";
    });

    str.write('  }\n\n');

    str.write('  @override\n');
    str.write(
      '  Map<String,dynamic> getFieldsValues($className? obj, {bool withHashCode = false}) {',
    );
    str.write('    obj ??= object;\n');
    str.write('    return <String,dynamic>{\n');
    for (var fieldName in entries.keys) {
      if (fieldName == 'hashCode') continue;
      str.write("      '$fieldName': obj?.$fieldName,");
    }
    str.write("      if (withHashCode) 'hashCode': obj?.hashCode,");
    str.write('    };\n');
    str.write('  }\n\n');

    var entriesWithJsonFieldHidden =
        entries.entries
            .where(
              (e) =>
                  e.key != 'hashCode' &&
                  e.value.annotations.any((a) {
                    var o = a.computeConstantValue();
                    if (o == null) return false;

                    var isJsonField =
                        o.type?.getDisplayStringNoNullability() == 'JsonField';
                    if (!isJsonField) return false;

                    var hidden = o.getField('_hidden')?.toBoolValue() ?? false;
                    return hidden;
                  }),
            )
            .toList();

    if (entriesWithJsonFieldHidden.isNotEmpty) {
      var hiddenKeys = entriesWithJsonFieldHidden.map((e) => e.key).toSet();
      var visibleKeys =
          entries.keys.where((k) => !hiddenKeys.contains(k)).toList();

      str.write('  @override\n');
      str.write(
        '  Map<String,dynamic> getJsonFieldsVisibleValues($className? obj, {bool withHashCode = false}) {',
      );
      str.write('    obj ??= object;\n');
      str.write('    return <String,dynamic>{\n');
      for (var fieldName in visibleKeys) {
        if (fieldName == 'hashCode') continue;
        str.write("      '$fieldName': obj?.$fieldName,");
      }
      str.write("      if (withHashCode) 'hashCode': obj?.hashCode,");
      str.write('    };\n');

      str.write('  }\n\n');
    }
  }

  void _buildStaticFields(StringBuffer str) {
    var entries = _toFieldEntries(staticFields);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _staticFieldsNames = $names;\n\n');

    str.write('  @override\n');
    str.write(
      '  List<String> get staticFieldsNames => _staticFieldsNames;\n\n',
    );

    if (entries.isEmpty) {
      str.write('  @override\n');
      str.write(
        '  StaticFieldReflection<$className,T>? staticField<T>(String fieldName) => null;\n\n',
      );
      return;
    }

    str.write(
      '  static final Map<String,StaticFieldReflection<$className,dynamic>> _staticFields = {};\n\n',
    );

    str.write('  @override\n');
    str.write(
      '  StaticFieldReflection<$className,T>? staticField<T>(String fieldName) {\n',
    );

    str.write('    var f = _staticFields[fieldName];\n');
    str.write(
      '    if (f != null) {return f as StaticFieldReflection<$className,T>;}\n',
    );
    str.write('    f = _staticFieldImpl(fieldName);\n');
    str.write('    if (f == null) return null;\n');
    str.write('    _staticFields[fieldName] = f;\n');
    str.write('    return f as StaticFieldReflection<$className,T>;\n');

    str.write('  }\n\n');

    str.write(
      '  StaticFieldReflection<$className,dynamic>? _staticFieldImpl(String fieldName) {\n',
    );

    _buildSwitches(str, 'fieldName', entries.keys, (name) {
      var field = entries[name]!;
      if (verbose) {
        log.info('[FIELD] $field');
      }

      var fieldDeclaringType = field.declaringType;

      if (fieldDeclaringType == null) {
        throw StateError(
          "Can't determine `declaringType` for static field `$name`: $field",
        );
      }

      if (field.isTypeWithReflection) {
        staticFieldsTypesWithEnableReflection.addAll(
          field.getTypesWithReflection(),
        );
      }

      var declaringType = fieldDeclaringType.typeNameResolvable;
      var typeCode = field.typeAsCode(typeAliasTable);
      var fullType = field.typeNameAsNullableCode;
      var nullable = field.nullable ? 'true' : 'false';
      var isFinal = field.isFinal ? 'true' : 'false';
      var getter = '() => () => $className.$name';
      var setter =
          !field.allowSetter ? 'null' : '() => (v) => $className.$name = v';

      return "StaticFieldReflection<$className,$fullType>(this, $declaringType, "
          "$typeCode, '$name', $nullable, "
          "$getter , $setter , $isFinal, "
          "${field.annotationsAsListCode}, "
          ")";
    });

    str.write('  }\n\n');
  }

  Map<String, _Field> _toFieldEntries(Set<FieldElement> fields) {
    return Map.fromEntries(fields.map((e) => MapEntry(e.name!, _Field(e))));
  }

  void _buildCallMethodToJson(StringBuffer str) {
    var entries = _toMethodsEntries(methods);

    var toJsonMethod =
        entries.values
            .where((m) => m.name.toLowerCase() == 'tojson')
            .firstOrNull;

    if (toJsonMethod != null &&
        toJsonMethod.normalParameters.isEmpty &&
        !toJsonMethod.hasRequiredNamedParameter) {
      str.write('  @override\n');
      str.write('  bool get hasMethodToJson => true;\n\n');
      str.write('  @override\n');
      str.write(
        '  Object? callMethodToJson([$className? obj]) { obj ??= object ; return obj?.${toJsonMethod.name}();}\n\n',
      );
    } else {
      str.write('  @override\n');
      str.write('  bool get hasMethodToJson => false;\n\n');
      str.write('  @override\n');
      str.write('  Object? callMethodToJson([$className? obj]) => null;\n\n');
    }
  }

  void _buildMethods(StringBuffer str) {
    var entries = _toMethodsEntries(methods);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _methodsNames = $names;\n\n');

    str.write('  @override\n');
    str.write('  List<String> get methodsNames => _methodsNames;\n\n');

    if (entries.isEmpty) {
      str.write('  @override\n');
      str.write(
        '  MethodReflection<$className,R>? method<R>(String methodName, [$className? obj]) => null;\n',
      );
      return;
    }

    str.write(
      '  static final Map<String,MethodReflection<$className,dynamic>> _methodsNoObject = {};\n\n',
    );

    str.write(
      '  final Map<String,MethodReflection<$className,dynamic>> _methodsObject = {};\n\n',
    );

    str.write('  @override\n');
    str.write(
      '  MethodReflection<$className,R>? method<R>(String methodName, [$className? obj]) {\n',
    );

    //str.write('    return _methodImpl<R>(methodName, obj);\n');

    str.write('    if (obj == null) {\n');
    str.write('      if (object != null) {\n');
    str.write('        return _methodObjectImpl<R>(methodName);\n');
    str.write('      } else {\n');
    str.write('        return _methodNoObjectImpl<R>(methodName);\n');
    str.write('      }\n');
    str.write('    } else if (identical(obj, object)) {\n');
    str.write('      return _methodObjectImpl<R>(methodName);\n');
    str.write('    }\n');
    str.write(
      '    return _methodNoObjectImpl<R>(methodName)?.withObject(obj);\n',
    );

    str.write('  }\n\n');

    str.write(
      '  MethodReflection<$className,R>? _methodNoObjectImpl<R>(String methodName) {\n',
    );
    str.write('    final m = _methodsNoObject[methodName];\n');
    str.write(
      '    if (m != null) {return m as MethodReflection<$className, R>;}\n',
    );
    str.write('    final m2 = _methodImpl(methodName, null);\n');
    str.write('    if (m2 == null) return null;\n');
    str.write('    _methodsNoObject[methodName] = m2;\n');
    str.write('    return m2 as MethodReflection<$className, R>;\n');
    str.write('  }\n\n');

    str.write(
      '  MethodReflection<$className,R>? _methodObjectImpl<R>(String methodName) {\n',
    );
    str.write('    final m = _methodsObject[methodName];\n');
    str.write(
      '    if (m != null) {return m as MethodReflection<$className, R>;}\n',
    );
    str.write('    var m2 = _methodNoObjectImpl<R>(methodName);\n');
    str.write('    if (m2 == null) return null;\n');
    str.write('    m2 = m2.withObject(object!);\n');
    str.write('    _methodsObject[methodName] = m2;\n');
    str.write('    return m2;\n');
    str.write('  }\n\n');

    str.write(
      '  MethodReflection<$className,dynamic>? _methodImpl(String methodName, $className? obj) {\n',
    );
    str.write('    obj ??= object;\n\n');

    _buildSwitches(str, 'methodName', entries.keys, (name) {
      var method = entries[name]!;
      if (verbose) {
        log.info('[METHOD] $method');
      }

      typeAliasTable.addAllNamedParameters(method.namedParameters.keys);

      var declaringType = method.declaringType!.typeNameResolvable;
      var returnType = method.returnTypeNameAsCode;

      var returnTypeAsCode = method.returnTypeAsCode;

      var nullable = method.returnNullable ? 'true' : 'false';

      return "MethodReflection<$className,$returnType>("
          "this, $declaringType, '$name', $returnTypeAsCode, $nullable, (o) => o!.$name , obj , "
          "${method.normalParametersAsCode} , "
          "${method.optionalParametersAsCode}, "
          "${method.namedParametersAsCode}, "
          "${method.annotationsAsListCode}"
          ")";
    });

    str.write('  }\n\n');
  }

  void _buildStaticMethods(StringBuffer str) {
    var entries = _toMethodsEntries(staticMethods);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  static const List<String> _staticMethodsNames = $names;\n\n');

    str.write('  @override\n');
    str.write(
      '  List<String> get staticMethodsNames => _staticMethodsNames;\n\n',
    );

    if (entries.isEmpty) {
      str.write('  @override\n');
      str.write(
        '  StaticMethodReflection<$className,R>? staticMethod<R>(String methodName) => null;\n\n',
      );
      return;
    }

    str.write(
      '  static final Map<String,StaticMethodReflection<$className,dynamic>> _staticMethods = {};\n\n',
    );

    str.write('  @override\n');
    str.write(
      '  StaticMethodReflection<$className,R>? staticMethod<R>(String methodName) {\n',
    );

    str.write('    var m = _staticMethods[methodName];\n');
    str.write(
      '    if (m != null) {return m as StaticMethodReflection<$className,R>;}\n',
    );
    str.write('    m = _staticMethodImpl(methodName);\n');
    str.write('    if (m == null) return null;\n');
    str.write('    _staticMethods[methodName] = m;\n');
    str.write('    return m as StaticMethodReflection<$className,R>;\n');

    str.write('  }\n\n');

    str.write(
      '  StaticMethodReflection<$className,dynamic>? _staticMethodImpl(String methodName) {\n',
    );

    _buildSwitches(str, 'methodName', entries.keys, (name) {
      var method = entries[name]!;
      if (verbose) {
        log.info('[METHOD] $method');
      }

      var declaringType = method.declaringType!.typeNameResolvable;
      var returnType = method.returnTypeNameAsCode;
      var returnTypeAsCode = method.returnTypeAsCode;
      var nullable = method.returnNullable ? 'true' : 'false';

      return "StaticMethodReflection<$className,$returnType>("
          "this, $declaringType, '$name', $returnTypeAsCode, $nullable, () => $className.$name , "
          "${method.normalParametersAsCode} , "
          "${method.optionalParametersAsCode}, "
          "${method.namedParametersAsCode}, "
          "${method.annotationsAsListCode}"
          ")";
    });

    str.write('  }\n\n');
  }

  Map<String, _Constructor> _toConstructorEntries(
    _ClassTree<T> classTree,
    Set<ConstructorElement> elements,
  ) {
    return Map.fromEntries(
      elements.map((c) {
        return MapEntry(c.codeName, _Constructor(classTree, c));
      }),
    );
  }

  Map<String, _Method> _toMethodsEntries(Set<MethodElement> elements) {
    return Map.fromEntries(
      elements.map((m) {
        return MapEntry(m.name!, _Method(this, m));
      }),
    );
  }

  void _buildSwitches(
    StringBuffer str,
    String argName,
    Iterable<String> entriesNames,
    String Function(String name) caseReturn,
  ) {
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
        '  /// Returns a [ClassReflection] for type [$className]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  ClassReflection<$className> get reflection => $reflectionClass(this);\n',
      );
      entriesCount++;
    }

    if (!hasEntry('toJson')) {
      str.write(
        '\n  /// Returns a JSON for type [$className]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  Object? toJson({bool duplicatedEntitiesAsID = false}) => reflection.toJson(null, null, duplicatedEntitiesAsID);\n',
      );
      entriesCount++;
    }

    if (!hasEntry('toJsonMap')) {
      str.write(
        '\n  /// Returns a JSON [Map] for type [$className]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  Map<String,dynamic>? toJsonMap({bool duplicatedEntitiesAsID = false}) => reflection.toJsonMap(duplicatedEntitiesAsID: duplicatedEntitiesAsID);\n',
      );
      entriesCount++;
    }

    if (!hasEntry('toJsonEncoded')) {
      str.write(
        '\n  /// Returns an encoded JSON [String] for type [$className]. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  String toJsonEncoded({bool pretty = false, bool duplicatedEntitiesAsID = false}) => reflection.toJsonEncoded(pretty: pretty, duplicatedEntitiesAsID: duplicatedEntitiesAsID);\n',
      );
      entriesCount++;
    }

    if (!hasEntry('toJsonFromFields')) {
      str.write(
        '\n  /// Returns a JSON for type [$className] using the class fields. (Generated by [ReflectionFactory])\n',
      );
      str.write(
        '  Object? toJsonFromFields({bool duplicatedEntitiesAsID = false}) => reflection.toJsonFromFields(duplicatedEntitiesAsID: duplicatedEntitiesAsID);\n',
      );
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
    Set<DartObject> ignoreMethods,
    _TypeAliasTable typeAliasTable,
  ) {
    if (!_implementsType(proxyClass, 'ClassProxyListener')) {
      throw StateError(
        "`ClassProxy` is being used in a class that is not implementing `ClassProxyListener`: ${proxyClass.name}",
      );
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
      typeProvider,
      typeAliasTable,
    );

    str.write('}\n\n');

    return str.toString();
  }

  static const TypeChecker typeIgnoreClassProxyMethod = TypeChecker.fromRuntime(
    IgnoreClassProxyMethod,
  );

  void _buildClassProxyMethods(
    StringBuffer codeBuffer,
    bool alwaysReturnFuture,
    Set<DartType> traverseReturnTypes,
    Set<DartType> ignoreParametersTypes,
    Set<String> ignoreMethods,
    TypeProvider typeProvider,
    _TypeAliasTable typeAliasTable,
  ) {
    final fReturnValue = typeAliasTable.fReturnValue;
    final fReturnFuture = typeAliasTable.fReturnFuture;
    final fReturnFutureOr = typeAliasTable.fReturnFutureOr;

    var str = StringBuffer();

    var traverseReturnInterfaceTypes =
        traverseReturnTypes.map((e) => e.interfaceType).nonNulls.toSet();

    var entriesCount = 0;

    var methods = this.methods.where((e) => !e.isStatic).toList();

    for (var method in methods) {
      var methodName = method.name;
      if (methodName == 'toString' || ignoreMethods.contains(methodName)) {
        continue;
      }

      if (method.isAnnotatedWith(typeIgnoreClassProxyMethod)) {
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
          traverseReturnInterfaceTypes.contains(
            proxyMethod.returnType.interfaceType,
          )) {
        proxyMethod = proxyMethod.traverseReturnType();
      }

      if (alwaysReturnFuture && !proxyMethod.isReturningFuture) {
        if (proxyMethod.isReturningFutureOr) {
          proxyMethod = proxyMethod.traverseReturnType().returningFuture(
            typeProvider,
          );
        } else {
          proxyMethod = proxyMethod.returningFuture(typeProvider);
        }
      }

      str.write(proxyMethod.signature(ignoreParametersTypes));

      str.write(' {\n');

      var returnTypeAsCode = proxyMethod.returnType.asTypeReflectionCode(
        typeAliasTable,
      );

      var call = StringBuffer();

      call.write("onCall( this, '${proxyMethod.name}', <String,dynamic>{\n");
      for (var p in method.formalParameters) {
        if (ignoreParametersTypes.containsType(p.type)) continue;
        var name = p.name;
        call.write("  '${p.name}': $name,\n");
      }
      call.write("  }, $returnTypeAsCode );\n");

      if (!proxyMethod.isReturningVoid) {
        str.write('  var ret = ');
        str.write(call);

        var acceptsNull = proxyMethod.returnAcceptsNull;

        if (proxyMethod.isReturningFuture || proxyMethod.isReturningFutureOr) {
          var futureType = proxyMethod.returnTypeArgument;

          var futureTypeStr =
              futureType != null && futureType is VoidType
                  ? 'dynamic'
                  : (futureType?.fullTypeNameResolvable() ?? 'dynamic');

          if (acceptsNull) {
            str.write('  if (ret == null) return null;\n');
          }

          if (proxyMethod.isReturningFuture) {
            typeAliasTable.fReturnFutureUseCount++;
            str.write('  return $fReturnFuture<$futureTypeStr>(ret);\n');
          } else {
            typeAliasTable.fReturnFutureOrUseCount++;
            str.write('  return $fReturnFutureOr<$futureTypeStr>(ret);\n');
          }
        } else {
          var valueType = proxyMethod.returnType;
          var valueTypeStr = valueType.fullTypeNameResolvable();

          if (acceptsNull) {
            str.write('  if (ret == null) return null;\n');
          }

          typeAliasTable.fReturnValueUseCount++;
          str.write('  return $fReturnValue<$valueTypeStr>(ret);\n');
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
      supertypes = typeElement.allSupertypes.toList();
    } else if (typeElement is InterfaceType) {
      supertypes = typeElement.allSupertypes.toList();
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
  final List<FormalParameterElement> parameters;
  final List<TypeParameterElement> typeParameters;

  _ProxyMethod(
    this.name,
    this.returnType,
    this.parameters,
    this.typeParameters,
  );

  factory _ProxyMethod.fromMethodElement(MethodElement method) {
    return _ProxyMethod(
      method.name!,
      method.returnType,
      method.formalParameters.toList(),
      method.typeParameters.toList(),
    );
  }

  List<String> get typeParametersNames =>
      typeParameters.map((e) => e.name).nonNulls.toList();

  List<FormalParameterElement> get positionalParameters =>
      parameters
          .where((p) => p.isPositional && !p.isOptionalPositional)
          .toList();

  List<FormalParameterElement> get positionalOptionalParameters =>
      parameters.where((p) => p.isOptionalPositional).toList();

  List<FormalParameterElement> get namedParameters =>
      parameters.where((p) => p.isNamed).toList();

  bool get returnAcceptsNull => returnType.isNullable;

  bool get isReturningVoid => returnType is VoidType;

  bool get isReturningFuture => returnType.isDartAsyncFuture;

  bool get isReturningFutureOr => returnType.isDartAsyncFutureOr;

  String get returnTypeAsString => returnType.getDisplayString();

  String returnTypeNameResolvable({bool withNullability = true}) =>
      returnType.fullTypeNameResolvable(
        withNullability: withNullability,
        typeParameters: typeParametersNames,
      );

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
      var pStr = p.displayString();
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
        parametersStr,
        positionalParameters,
        ignoreParametersTypes,
      );
    }

    if (positionalOptionalParameters.isNotEmpty) {
      if (parametersStr.isNotEmpty) {
        parametersStr.write(', ');
      }

      parametersStr.write('[ ');
      _writeParameters(
        parametersStr,
        positionalOptionalParameters,
        ignoreParametersTypes,
      );
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

  void _writeParameters(
    StringBuffer parametersStr,
    List<FormalParameterElement> parameters,
    Set<DartType> ignoreParametersTypes,
  ) {
    for (int i = 0; i < parameters.length; i++) {
      var e = parameters[i];

      if (ignoreParametersTypes.containsType(e.type)) continue;

      if (i > 0) parametersStr.write(', ');
      var pStr = e.displayString();
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

  DartType? get thisType {
    var e = _element;

    if (e is InterfaceElement) {
      return e.thisType;
    } else if (e is FieldElement) {
      return e.type;
    }

    return null;
  }

  DartType? get declaringType {
    var element = _element;
    if (element is InterfaceElement) {
      return null;
    }

    var enclosingElement = element.enclosingElement;

    if (enclosingElement is InterfaceElement) {
      return enclosingElement.thisType;
    }

    return null;
  }

  List<ElementAnnotation>? _annotations;

  List<ElementAnnotation> get annotations =>
      _annotations ??= _annotationsImpl();

  List<ElementAnnotation> _annotationsImpl() {
    var element = _element;
    var metadata = List<ElementAnnotation>.from(element.metadata.annotations);

    if (element is FieldElement) {
      var getter = element.getter;
      if (getter != null) {
        metadata.addAll(getter.metadata.annotations);
      }

      var setter = element.setter;
      if (setter != null) {
        metadata.addAll(setter.metadata.annotations);
      }
    }

    return UnmodifiableListView(metadata);
  }

  List<String> get annotationsAsCode {
    return annotations
        .map((e) => e.toSource())
        .where(
          (src) =>
              !src.startsWith('@EnableReflection(') &&
              !src.startsWith('@ReflectionBridge('),
        )
        .map((src) {
          if (src.startsWith('@')) {
            src = src.substring(1);
          }
          return src;
        })
        .toList();
  }

  String get annotationsAsListCode {
    var codes = annotationsAsCode;
    return codes.isEmpty ? 'null' : 'const [${codes.join(',')}]';
  }
}

class _Parameter extends _Element {
  final FormalParameterElement parameterElement;
  final int parameterIndex;

  final DartType type;
  final String name;

  final bool nullable;

  final bool required;

  _Parameter(
    this.parameterElement,
    this.parameterIndex,
    this.type,
    this.name,
    this.nullable,
    this.required,
  ) : super(parameterElement);

  bool get isNullable => nullable || type is DynamicType;

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

  _TypeAliasTable get typeAliasTable => classTree.typeAliasTable;

  String get name => constructorElement.codeName;

  bool get returnNullable => constructorElement.returnType.isNullable;

  bool get isStatic => constructorElement.isStatic;

  String get returnTypeNameAsCode =>
      constructorElement.returnType.typeNameAsNullableCode;

  String get returnTypeAsCode =>
      constructorElement.returnType.asTypeReflectionCode(typeAliasTable);

  List<_Parameter> get normalParameters =>
      constructorElement.type.normalParameters;

  List<_Parameter> get optionalParameters =>
      constructorElement.type.optionalParameters;

  Map<String, _Parameter> get namedParameters =>
      constructorElement.type.namedParameters;

  String get normalParametersAsCode => _buildParameterReflectionList(
    typeAliasTable,
    normalParameters,
    nullOnEmpty: true,
    required: true,
  );

  String get optionalParametersAsCode => _buildParameterReflectionList(
    typeAliasTable,
    optionalParameters,
    nullOnEmpty: true,
    required: false,
  );

  String get namedParametersAsCode => _buildNamedParameterReflectionMap(
    typeAliasTable,
    namedParameters,
    nullOnEmpty: true,
  );

  String get fullName {
    var className = classTree.className;
    var constructorName = name.isEmpty ? 'new' : name;
    return '$className.$constructorName';
  }

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
  final _ClassTree classTree;
  final MethodElement methodElement;

  _Method(this.classTree, this.methodElement) : super(methodElement);

  _TypeAliasTable get typeAliasTable => classTree.typeAliasTable;

  String get name => methodElement.name!;

  bool get returnNullable => methodElement.returnType.isNullable;

  bool get isStatic => methodElement.isStatic;

  DartType get returnType => methodElement.returnType;

  String get returnTypeNameAsCode =>
      methodElement.returnType.typeNameAsNullableCode;

  String get returnTypeAsCode =>
      methodElement.returnType.asTypeReflectionCode(typeAliasTable);

  List<_Parameter> get normalParameters => methodElement.type.normalParameters;

  List<_Parameter> get optionalParameters =>
      methodElement.type.optionalParameters;

  Map<String, _Parameter> get namedParameters =>
      methodElement.type.namedParameters;

  bool get hasRequiredNamedParameter =>
      namedParameters.values
          .where((m) => m.required || (!m.isNullable && !m.hasDefaultValue))
          .isNotEmpty;

  String get normalParametersAsCode => _buildParameterReflectionList(
    typeAliasTable,
    normalParameters,
    nullOnEmpty: true,
    required: true,
  );

  String get optionalParametersAsCode => _buildParameterReflectionList(
    typeAliasTable,
    optionalParameters,
    nullOnEmpty: true,
    required: false,
  );

  String get namedParametersAsCode => _buildNamedParameterReflectionMap(
    typeAliasTable,
    namedParameters,
    nullOnEmpty: true,
  );

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

  String get name => fieldElement.name!;

  bool get isDartCore => fieldElement.type.isDartCore;

  bool get isFunctionType => fieldElement.type.isFunctionType;

  bool get nullable => fieldElement.type.isNullable;

  bool get isStatic => fieldElement.isStatic;

  bool get isFinal => fieldElement.isFinal;

  bool get isConst => fieldElement.isConst;

  bool get allowSetter => !isFinal && !isConst && fieldElement.setter != null;

  String get typeNameAsCode => fieldElement.type.typeNameAsCode;

  String get typeNameAsNullableCode => fieldElement.type.typeNameAsNullableCode;

  bool get isTypeWithReflection => fieldElement.type.isTypeWithReflection;

  Iterable<DartType> getTypesWithReflection() =>
      fieldElement.type.getTypesWithReflection();

  String typeAsCode(_TypeAliasTable typeAliasTable) =>
      fieldElement.type.asTypeReflectionCode(typeAliasTable);

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

  String toListOfConstTypeCode(
    _TypeAliasTable typeAliasTable, {
    bool allowConstPrefix = true,
  }) {
    final tr = typeAliasTable.trName;
    final ti = typeAliasTable.tiName;

    var listConstTypeReflection = map(
      (e) => e.asConstTypeReflectionCode(typeAliasTable),
    ).toList(growable: false);
    if (listConstTypeReflection.every((e) => e != null)) {
      return '<$tr>[${listConstTypeReflection.join(',')}]';
    }

    var listConstTypeInfo = map(
      (e) => e.asConstTypeInfoCode(typeAliasTable),
    ).toList(growable: false);
    if (listConstTypeInfo.every((e) => e != null)) {
      return '<$ti>[${listConstTypeInfo.join(',')}]';
    }

    var listTypeReflection = map(
      (e) => e.asTypeReflectionCode(
        typeAliasTable,
        allowConstPrefix: allowConstPrefix,
      ),
    ).toList(growable: false);
    return '<$tr>[${listTypeReflection.join(',')}]';
  }

  String get typesNames =>
      map((e) => e.fullTypeNameResolvable(withNullability: true)).join(', ');
}

extension _DartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;

  bool get isParameterType => this is TypeParameterType;

  bool get isResolvableType => !isParameterType;

  static final Map<DartType, String> _typeNameResolvableCache = {};

  String get typeNameResolvable =>
      _typeNameResolvableCache[this] ??= resolveTypeName();

  static final Map<DartType, bool> _isDartCoreCache = {};

  bool get isDartCore => _isDartCoreCache[this] ??= _isDartCoreImpl();

  bool _isDartCoreImpl() {
    final type = this;
    return type.isDartCoreType ||
        type.isDartCoreString ||
        type.isDartCoreNum ||
        type.isDartCoreDouble ||
        type.isDartCoreInt ||
        type.isDartCoreEnum ||
        type.isDartCoreBool ||
        type.isDartCoreList ||
        type.isDartCoreMap ||
        type.isDartCoreSet ||
        type.isDartCoreIterable ||
        type.isDartCoreFunction ||
        type.isDartAsyncFuture ||
        type.isDartAsyncFutureOr;
  }

  bool get isFunctionType => this is FunctionType;

  static final Map<DartType, bool> _isTypeWithReflectionCache = {};

  bool get isTypeWithReflection =>
      _isTypeWithReflectionCache[this] ??= _isTypeWithReflectionImpl();

  bool _isTypeWithReflectionImpl() {
    if (isDartCore) return false;
    if (isFunctionType) return false;

    var enableReflection =
        element?.isAnnotatedWith(ReflectionBuilder.typeEnableReflection) ??
        false;

    if (enableReflection) return true;

    final self = this;
    if (self is ParameterizedType) {
      return self.typeArguments.any((t) => t.isTypeWithReflection);
    } else {
      return false;
    }
  }

  static final Map<DartType, List<DartType>> _typesWithReflectionCache = {};

  Iterable<DartType> getTypesWithReflection() =>
      _typesWithReflectionCache[this] ??= _getTypesWithReflectionImpl();

  static final List<DartType> _emptyListDartType = List<DartType>.unmodifiable(
    [],
  );

  List<DartType> _getTypesWithReflectionImpl() {
    if (isDartCore) return _emptyListDartType;
    if (isFunctionType) return _emptyListDartType;

    var enableReflection =
        element?.isAnnotatedWith(ReflectionBuilder.typeEnableReflection) ??
        false;

    var parametersWithReflection = _getTypeParametersWithReflection();

    if (enableReflection) {
      return List.unmodifiable(
        parametersWithReflection.isEmpty
            ? [this]
            : [this, ...parametersWithReflection],
      );
    } else {
      return parametersWithReflection;
    }
  }

  List<DartType> _getTypeParametersWithReflection() {
    final self = this;
    if (self is ParameterizedType) {
      return List.unmodifiable(
        self.typeArguments.expand((t) => t.getTypesWithReflection()),
      );
    } else {
      return _emptyListDartType;
    }
  }

  static final _regexpNullableSuffix = RegExp(r'\?$');

  String getDisplayStringNoNullability() {
    var type = getDisplayString();
    if (type.contains('?')) {
      type = type.trim().replaceFirst(_regexpNullableSuffix, '');
    }
    return type;
  }

  String resolveTypeName({Iterable<String>? typeParameters}) {
    if (isRecordType) {
      return recordDeclaration(typeParameters: typeParameters)!;
    }

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

  String fullTypeNameResolvable({
    bool withNullability = true,
    Iterable<String>? typeParameters,
  }) {
    if (this is InvalidType) {
      return 'dynamic';
    }

    var name = resolveTypeName(typeParameters: typeParameters);

    if (!hasTypeArguments) {
      return withNullability && isNullable ? '$name?' : name;
    }

    var argsList =
        resolvedTypeArguments.map((e) {
          return e.fullTypeNameResolvable(
            withNullability: withNullability,
            typeParameters: typeParameters,
          );
        }).toList();

    if (argsList.isEmpty || argsList.every((a) => a == 'dynamic')) {
      return name;
    }

    var args = argsList.join(',');

    return withNullability && isNullable ? '$name<$args>?' : '$name<$args>';
  }

  bool get isRecordType => this is RecordType;

  String? recordDeclaration({Iterable<String>? typeParameters}) {
    if (!isRecordType) return null;

    var recordType = this as RecordType;

    var recordTypesNamesPos =
        recordType.positionalFields.map((t) {
          return t.type.fullTypeNameResolvable(typeParameters: typeParameters);
        }).toList();

    var recordTypesNamesNamed =
        recordType.namedFields.map((t) {
          return '${t.type.fullTypeNameResolvable(typeParameters: typeParameters)} ${t.name}';
        }).toList();

    var list = [
      '(',
      if (recordTypesNamesPos.isNotEmpty) recordTypesNamesPos.join(', '),
      if (recordTypesNamesNamed.isNotEmpty) ...[
        '{',
        recordTypesNamesNamed.join(', '),
        '}',
      ],
      ')',
    ];

    var recordDeclaration = list.join();

    return recordDeclaration;
  }

  static final Map<DartType, String> _typeNameCache = {};

  String get typeName => _typeNameCache[this] ??= _typeNameImpl();

  String _typeNameImpl() {
    if (isRecordType) {
      return recordDeclaration()!;
    }

    var name = elementDeclaration?.name;

    if (name == null) {
      name = getDisplayStringNoNullability();

      var idx = name.indexOf('Function(');

      if (idx == 0 ||
          (idx > 0 && name.substring(idx - 1, idx).trim().isEmpty)) {
        name = 'Function';
      } else {
        name = TypeInfo.removeTypeGenerics(name);
      }
    }

    return name;
  }

  InterfaceType? get interfaceType {
    var element = elementDeclaration;
    if (element is InterfaceElement) {
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

  static final Map<DartType, bool> _hasSimpleTypeArgumentsCache = {};

  bool get hasSimpleTypeArguments =>
      _hasSimpleTypeArgumentsCache[this] ??= _hasSimpleTypeArgumentsImpl();

  bool _hasSimpleTypeArgumentsImpl() {
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

  static final Map<DartType, String> _typeNameAsCodeCache = {};

  String get typeNameAsCode =>
      _typeNameAsCodeCache[this] ??= _typeNameAsCodeImpl();

  String _typeNameAsCodeImpl() {
    var self = this;
    if (self is VoidType) {
      return 'void';
    }

    if (self is FunctionType) {
      var alias = self.alias;
      if (alias != null && alias.typeArguments.isEmpty) {
        var name =
            alias.element.name ??
            (throw StateError(
              "Can't resolve `FunctionType` alias name: $alias",
            ));
        return name;
      } else {
        var functionType = self.getDisplayStringNoNullability();
        return functionType;
      }
    }

    var name = typeNameResolvable;
    var arguments = resolvedTypeArguments;

    if (arguments.isNotEmpty) {
      return '$name<${arguments.map((e) => e.typeNameAsNullableCode).join(', ')}>';
    } else {
      return name;
    }
  }

  String get typeNameAsNullableCode =>
      isNullable && this is! DynamicType && isResolvableType
          ? '$typeNameAsCode?'
          : typeNameAsCode;

  String? asConstTypeReflectionCode(_TypeAliasTable typeAliasTable) {
    var self = this;

    final tr = typeAliasTable.trName;

    if (self is VoidType) {
      return '$tr.tVoid';
    }

    if (self is FunctionType) {
      var alias = self.alias;
      if (alias != null) {
        return null;
      } else {
        return '$tr.tFunction';
      }
    }

    var name = typeNameResolvable;
    var arguments = resolvedTypeArguments;

    if (arguments.isNotEmpty) {
      if (self.isDartAsyncFuture) {
        if (arguments.isEmpty) {
          return '$tr.tFutureDynamic';
        } else if (arguments[0] is VoidType) {
          return '$tr.tFutureVoid';
        }
      } else if (self.isDartAsyncFutureOr) {
        if (arguments.isEmpty) {
          return '$tr.tFutureOrDynamic';
        } else if (arguments[0] is VoidType) {
          return '$tr.tFutureOrVoid';
        }
      }

      if (hasSimpleTypeArguments) {
        var typeArgs = arguments.typesNamesResolvable;

        var constName = TypeReflection.getConstantName(name, typeArgs);
        if (constName != null) {
          return '$tr.$constName';
        }
      }

      return null;
    } else {
      var constName = _getTypeReflectionConstantName(name);
      if (constName != null) {
        return '$tr.$constName';
      } else if (this is TypeParameterType) {
        return '$tr.tDynamic';
      }

      return null;
    }
  }

  String asTypeReflectionCode(
    _TypeAliasTable typeAliasTable, {
    bool allowConstPrefix = true,
  }) {
    var self = this;
    final tr = typeAliasTable.trName;

    if (self is VoidType) {
      return '$tr.tVoid';
    }

    if (self is FunctionType) {
      var alias = self.alias;
      if (alias != null) {
        var name = alias.element.name;
        List<DartType> arguments = alias.typeArguments;

        if (arguments.isEmpty) {
          var constPrefix = allowConstPrefix ? 'const ' : '';
          return '$constPrefix$tr<$name>($name)';
        } else {
          var argsCode = arguments.toListOfConstTypeCode(
            typeAliasTable,
            allowConstPrefix: false,
          );
          var allowConst = allowConstPrefix && !argsCode.contains('.tVoid');
          var constPrefix = allowConst ? 'const ' : '';
          return '$constPrefix$tr<$name<${arguments.typesNames}>>($name, $argsCode)';
        }
      } else {
        return '$tr.tFunction';
      }
    }

    var name = typeNameResolvable;
    var arguments = resolvedTypeArguments;

    if (self.isDartAsyncFuture) {
      if (arguments.isEmpty) {
        return '$tr.tFutureDynamic';
      } else if (arguments[0] is VoidType) {
        return '$tr.tFutureVoid';
      }
    } else if (self.isDartAsyncFutureOr) {
      if (arguments.isEmpty) {
        return '$tr.tFutureOrDynamic';
      } else if (arguments[0] is VoidType) {
        return '$tr.tFutureOrVoid';
      }
    }

    if (arguments.isNotEmpty) {
      if (hasSimpleTypeArguments) {
        var typeArgs = arguments.typesNamesResolvable;

        var constName = TypeReflection.getConstantName(name, typeArgs);
        if (constName != null) {
          return '$tr.$constName';
        }
      }

      var argsT = arguments.typesNames;
      var argsCode = arguments.toListOfConstTypeCode(
        typeAliasTable,
        allowConstPrefix: false,
      );
      var allowConst = allowConstPrefix && !argsCode.contains('.tVoid');
      var constPrefix = allowConst ? 'const ' : '';
      return '$constPrefix$tr<$name<$argsT>>($name, $argsCode)';
    } else {
      var constName = _getTypeReflectionConstantName(name);
      if (constName != null) {
        return '$tr.$constName';
      } else {
        var constPrefix = allowConstPrefix ? 'const ' : '';

        if (isRecordType) {
          typeNameResolvable;

          var typeAlias = typeAliasTable.aliasForRecordType(name);
          return '$constPrefix$tr<$typeAlias>($typeAlias)';
        } else if (this is TypeParameterType) {
          return '$tr.tDynamic';
        } else {
          return '$constPrefix$tr<$name>($name)';
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

  String? asConstTypeInfoCode(_TypeAliasTable typeAliasTable) {
    final ti = typeAliasTable.tiName;
    var constName = _getTypeReflectionConstantName();
    return constName == null ? null : '$ti.$constName';
  }
}

extension _ConstructorElementExtension on ConstructorElement {
  List<_Parameter> parametersWhere(
    bool Function(FormalParameterElement p) filter,
  ) {
    var list = <_Parameter>[];
    var i = 0;
    for (var p in formalParameters) {
      if (filter(p)) {
        var param = _Parameter(
          p,
          i,
          p.type,
          p.name!,
          p.type.isNullable,
          p.isRequiredNamed,
        );
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
        parametersWhere((p) => p.isNamed).map((e) => MapEntry(e.name, e)),
      );
}

extension _FormalParameterElementExtension on FormalParameterElement {
  bool get isNormal => isRequiredPositional;
}

extension _FunctionTypeExtension on FunctionType {
  List<String> get normalParameterNames =>
      formalParameters
          .where((p) => p.isNormal)
          .map((p) => p.name)
          .nonNulls
          .toList();

  List<_Parameter> get normalParameters {
    final normalParameterNames = this.normalParameterNames;
    final normalParameterTypes = this.normalParameterTypes;
    return List<_Parameter>.generate(normalParameterNames.length, (i) {
      var n = normalParameterNames[i];
      var t = normalParameterTypes[i];
      var p = formalParameters[i];
      return _Parameter(p, i, t, n, t.isNullable, true);
    });
  }

  List<String> get optionalParameterNames =>
      formalParameters
          .where((p) => p.isOptionalPositional)
          .map((p) => p.name)
          .nonNulls
          .toList();

  List<_Parameter> get optionalParameters {
    final optionalParameterNames = this.optionalParameterNames;
    final optionalParameterTypes = this.optionalParameterTypes;
    return List<_Parameter>.generate(optionalParameterNames.length, (i) {
      var n = optionalParameterNames[i];
      var t = optionalParameterTypes[i];
      var idx = normalParameterNames.length + i;
      var p = formalParameters[idx];
      return _Parameter(p, idx, t, n, t.isNullable, false);
    });
  }

  Map<String, _Parameter> get namedParameters {
    var map = <String, _Parameter>{};
    final normalParametersLength = normalParameterNames.length;
    final namedParametersLength = namedParameterTypes.length;

    for (var i = 0; i < namedParametersLength; ++i) {
      var idx = normalParametersLength + i;
      var p = formalParameters[idx];
      var key = p.name!;
      var type = p.type;
      var required = p.isRequiredNamed;
      var parameter = _Parameter(p, idx, type, key, type.isNullable, required);
      map[key] = parameter;
    }

    return map;
  }
}

bool _addWithUniqueName(Set<Element> set, Element element) {
  if (set.where((e) => e.name == element.name).isEmpty) {
    set.add(element);
    return true;
  }

  return false;
}

String _buildStringListCode(
  Iterable? o, {
  bool sorted = false,
  bool nullOnEmpty = false,
}) {
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

String _buildParameterReflectionList(
  _TypeAliasTable typeAliasTable,
  Iterable<_Parameter>? o, {
  required bool nullOnEmpty,
  required bool required,
}) {
  final pr = typeAliasTable.prName;

  if (o == null || o.isEmpty) {
    return nullOnEmpty ? 'null' : 'const <$pr>[]';
  } else {
    var parameters = o
        .map((e) {
          var defaultValue = e.defaultValue ?? 'null';
          var annotationsAsListCode = e.annotationsAsListCode;

          return "$pr( "
              "${e.type.asTypeReflectionCode(typeAliasTable, allowConstPrefix: false)} , "
              "'${e.name}' , "
              "${e.isNullable} , "
              "$required"
              "${defaultValue == 'null' && annotationsAsListCode == 'null' ? '' : ', $defaultValue '}"
              "${annotationsAsListCode == 'null' ? '' : ', $annotationsAsListCode'}"
              ")";
        })
        .join(', ');

    return 'const <$pr>[$parameters]';
  }
}

String _buildNamedParameterReflectionMap(
  _TypeAliasTable typeAliasTable,
  Map<String, _Parameter>? o, {
  bool nullOnEmpty = false,
}) {
  final pr = typeAliasTable.prName;

  if (o == null || o.isEmpty) {
    return nullOnEmpty ? 'null' : 'const <String,Type>{}}';
  } else {
    var parameters = o.entries
        .map((e) {
          var key = e.key;
          var value = e.value;
          var defaultValue = e.value.defaultValue ?? 'null';
          var annotationsAsListCode = e.value.annotationsAsListCode;

          return "'$key': $pr( "
              "${value.type.asTypeReflectionCode(typeAliasTable, allowConstPrefix: false)} , "
              "'${e.value.name}' , "
              "${e.value.isNullable} , "
              "${e.value.required} "
              "${defaultValue == 'null' && annotationsAsListCode == 'null' ? '' : ', $defaultValue '}"
              "${annotationsAsListCode == 'null' ? '' : ', $annotationsAsListCode'}"
              ")";
        })
        .join(', ');
    return 'const <String,$pr>{$parameters}';
  }
}
