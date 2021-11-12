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
  - Added `getBestConstructorFor`, that selects the constructor capable to create an instance with provided parameters.
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
  - `methodInvocation(parametersProvider)` now accepts a `ParameterReflection`,
    not only a `String` with the parameter name.

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
