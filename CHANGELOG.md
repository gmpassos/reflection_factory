## 2.5.2

- `JsonCodec` and `JsonEncoder`:
  - Added `encodeToSink`.

## 2.5.1

- `Reflection`:
  - Added `getSymbol`, to allow resolution of `const Symbol` instances.

- `MethodInvocation`:
  - Added field `reflection`.
  - `namedArguments`: use `reflection.getSymbol` to resolve the `const Symbol` for the named parameters keys.

- `ReflectionBuilder`:
  - `_writeGeneratedCode`: `DartFormatter(languageVersion)`.

- dart_style: ^3.0.1

## 2.5.0

- `Constructor`: added `fullName`.

- `ClassTree._buildConstructors`: use as direct constructor name as `constructorAccessor`, reducing generated code.

- sdk: '>=3.6.0 <4.0.0'

- collection: ^1.19.0

- build_runner: ^2.4.15
- lints: ^5.1.1
- test: ^1.25.15

## 2.4.10

- New `InputAnalyzer` and `InputAnalyzerResolved`:
  - Move library, compilation unit and parts resolver code.

- `ReflectionBuilder`:
  - Use `InputAnalyzerResolved`.
  - `_classProxy`: Force class library dependency, and fix cache dependency issue.
  - Check for reflection annotations (AST) before skipping generation if no `part`
    directive is found.

- `ClassReflection`, `EnumReflection`:
  - `compareTo`: compare enumName and className in addition to `reflectionLevel`.

## 2.4.9

- `ReflectionBuilder`:
  - `_buildSiblingsClassReflection`:
    - Also activate `XYZ$reflection()` for imported classes with `@EnableReflection`.

- `_DartTypeExtension`:
  - Added caches for:
    - `isDartCore`, `isTypeWithReflection`, `getTypesWithReflection`.
    - `typeNameResolvable`, `typeName`, `hasSimpleTypeArguments`, `typeNameAsCode`.

- build: ^2.4.2
- dart_style: ^2.3.8
- yaml: ^3.1.3

- build_runner: ^2.4.14
- build_test: ^2.2.3
- pubspec_parse: ^1.5.0
- test: ^1.25.14

## 2.4.8

- `TypeParser`:
  - `_parserForTypeInfo`: handle casting of collections.

- sdk: '>=3.4.0 <4.0.0'

- analyzer: ^6.11.0
- pub_semver: ^2.1.5
- source_span: ^1.10.1
- build_runner: ^2.4.13
- test: ^1.25.12
- coverage: ^1.11.1

## 2.4.7

- `JsonDecoder`:
  - `_fromJsonImpl`: try to parse primitives to `typeInfo` definition (Allow `Map` `String` keys to be parsed as `int`).
  - `_fromJsonMapImpl`: fix for when `typeInfo` is for a `Map<K,V>`.

## 2.4.6

- `TypeInfo`:
  - `isValidGenericType`: fix for `Map`, `MapEntry`, `List` and `Set`.
  - Added `toMapType`, `toMapEntryValueType`, `toMapEntryKeyType`, `toMapEntryType` and `isCastedMapEntry`.

## 2.4.5

- `_TypeWrapperList`, `_TypeWrapperMap`, `_TypeWrapperSet`, `_TypeWrapperIterable`:
  - Improve `parse`, handling generic types of constructed collections.

- analyzer: ^6.8.0
- dart_style: ^2.3.7
- meta: ^1.16.0
- mime: ^1.0.6
- path: ^1.9.1

- data_serializer: ^1.2.1
- coverage: ^1.10.0

## 2.4.4

- 🐛 fix(builder):
  - Use raw strings on class names.
  - `ignore_for_file`: added `deprecated_member_use` and `deprecated_member_use_from_same_package`.

- Change package `pubspec` to `pubspec_parse`.

- pubspec_parse: ^1.3.0

## 2.4.3

- `ClassReflection`: optimize `createInstanceWithConstructors`.

## 2.4.2

- `JsonDecoder`:
  - `decode`: optimize resolution for `T`/`type` `dynamic`/`Object` (any type).

- `JsonConverter` (`JsonEncoder` & `JsonDecoder`):
  - Added `isStandard`.

## 2.4.1

- `JsonEntityCache`:
  - Added `isCachedEntityByID` and `cacheEntityInstantiator`.
  - `JsonEntityCacheSimple`: implement new methods.
  - Added to interface (from `JsonEntityCacheSimple`):
    `cachedEntities`, `allCachedEntities`, `instantiateAllCachedEntities`, `cachedEntitiesLength`,
    `cachedEntitiesInstantiatorsLength`, `totalCachedEntities`.

## 2.4.0

- sdk: '>=3.3.0 <4.0.0'

- analyzer: ^6.5.0
- meta: ^1.15.0
- lints: ^4.0.0
- test: ^1.25.5
- coverage: ^1.8.0

## 2.3.4

- Fix handling og record types with named parameters.
- Fix type argument resolution.

## 2.3.3

- `ClassReflection`:
  - Fix generation of `getJsonFieldsVisibleValues` for getters and setters with `JsonField.hidden` annotations.

## 2.3.2

- `ClassReflection`:
  - Added `getJsonFieldsVisibleValues`

- meta: ^1.14.0
- build_runner: ^2.4.9

## 2.3.1

- `JsonEncoder`:
  - Expose `entityCache`.

- data_serializer: ^1.1.0
- dart_style: ^2.3.6

## 2.3.0

- New `StaticFunctionReflection`.
  - New `StaticMethodReflection`.
  - `ConstructorReflection` extends `StaticFunctionReflection`.
- New `BasicFieldReflection`:
  - New `StaticFieldReflection`.

- `ClassReflection`:
  - Added `getFieldsValues`.

- meta: ^1.12.0
- path: ^1.9.0
- dependency_validator: ^3.2.3

## 2.2.8

- Fix issue with parameter resolution when calling a constructor/method.

- analyzer: ^6.4.1
- mime: ^1.0.5
- build_runner: ^2.4.8
- test: ^1.25.2

## 2.2.7

- Small fix for `Duration` support.

## 2.2.6

- `TypeParser`: added `parseDuration`.
- Json: add support to `Duration`.

- coverage: ^1.7.2
- build_test: ^2.2.2

## 2.2.5

- `TypeInfo`:
  - Fix `castList` for nullable types.

- lints: ^3.0.0
  - Adjust code generation for `type_literal_in_constant_pattern` lint. 

- dart_style: ^2.3.4
- build_runner: ^2.4.7

## 2.2.4

- Added basic support for Records types.
  - Added logic to handle record types and generate typedefs for record declarations.
- Added new tests for Records and generics in `test/reflection_factory_build_test.dart`.

- test: ^1.24.9
- coverage: ^1.6.4
- data_serializer: ^1.0.12

## 2.2.3

- Added `ClassProxy.ignoreMethods2`.

## 2.2.2

- Added `@IgnoreClassProxyMethod`.

## 2.2.1

- `ReflectionBuilder`:
  - Generated files:
    - `ignore_for_file: camel_case_types`
    - `ignore_for_file: camel_case_extensions`

- build: ^2.4.1
- dart_style: ^2.3.2
- collection: ^1.18.0
- build_runner: ^2.4.6
- build_test: ^2.2.0
- data_serializer: ^1.0.10
- test: ^1.24.6

## 2.2.0

- `LibraryReader`: added `allAnnotatedElements`.
- `ReflectionBuilder`
  - Optimize detection of annotated elements. 
  - Fix typos.

- sdk: '>=3.0.0 <4.0.0'
- analyzer: ^6.2.0
- lints: ^2.1.1

## 2.1.6

- New `ClassProxyDelegateListener`.

## 2.1.5

- Optimize `createInstanceWithBestConstructor` and `createInstanceWithConstructors`.

## 2.1.4

- Added `TypeParser.parserForTypeInfo`.
- Optimize `TypeParser.parserFor`.
- Optimize `_TypeWrapper` with specialized implementations for each handled type in `BasicDartType`.
- Optimize `TypeInfo.parse` delegating to specialized `TypeWrapper.parse` implementations.

## 2.1.3

- `TypeInfo`:
  - Fix `castCollection`: redirecting `Map`s to `castMap`.
- sdk: '>=2.19.0 <4.0.0'
- build: ^2.4.0
- analyzer: ^5.13.0
- dart_style: ^2.3.1
- meta: ^1.9.1
- pub_semver: ^2.1.4
- collection: ^1.17.1
- yaml: ^3.1.2
- source_span: ^1.10.0
- test: ^1.24.3

## 2.1.2

- `TypeParser`:
  - Small fixes `parseList`, `parseMap` and `parseMapEntry`.
- `TypeInfo`:
  - Added `callCastedArgumentA` and `callCastedArgumentsAB`.

## 2.1.1

- `TypeInfo`:
  - Added getters `arguments0` and `arguments1`.
  - Added `isCastedList`, `isCastedSet`, `isCastedIterable` and `isCastedMap`.

## 2.1.0

- `EnumReflection` (**Breaking Change**):
  - Now separates fields into `staticFieldsNames` and `fieldsNames`.
- sdk: '>=2.18.0 <3.0.0'
- collection: ^1.17.0

## 2.0.7 

- `TypeInfo`:
  - Fix `isValidGenericType` for `List<T>`.
  - `_fromJsonImpl`: pass `typeInfo` instead of `type`.
- `JsonDecoder`:
  - `_fromJsonListImpl`: fix for `List<List<T>>`.

## 2.0.6

- `TypeParser.parseBool`: improve detected values.
- analyzer: ^5.10.0

## 2.0.5

- `ClassProxy`:
  - Added `returnValue`, `returnFuture` and `returnFutureOr`.
- Added `ClassProxyCallError`.
- analyzer: ^5.8.0
- dart_style: ^2.3.0

## 2.0.4

- `JsonEncoder`:
  - Added `JsonEncoder.callToJson`:
    - Optimized call of `toJson` and avoid `NoSuchMethodError`.
- `TypeInfo`
  - Added static `isPrimitiveTypeFor`
- `TypeParser`:
  - Optimize `isPrimitiveType` and `isPrimitiveValue`.
- `ClassReflection`:
  - Optimize `withObject`.
- `FieldReflection`:
  - Optimize `withObject`.
- `ReflectionBuilder`:
  - Optimize generation of getters that can use static fields:
    - Enums:
      - `fieldsNames`, `valuesByName`
    - Classes:
      - `constructorsNames`, `fieldsNames`, `staticFieldsNames`, `methodsNames`, `staticMethodsNames`.
  - Fix: ensure that reflected annotations are `const`.  
- `analysis_options.yaml`:
  - Added linter rules:
    - `avoid_dynamic_calls`
    - `avoid_type_to_string`
    - `no_runtimeType_toString`
    - `discarded_futures`
    - `no_adjacent_strings_in_list`

## 2.0.3

- `JsonEntityCacheSimple`:
  - Rename `length` to `totalCachedEntites` to avoid implementation issues. 

## 2.0.2

- `ClassReflection`:
  - `getBestConstructorsFor`, `createInstanceWithBestConstructor`, `getBestConstructorForMap`, `getBestConstructorsForMap`:
    - Added parameter `allowOptionalOnlyConstructors`.
  - `createInstanceFromMap`:
    - Improved constructor resolution. 
- `EnableReflection`, `ReflectionBridge`:
  - Added parameter `optimizeReflectionInstances = true`:
    - If `true` all generated `ClassReflection` and `EnumReflection` will have a `factory` constructor and
      an `Expando` to cache reflection instances.
- `FunctionReflection`:
  - `methodInvocationFromMap`: optimize and clean code.
- Added annotation `JsonConstructor`.

## 2.0.1

- `ClassReflection.createInstanceWithBestConstructor`:
  - Now throws `UnresolvedParameterError` instead of `StateError` for unresolved parameters.
- analyzer: ^5.5.0
- test: ^1.23.1
- coverage: ^1.6.3

## 2.0.0

- `ClassReflection`:
  - `constructor`:
    - removed `<R>` type.
  - `field`:
    - Ggenerated implementation declares `T` of `FieldReflection<$class,T>` statically.
  - Optimized:
    - `allFields`, `allMethods`: object instances derived from cached `no-object` instances.
    - `construtor`, `staticField`, `field`, `method`:
      - Caching instances.
      - Object instances derived from cached `no-object` instances.
- `FieldReflection`:
  - Added `setNullable`.
- benchmark: ^0.3.0
  - `benchmark/reflection_factory_benchmark.dart`
- meta: ^1.9.0

## 1.2.25

- Extra fix: issue when a source has a `part of` directive.

## 1.2.24

- Fix issue when a source has a `part of` directive.

## 1.2.23

- `ReflectionBuilder`
  - New `sequential` and `buildStepTimeout`.
  - Build now is sequential by default:
    - Only one `BuildStep` is processed at a time.
    - Avoid `InconsistentAnalysisException` (`build` issue #2689).
- Added `build.yaml` options (`verbose`,`sequential`, `timeout`).
- Improved logging.
- Added `ClassProxy` test using `libraryPath`.
- `reflection_factory/build.yaml`:
  - `generate_for`:
    - Added `bin/*`

## 1.2.22

- Attempt to avoid `build` issue:
  - `InconsistentAnalysisException: Requested result might be inconsistent with previously returned results` #2689
  - https://github.com/dart-lang/build/issues/2689
- mime: ^1.0.4
- build_test: ^2.1.6
- test: ^1.22.2
- coverage: ^1.6.2

## 1.2.21

- `ClassReflection`:
  - Fix generated `supperTypes`.

## 1.2.20

- Migrate to `analyzer: ^5.4.0`.
- analyzer: ^5.4.0

## 1.2.19

- `TypeInfo`:
  - Added `isPrimitiveOrDynamicOrObjectType` and `isEntityType`.
- Fix `castMapType` for `Map<String,dynamic>`.

## 1.2.18

- `Reflection`:
  - Fix `castMap`:
  - Added `castMapKeys` and `castMapValues`.
  - Added getters: `asTypeReflection`, `typeInfo`, `listType`, `mapKeyType` and `mapValueType`.
- `JsonCodec`:
  - Added field `mapCaster`.
- `_JsonDecoder`:
  - Now supports `Map` casting when decoding an entity field.
- Added `castMapType`.
- `ReflectionBuilder`:
  - Optimize and reduce generated code.
- build: ^2.3.1
- analyzer: ^4.7.0
- dart_style: ^2.2.4
- mime: ^1.0.3
- pub_semver: ^2.1.3
- path: ^1.8.3
- build_runner: ^2.3.3
- lints: ^2.0.1
- test: ^1.22.1
- coverage: ^1.6.1

## 1.2.17

- `FunctionReflection.parametersNamesWhere`:
  - Added parameter `nameResolver`.
- `ClassReflection.getBestConstructorsFor`:
  - Improve parameter/field JSON name alias (`JsonFieldAlias`) resolution.

## 1.2.16

- `ClassReflection`:
  - Added `fieldsWithJsonFieldHidden`, `fieldsWithJsonFieldVisible`, `hasJsonFieldHidden` and `hasJsonFieldVisible`.
  - Added `entityFields` and `entityFieldsNamesWhere`.
  - Added `getBestConstructorsFor`.
  - `getBestConstructorFor`: using multiple contructor candidates.

## 1.2.15

- `JsonTypeDecoder`: added parameter `TypeInfo typeInfo`.
- `JsonDecoder`:
  - Added `unregisterTypeDecoder`
  - Allow decoding of `null` values with personalized `JsonTypeDecoder`.
- Added `ClassReflection.createInstanceWithConstructorByName`.

## 1.2.14

- `FunctionReflection.methodInvocation`:
  - Function `parameterProvider`:
    - Add `parameterIndex` to indicate the order of the parameter in the method.  

## 1.2.13

- Json:
  - Add parameter `TypeInfo` as an alternative to the parameter `Type`.
  - Improve collections casting.
- `TypeInfo`:
  - Added constructors: `TypeInfo.fromListType`, `TypeInfo.fromSetType`, `TypeInfo.fromMapType`.
  - Added `toListType`, `toSetType`, `toIterableType`, `toMapValueType` and `toMapKeyType`.
  - Added `castList`, `castSet`, `castIterable` and `castMap`.

## 1.2.12

- `ClassReflection` added field `className`.
- `EnumReflection` added field `enumName`.

## 1.2.11

- `ClassProxy`:
  - Optimize `@ClassProxy` classes resolution speed.
  - Added `ClassProxy` test with `libraryPath` parameter.
- `README.md`:
  - Added `part` directive description.
  - Added `@ClassProxy` example.
- Added tests for `JsonEntityCacheSimple`.

## 1.2.10

- Small fix in `TypeInfo.toString`: was not passing the parameter `withT` to recursive calls. 

## 1.2.9

- `ReflectionFactory`:
  - Added `getRegisterClassReflectionByName` and `getRegisterEnumReflectionByName`.
- `JsonTypeDecoder`: added parameter `jsonDecoder`.

## 1.2.8

- `FunctionReflection.methodInvocationFromMap` and `FunctionReflection.methodInvocation`:
  - Better handling of unresolved parameters values.
    Attempts to resolve 2 times, to allow entities references through cache.
- `Reflection`:
  - `castList`, `castSet`, `castIterable`, `castMap`, `castCollection`:
    - Added parameter `nullable`.

## 1.2.7

- `TypeInfo`:
  - Added `T` generic type.
  - Added `callCasted` to pass the `T` to a `Function<T>()`.
  - Improved internal representation og `arguments`.
- `ReflectionBuilder`:
  - Declare reflected types using `TypeInfo<T>` generics.
- Improved tests coverage.

## 1.2.6

- Add `coverage:ignore-file` to generated files.
- analyzer: ^4.6.0

## 1.2.5

- `Json`:
  - `toJson`: fix casting bug when the resulting JSON value is `null`.
- Removed unused analyzer helper code.
- Adjusted for analyzer 4.4.0.
- sdk: '>=2.17.0 <3.0.0'
- analyzer: ^4.4.0

## 1.2.4

- `TypeParser` and `TypeInfo`:
  - Add support for `Uint8List`.

## 1.2.3

- `JsonEntityCache`:
  - Added instance `id`.
  - Added `allowEntityFetch`.
- `TypeInfo`:
  - Added `equalsTypeAndArguments`.
- `TypeReflection`:
  - Added `isBigInt`.
  - `isNumericType` renamed to `isNumberType`.
  - Added `isNumericType` (`isNumericType` + `isBigInt`).
- Added extension `TypeExtension`:
  - method `isPrimitiveType`.
- Added extension `GenericObjectExtension`:
  - `isPrimitiveValue`, `isPrimitiveList`, `isPrimitiveMap`.

## 1.2.2

- `ReflectionInspector`:
  - Fix inspection for generated files in the subdirectory `reflection`.

## 1.2.1

- Fix use of deprecated methods of package `analyzer`.
- build: ^2.3.0
- analyzer: ^4.3.0
- pub_semver: ^2.1.1
- yaml: ^3.1.1
- source_span: ^1.9.1
- build_runner: ^2.2.0
- build_test: ^2.1.5
- pubspec: ^2.3.0
- data_serializer: ^1.0.7
- dependency_validator: ^3.2.2
- test: ^1.21.4
- coverage: ^1.5.0

## 1.2.0

- sdk: '>=2.15.0 <3.0.0'
- analyzer: ^4.1.0
- meta: ^1.8.0
- path: ^1.8.2
- build_runner: ^2.1.11
- lints: ^2.0.0
- pubspec: ^2.2.0
- test: ^1.21.2
- coverage: ^1.3.2

## 1.1.2

- `ClassProxy`.
  - Allow type parameters in generated proxy methods. 

## 1.1.1

- `TypeInfo`:
  - Fix `fromJson` when decoding a list with a graph containing duplicated entities (referenced by ID).
  - Added support for `FutureOr`.
- `JsonCoder`/`JsonEncoder`/`JsonDecoder`:
  - Allow override of `autoResetEntityCache` while encoding or decoding. 
- Improved GitHub CI: added browser tests (chrome).
- mime: ^1.0.2
- analyzer: ^3.4.1
- dart_style: ^2.2.3

## 1.1.0

- Changed possible generated reflection file path. Now it can generate: 
  - Inside the directory: `reflection/{{file}}.g.dart`
  - Or as a sibling file `{{file}}.reflection.g.dart` 
- Added warning of absent `part` directive for the generated reflection file.

## 1.0.29

- `ClassReflection`:
  - Add parameter `duplicatedEntitiesAsID` to JSON related methods. 

## 1.0.28

- Fix `createInstanceFromMap` when there's no constructor without arguments.
- New annotation `JsonFieldAlias`.

## 1.0.27

- Fix JSON `DateTime` parsing when encoded as an `int`.
- JSON encoder/decoder can reference already encoded entities by ID through `JsonEntityCache`.

## 1.0.26

- Fix `ClassProxy.ignoreParametersTypes`.

## 1.0.25

- `ClassProxy`: added `ignoreParametersTypes`.

## 1.0.24

- `ClassProxy`:
    - Fix proxy generation for methods that returns `FutureOr`.
- `ClassReflection`:
    - Optimize `createInstanceWithBestConstructor` and `getBestConstructorForMap`.
- source_span: ^1.8.2
- path: ^1.8.1
- collection: ^1.16.0
- build: ^2.2.1
- analyzer: ^3.3.1
- dart_style: ^2.2.1

## 1.0.23

- `ClassProxy`:
    - Fix target class resolution issue. Added `libraryPath`.
    - Added extra configuration: `alwaysReturnFuture`,`traverseReturnTypes`, `ignoreMethods`.
- Improve `JsonEncoder` and `JsonDecoder`:
    - Added `registerTypeToEncodable` and `registerTypeDecoder`.

## 1.0.22

- Added `ClassProxy`:
    - Allows generation of a class proxy without directly depending on the target class.

## 1.0.21

- Improve JSON codec customization.
- Improve `createInstanceWithBestConstructor`.

## 1.0.20

- Added `TypeInfo` to perform type checking and handle other `Type` operations needed for reflection use.
- Improved `TypeReflection` for `Function` types.
- Fixed constructors with nullable named parameters.
- Fixed constructors with `required` named parameters.
- Fixed fields/parameters with `Function` `typedef` alias.

## 1.0.19

- Fix small bug at `createInstanceFromMap` for field resolution.

## 1.0.18

- `EnumReflection`: added `enumName` to extension.
- Fix `siblingEnumReflectionFor` and `siblingEnumReflectionFor`.

## 1.0.17

- JSON
    - Better JSON handling and reflection integration.
    - Encoding/decoding to/from bytes (`Uint8List`).
    - `@JsonField`: to hide a field or to force it as a json field.
- Added support for enums: `EnumReflection`
- `ClassReflection`:
    - Support for supper classes.
    - Added `createInstanceWithNoRequiredArgsConstructor` as another way to create an instance without arguments.
    - Added `getBestConstructorFor`, that selects the constructor capable to create an instance with provided
      parameters.
    - Added `fromJson` and `fromJsonEncoded`.
    - Added `createInstanceWithBestConstructor` and `createInstanceFromMap`.
    - Added `declaringType`.
- Generating `ClassFoo$fromJson` and `ClassFoo$fromJsonEncoded`.
- Optimized some operations.
- Fixed `TypeReflection` for `Function`.
- mime: ^1.0.1
- base_codecs: ^1.0.1

## 1.0.16

- `ClassReflection`:
    - `withoutObjectInstance`: now always returns the same instance.
    - Added `reflectionFactoryVersion`.

## 1.0.15

- `ClassReflection`: added `callCasted`.
- `ReflectionInspector`: now checks if a generated file version is the same of the `reflection_factory` package.

## 1.0.14

- `ClassReflection`:
    - Added `siblingsClassReflection` and `withoutObjectInstance`.
    - `register` now triggers registration of all sibling `ClassReflection`.
- Using standard Dart coverage.
- coverage: ^1.0.3

## 1.0.13

- Allow call to `field` without an object. Useful to get the field type before instantiate an object.

## 1.0.12

- `FieldReflection`: added `hasSetter`.

## 1.0.11

- Added support to default values of optional and named parameters.

## 1.0.10

- Removed `BUILD TIME` comment in generated files to avoid unnecessary generate file modification/change.

## 1.0.9

- Added `ReflectionInspector`.
- Generated files now have the package version in the header comments.
- `toJsonEncodable`: fixed handling of `DateTime`.
- Improved tests.

## 1.0.8

- Improve tests.
- Fix issue with genetic types.

## 1.0.7

- `TypeReflection`:
    - Added `isOfType`.
- `FunctionReflection` (`MethodReflection`, `ConstructorReflection`):
    - `methodInvocation(parametersProvider)` now accepts a `ParameterReflection`, not only a `String` with the parameter
      name.

## 1.0.6

- `ClassReflection`:
    - Added: `fieldsWhere`, `staticFieldsWhere`, `methodsWhere`, `staticMethodsWhere`.
- `TypeReflection`:
- Added: `isPrimitiveType`, `isCollectionType`, `isMapType`, `isIterableType`,
  `isNumericType`, `isIntType`, `isDoubleType`, `isBoolType`, `isStringType`.

## 1.0.5

- Added support for class constructors.
- Added `TypeReflection`:
    - Allows handling of Type generics/arguments.
- Added extensions:
    - `IterableTypeReflectionExtension`, `IterableParameterReflectionExtension`, `IterableFieldReflectionExtension`.

## 1.0.4

- Added `ElementResolver`:
- `ClassReflection`:
    - Added resolvers:
      `fieldResolver`, `staticFieldResolver`, `methodResolver`, `staticMethodResolver`.
    - Optimized `toJson` to resolve faster `MethodReflection` of `obj.toJson`.
- Changed `FieldReflection` to allow `withObject`.
- Changed `MethodReflection` to allow `withObject`.
- Added `ReflectionFactory.toJsonEncodable`.
- Improve API Documentation.
- Fix issue with operator overloading.

## 1.0.3

- Annotation reflection:
    - Support for classes, fields, methods and method parameters.

## 1.0.2

- `ClassReflection`:
    - Added: `allMethods`, `allStaticMethods`
- `MethodReflection`:
    - Methods parameters now are defined with `ParameterReflection`.
    - `returnType`: fixed for `void`.
    - `method`: exposed, not private anymore.
    - Added:
        - `equalsNormalParametersTypes`, `equalsOptionalParametersTypes`, `equalsNamedParametersTypes`.
        - `methodInvocation`, `methodInvocationFromMap`.
- `MethodInvocation`: class to represent an invocation.
- Builder:
    - Now generates documentation of generated extension methods.
    - Better handling of parameters and fields with `ParameterReflection`.
        - Now knows if a parameter is `required`.
- Improved API documentation.
- Improved tests.
- collection: ^1.15.0

## 1.0.1

- @EnableReflection:
    - Added `reflectionClassName`, `reflectionExtensionName`.
- @ReflectionBridge:
    - Added `bridgeExtensionName`, `reflectionClassNames`, `reflectionExtensionNames`.
- Builder:
    - `MethodReflection`:
        - Added method parameters names to normal and optional parameters.
    - Optimize generated code.
    - Improved console output and verbose mode.
- Improved tests.

## 1.0.0

- Support for Class reflection:
    - FieldReflection
    - MethodReflection
- Initial version.
