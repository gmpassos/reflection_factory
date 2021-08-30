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
