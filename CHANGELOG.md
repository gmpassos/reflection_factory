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
