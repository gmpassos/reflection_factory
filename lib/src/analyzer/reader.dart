// LICENSE: BSD-3-Clause License
// Original package: https://pub.dev/packages/source_gen
// Original source: https://github.com/dart-lang/source_gen

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';

import 'type_checker.dart';
import 'utils.dart';

/// A wrapper for analyzer's [DartObject] with a predictable high-level API.
///
/// Unlike [DartObject.getField], the [read] method attempts to access super
/// classes for the field value if not found.
abstract class ConstantReader {
  factory ConstantReader(DartObject? object) =>
      isNullLike(object) ? const _NullConstant() : _DartObjectConstant(object!);

  const ConstantReader._();

  /// Whether this constant is a literal value.
  bool get isLiteral => true;

  /// Constant as a literal value.
  ///
  /// Throws [FormatException] if a valid literal value cannot be returned. This
  /// is the case if the constant is not a literal or if the literal value
  /// is represented at least partially with [DartObject] instances.
  Object? get literalValue => null;

  /// Underlying object this instance is reading from.
  DartObject get objectValue;

  /// Whether the value this constant represents matches [checker].
  bool instanceOf(TypeChecker checker) => false;

  /// Reads [field] from the constant as another constant value.
  ///
  /// Unlike [read], returns `null` if the field is not found.
  ConstantReader? peek(String field);

  /// Whether this constant is a `null` value.
  bool get isNull => true;

  /// Whether this constant represents a `bool` value.
  bool get isBool => false;

  /// Constant as a `bool` value.
  bool get boolValue;

  /// Whether this constant represents an `int` value.
  bool get isInt => false;

  /// Constant as a `int` value.
  int get intValue;

  /// Whether this constant represents a `double` value.
  bool get isDouble => false;

  /// Constant as a `double` value.
  double get doubleValue;

  /// Whether this constant represents a `String` value.
  bool get isString => false;

  /// Constant as a `String` value.
  String get stringValue;

  /// Whether this constant represents a `Symbol` value.
  bool get isSymbol => false;

  /// Constant as a `Symbol` value.
  Symbol get symbolValue;

  /// Whether this constant represents a `Type` value.
  bool get isType => false;

  /// Constant as a [DartType] representing a `Type` value.
  DartType get typeValue;

  /// Whether this constant represents a `Map` value.
  bool get isMap => false;

  /// Constant as a `Map` value.
  Map<DartObject?, DartObject?> get mapValue;

  /// Whether this constant represents a `List` value.
  bool get isList => false;

  /// Constant as a `List` value.
  List<DartObject> get listValue;

  /// Whether this constant represents a `Set` value.
  bool get isSet => false;

  /// Constant as a `Set` value.
  Set<DartObject> get setValue;
}

class _NullConstant extends ConstantReader {
  static Never _throw<T>(String expected) {
    throw FormatException('Not an instance of $expected.');
  }

  const _NullConstant() : super._();

  @override
  DartObject get objectValue => throw UnsupportedError('Null');

  @override
  bool get boolValue => _throw('bool');

  @override
  double get doubleValue => _throw('double');

  @override
  int get intValue => _throw('int');

  @override
  List<DartObject> get listValue => _throw('List');

  @override
  Set<DartObject> get setValue => _throw('Set');

  @override
  Map<DartObject, DartObject> get mapValue => _throw('Map');

  @override
  ConstantReader? peek(_) => null;

  @override
  String get stringValue => _throw('String');

  @override
  Symbol get symbolValue => _throw('Symbol');

  @override
  DartType get typeValue => _throw('Type');
}

class _DartObjectConstant extends ConstantReader {
  @override
  final DartObject objectValue;

  const _DartObjectConstant(this.objectValue) : super._();

  T _check<T>(T? value, String expected) {
    if (value == null) {
      throw FormatException('Not an instance of $expected.', objectValue);
    }
    return value;
  }

  @override
  Object get literalValue =>
      objectValue.toBoolValue() ??
      objectValue.toStringValue() ??
      objectValue.toIntValue() ??
      objectValue.toDoubleValue() ??
      objectValue.toListValue() ??
      objectValue.toSetValue() ??
      objectValue.toMapValue() ??
      Symbol(_check(objectValue.toSymbolValue(), 'literal'));

  @override
  bool get isLiteral =>
      isBool ||
      isString ||
      isInt ||
      isDouble ||
      isList ||
      isMap ||
      isSymbol ||
      isSet ||
      isNull;

  @override
  bool instanceOf(TypeChecker checker) =>
      checker.isAssignableFromType(objectValue.type);

  @override
  bool get isNull => isNullLike(objectValue);

  @override
  bool get isBool => objectValue.toBoolValue() != null;

  @override
  bool get boolValue => _check(objectValue.toBoolValue(), 'bool');

  @override
  bool get isDouble => objectValue.toDoubleValue() != null;

  @override
  double get doubleValue => _check(objectValue.toDoubleValue(), 'double');

  @override
  bool get isInt => objectValue.toIntValue() != null;

  @override
  int get intValue => _check(objectValue.toIntValue(), 'int');

  @override
  bool get isList => objectValue.toListValue() != null;

  @override
  List<DartObject> get listValue => _check(objectValue.toListValue(), 'List');

  @override
  bool get isSet => objectValue.toSetValue() != null;

  @override
  Set<DartObject> get setValue => _check(objectValue.toSetValue(), 'Set');

  @override
  bool get isMap => objectValue.toMapValue() != null;

  @override
  Map<DartObject?, DartObject?> get mapValue =>
      _check(objectValue.toMapValue(), 'Map');

  @override
  bool get isString => objectValue.toStringValue() != null;

  @override
  String get stringValue => _check(objectValue.toStringValue(), 'String');

  @override
  bool get isSymbol => objectValue.toSymbolValue() != null;

  @override
  Symbol get symbolValue =>
      Symbol(_check(objectValue.toSymbolValue(), 'Symbol'));

  @override
  bool get isType => objectValue.toTypeValue() != null;

  @override
  DartType get typeValue => _check(objectValue.toTypeValue(), 'Type');

  @override
  ConstantReader? peek(String field) {
    final constant = ConstantReader(getFieldRecursive(objectValue, field));
    return constant.isNull ? null : constant;
  }

  @override
  String toString() {
    return '_DartObjectConstant{$objectValue}';
  }
}
