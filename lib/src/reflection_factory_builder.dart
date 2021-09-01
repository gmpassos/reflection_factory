import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';

import 'analyzer/library.dart';
import 'analyzer/type_checker.dart';
import 'reflection_factory_annotation.dart';

/// The reflection builder.
class ReflectionBuilder implements Builder {
  /// If `true` builds code in verbose mode.
  bool verbose;

  ReflectionBuilder({this.verbose = false});

  @override
  final buildExtensions = const {
    '.dart': ['.reflection.g.dart']
  };

  static const TypeChecker typeReflectionBridge =
      TypeChecker.fromRuntime(ReflectionBridge);

  static const TypeChecker typeEnableReflection =
      TypeChecker.fromRuntime(EnableReflection);

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

    var codeTable = await _buildCodeTable(buildStep, libraryReader);

    if (codeTable.isEmpty) {
      return;
    }

    var fullCode = StringBuffer();

    fullCode.write('// \n');
    fullCode.write('// GENERATED CODE - DO NOT MODIFY BY HAND!\n');
    fullCode.write('// BUILDER: "reflection_factory"\n');
    fullCode.write('// BUILD COMMAND: dart run build_runner build\n');
    fullCode.write('// \n\n');

    fullCode.write("part of '${inputId.pathSegments.last}';\n\n");

    var codeKeys = codeTable.keys.toList();
    _sortCodeKeys(codeKeys);

    for (var key in codeKeys) {
      var code = codeTable[key]!;
      if (code.trim().isNotEmpty) {
        fullCode.write(code);
      }
    }

    var genId = inputId.changeExtension('.reflection.g.dart');

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

  Future<Map<String, String>> _buildCodeTable(
      BuildStep buildStep, LibraryReader libraryReader) async {
    var codeTable = <String, String>{};

    var annotatedReflectionBridge =
        libraryReader.annotatedWith(typeReflectionBridge).toList();

    for (var annotated in annotatedReflectionBridge) {
      if (annotated.element.kind == ElementKind.CLASS) {
        var codes = await _reflectionBridge(buildStep, annotated);
        codeTable.addAll(codes);
      }
    }

    var annotatedEnableReflection =
        libraryReader.annotatedWith(typeEnableReflection).toList();

    for (var annotated in annotatedEnableReflection) {
      if (annotated.element.kind == ElementKind.CLASS) {
        var classElement = annotated.element as ClassElement;

        var annotation = annotated.annotation;
        var reflectionClassName =
            annotation.peek('reflectionClassName')!.stringValue;
        var reflectionExtensionName =
            annotated.annotation.peek('reflectionExtensionName')!.stringValue;

        var codes = await _enableReflection(
          buildStep,
          classElement,
          reflectionClassName,
          reflectionExtensionName,
        );

        codeTable.addAll(codes);
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
      var classElement = classType.element;
      if (classElement == null || classElement is! ClassElement) {
        continue;
      }

      var classLibrary = await _getClassLibrary(buildStep, classElement);

      var reflectionClassName = reflectionExtensionNames[classType] ?? '';
      var reflectionExtensionName = reflectionExtensionNames[classType] ?? '';

      var classTree = _ClassTree(
        classElement,
        reflectionClassName,
        reflectionExtensionName,
        classLibrary.languageVersion.effective,
        verbose: verbose,
      );

      if (verbose) {
        print(classTree);
      }

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
      var className = classType.element!.name!;

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

  Future<Map<String, String>> _enableReflection(
      BuildStep buildStep,
      ClassElement classElement,
      String reflectionClassName,
      String reflectionExtensionName) async {
    var classLibrary = await _getClassLibrary(buildStep, classElement);

    var classTree = _ClassTree(
      classElement,
      reflectionClassName,
      reflectionExtensionName,
      classLibrary.languageVersion.effective,
      verbose: verbose,
    );

    if (verbose) {
      print(classTree);
    }

    var reflectionClassCode = classTree.buildReflectionClass();
    var reflectionExtensionCode = classTree.buildReflectionExtension();

    return {
      classTree.reflectionClass: reflectionClassCode,
      classTree.reflectionExtension: reflectionExtensionCode,
    };
  }

  Future<LibraryElement> _getClassLibrary(
      BuildStep buildStep, ClassElement classElement) async {
    var resolver = buildStep.resolver;

    var classAssetId = await resolver.assetIdForElement(classElement);
    var classLibrary = await resolver.libraryFor(classAssetId);
    return classLibrary;
  }
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

class _ClassTree<T> extends RecursiveElementVisitor<T> {
  final ClassElement _classElement;

  final String reflectionClassName;
  final String reflectionExtensionName;

  final Version languageVersion;

  final bool verbose;

  final String className;

  _ClassTree(this._classElement, this.reflectionClassName,
      this.reflectionExtensionName, this.languageVersion,
      {this.verbose = false})
      : className = _classElement.name {
    _classElement.visitChildren(this);
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

  String get reflectionClass =>
      _buildReflectionClassName(className, reflectionClassName);

  String get reflectionExtension =>
      _buildReflectionExtensionName(className, reflectionExtensionName);

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
      staticMethods.add(element);
    } else {
      methods.add(element);
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
      staticFields.add(element);
    } else {
      fields.add(element);
    }

    return super.visitFieldElement(element);
  }

  String buildReflectionClass() {
    var str = StringBuffer();

    str.write(
        'class $reflectionClass extends ClassReflection<$className> {\n\n');

    str.write(
        '  $reflectionClass([$className? object]) : super($className, object);\n\n');

    str.write('  bool _registered = false;\n');
    str.write('  @override');
    str.write('  void register() {\n');
    str.write('    if (!_registered) {\n');
    str.write('      _registered = true;\n');
    str.write('      super.register();\n');
    str.write('    }\n');
    str.write('  }\n\n');

    str.write('  @override');
    str.write(
        '  $reflectionClass withObject([$className? obj]) => $reflectionClass(obj);\n\n');

    str.write('  @override');
    str.write(
        "  Version get languageVersion => Version.parse('$languageVersion');\n\n");

    var classElement = _Element(_classElement);

    var classAnnotationListCode = classElement.annotationsAsListCode;
    if (classAnnotationListCode != 'null') {
      str.write(
          '  static const List<Object> _classAnnotations = $classAnnotationListCode; \n\n');
      str.write('  @override');
      str.write(
          '  List<Object> get classAnnotations => List<Object>.unmodifiable(_classAnnotations);\n\n');
    } else {
      str.write('  @override');
      str.write(
          '  List<Object> get classAnnotations => List<Object>.unmodifiable(<Object>[]);\n\n');
    }

    _buildField(str);
    _buildStaticField(str);

    _buildMethod(str);
    _buildStaticMethod(str);

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
        '  FieldReflection<$className,T>? field<T>(String fieldName, [$className? obj]) {\n');
    str.write('    obj ??= object!;\n\n');

    _buildSwitches(str, 'fieldName', entries.keys, (name) {
      var field = entries[name]!;

      if (verbose) {
        print(field);
      }

      var type = field.typeCodeName;
      var fullType = field.fullTypeCodeName;
      var nullable = field.nullable ? 'true' : 'false';
      var isFinal = field.isFinal ? 'true' : 'false';
      var getter = '(o) => () => o!.$name as T';
      var setter = !field.allowSetter
          ? 'null'
          : '(o) => (T v) => o!.$name = v as $fullType';

      return "FieldReflection<$className,T>(this, "
          "$type, '$name', $nullable, "
          "$getter , $setter , "
          "obj, false, $isFinal, "
          "${field.annotationsAsListCode}, "
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

      var type = field.typeCodeName;
      var fullType = field.fullTypeCodeName;
      var nullable = field.nullable ? 'true' : 'false';
      var isFinal = field.isFinal ? 'true' : 'false';
      var getter = '(o) => () => $className.$name as T';
      var setter = !field.allowSetter
          ? 'null'
          : '(o) => (T v) => $className.$name = v as $fullType';

      return "FieldReflection<$className,T>(this, "
          "$type, '$name', $nullable, "
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

  void _buildMethod(StringBuffer str) {
    var entries = _toMethodsEntries(methods);
    var names = _buildStringListCode(entries.keys, sorted: true);

    str.write('  @override\n');
    str.write('  List<String> get methodsNames => $names;\n\n');

    str.write('  @override\n');
    str.write(
        '  MethodReflection<$className>? method(String methodName, [$className? obj]) {\n');
    str.write('    obj ??= object;\n\n');

    _buildSwitches(str, 'methodName', entries.keys, (name) {
      var method = entries[name]!;
      if (verbose) {
        print(method);
      }

      var type = method.returnTypeCodeName;
      var nullable = method.returnNullable ? 'true' : 'false';
      return "MethodReflection<$className>("
          "this, '$name', $type, $nullable, (o) => o!.$name , obj , false, "
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
        '  MethodReflection<$className>? staticMethod(String methodName) {\n');

    _buildSwitches(str, 'methodName', entries.keys, (name) {
      var method = entries[name]!;
      if (verbose) {
        print(method);
      }

      var type = method.returnTypeCodeName;
      var nullable = method.returnNullable ? 'true' : 'false';
      return "MethodReflection<$className>("
          "this, '$name', $type, $nullable, (o) => $className.$name , null , true, "
          "${method.normalParametersAsCode} , "
          "${method.optionalParametersAsCode}, "
          "${method.namedParametersAsCode}, "
          "${method.annotationsAsListCode}"
          ")";
    });

    str.write('  }\n\n');
  }

  Map<String, _Method> _toMethodsEntries(Set<MethodElement> methods) {
    return Map.fromEntries(methods.map((m) {
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
          '\n  /// Returns a JSON [Map] for type [$className]. (Generated by [ReflectionFactory])\n');
      str.write('  Map<String,dynamic> toJson() => reflection.toJson();\n');
      entriesCount++;
    }

    if (!hasEntry('toJsonEncoded')) {
      str.write(
          '\n  /// Returns an encoded JSON [String] for type [$className]. (Generated by [ReflectionFactory])\n');
      str.write('  String toJsonEncoded() => reflection.toJsonEncoded();\n');
      entriesCount++;
    }

    str.write('}\n\n');

    if (entriesCount > 0) {
      codeBuffer.write(str);
    }
  }
}

class _Element {
  final Element _element;

  _Element(this._element);

  List<ElementAnnotation> get annotations => _element.metadata;

  List<String> get annotationsAsCode => _element.metadata
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
}

class _Method extends _Element {
  final MethodElement methodElement;

  _Method(this.methodElement) : super(methodElement);

  String get name => methodElement.name;

  bool get returnNullable =>
      methodElement.returnType.nullabilitySuffix == NullabilitySuffix.question;

  bool get isStatic => methodElement.isStatic;

  String get returnTypeCodeName => methodElement.returnType.typeCodeName;

  List<_Parameter> get normalParameters => methodElement.type.normalParameters;

  List<_Parameter> get optionalParameters =>
      methodElement.type.optionalParameters;

  Map<String, _Parameter> get namedParameters =>
      methodElement.type.namedParameters;

  String get normalParametersAsCode =>
      _buildParameterReflectionList(normalParameters, nullOnEmpty: true);

  String get optionalParametersAsCode =>
      _buildParameterReflectionList(optionalParameters, nullOnEmpty: true);

  String get namedParametersAsCode =>
      _buildNamedParameterReflectionMap(namedParameters, nullOnEmpty: true);

  @override
  String toString() {
    return '_Method{ '
        'name: $name, '
        'static: $isStatic, '
        'return: $returnTypeCodeName '
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

  bool get nullable =>
      fieldElement.type.nullabilitySuffix == NullabilitySuffix.question;

  bool get isStatic => fieldElement.isStatic;

  bool get isFinal => fieldElement.isFinal;

  bool get isConst => fieldElement.isConst;

  bool get allowSetter => !isFinal && !isConst && fieldElement.setter != null;

  String get typeCodeName => fieldElement.type.typeCodeName;

  String get fullTypeCodeName => nullable ? '$typeCodeName?' : typeCodeName;

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

extension _DartTypeExtension on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;

  bool get isRequired => element?.hasRequired ?? false;

  String get typeCodeName {
    if (this is VoidType) {
      return 'null';
    }
    return element?.name ?? getDisplayString(withNullability: false);
  }
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
    var i = 0;
    for (var e in namedParameterTypes.entries) {
      var key = e.key;
      var value = e.value;
      var idx = normalParameterNames.length + i;
      var p = parameters[idx];
      var parameter =
          _Parameter(p, idx, value, key, value.isNullable, value.isRequired);
      map[key] = parameter;
      i++;
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
    return 'const <String>[' + o.map((e) => "'$e'").join(', ') + ']';
  }
}

String _buildParameterReflectionList(Iterable<_Parameter>? o,
    {bool nullOnEmpty = false}) {
  if (o == null || o.isEmpty) {
    return nullOnEmpty ? 'null' : '<ParameterReflection>[]';
  } else {
    var parameters = o
        .map((e) => "ParameterReflection( "
            "${e.type.typeCodeName} , "
            "'${e.name}' , "
            "${e.nullable ? 'true' : 'false'} , "
            "false , "
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
          "${value.type.typeCodeName} , "
          "'${e.value.name}' , "
          "${e.value.nullable ? 'true' : 'false'} , "
          "${e.value.required ? 'true' : 'false'} , "
          "${e.value.annotationsAsListCode}"
          ")";
    }).join(', ');
    return 'const <String,ParameterReflection>{$parameters}';
  }
}
