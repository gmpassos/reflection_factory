# reflection_factory

[![pub package](https://img.shields.io/pub/v/reflection_factory.svg?logo=dart&logoColor=00b9fc)](https://pub.dev/packages/reflection_factory)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/reflection_factory)](https://app.codecov.io/gh/gmpassos/reflection_factory)
[![CI](https://img.shields.io/github/workflow/status/gmpassos/reflection_factory/Dart%20CI/master?logo=github-actions&logoColor=white)](https://github.com/gmpassos/reflection_factory/actions)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/reflection_factory?logo=git&logoColor=white)](https://github.com/gmpassos/reflection_factory/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/reflection_factory/latest?logo=git&logoColor=white)](https://github.com/gmpassos/reflection_factory/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/reflection_factory?logo=git&logoColor=white)](https://github.com/gmpassos/reflection_factory/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/reflection_factory?logo=github&logoColor=white)](https://github.com/gmpassos/reflection_factory/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/reflection_factory?logo=github&logoColor=white)](https://github.com/gmpassos/reflection_factory)
[![License](https://img.shields.io/github/license/gmpassos/reflection_factory?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/reflection_factory/blob/master/LICENSE)

`reflection_factory` allows Dart reflection using code generation/builder.

## Usage

To enable/generate reflection for some class/type,
you can use two approaches:

- `@EnableReflection()`:

  Annotation that indicates that a specific class/type will have reflection.

- `@ReflectionBridge([User, Profile])`:

  Annotation that indicates through a bridge class
  that the types (`User` and `Profile`) will have reflection.

### @EnableReflection

The annotations `@EnableReflection` is used above your class/type
that you want to have reflection enabled.

File: `some_source_file.dart`:
```dart
import 'package:reflection_factory/reflection_factory.dart';

// Add a reference to the code generated by:
// $> dart run build_runner build
part 'some_source_file.reflection.g.dart';

void main() {
  var user = User('joe@mail.com', '123');

  // The generated reflection:
  var userReflection = user.reflection;

  var fieldEmail = userReflection.field('email')!;
  print('email: ${fieldEmail.get()}');

  var methodCheckPassword = userReflection.method('checkPassword')!;

  var passOk1 = methodCheckPassword.invoke(['wrong']); // false
  print('pass("wrong"): $passOk1');

  var passOk2 = methodCheckPassword.invoke(['123']); // true
  print('pass("123"): $passOk2');

  print('User JSON:');
  print(user.toJson());

  print('User JSON encoded:');
  print(user.toJsonEncoded());
}

// Indicated that reflection for class `User` will be generated/enabled:
@EnableReflection()
class User {
  String? email;

  String pass;

  User(this.email, this.pass);

  bool get hasEmail => email != null;

  bool checkPassword(String pass) {
    return this.pass == pass;
  }
}

```

OUTPUT:

```text
email: joe@mail.com
pass("wrong"): false
pass("123"): true
User JSON:
{email: joe@mail.com, pass: 123, hasEmail: true}
User JSON encoded:
{"email":"joe@mail.com","pass":"123","hasEmail":true}
```

### @ReflectionBridge

The annotations `@ReflectionBridge` is used above a bridge class,
and indicates that third-party types will have reflection generated.

File: `some_source_file.dart`:
```dart

import 'package:reflection_factory/reflection_factory.dart';

// Class `User` is from a third-party package:
import 'package:some_api/user.dart';

// Add a reference to the code generated by:
// $> dart run build_runner build
part 'some_source_file.reflection.g.dart';

// Indicated that reflection for class `User` will be generated/enabled
// through a bridge class:
@ReflectionBridge([User])
class UserReflectionBridge {}

void main() {
  var user = User('joe@mail.com', '123');

  // The generated reflection through bridge class:
  var userReflection = UserReflectionBridge().reflection(user);

  var fieldEmail = userReflection.field('email')!;
  print('email: ${fieldEmail.get()}');

  print('User JSON encoded:');
  print(user.toJsonEncoded());
}

```

OUTPUT:

```text
email: joe@mail.com
User JSON encoded:
{"email":"joe@mail.com","pass":"123","hasEmail":true}
```

## Dependencies

You need to add 2 dependencies in your project:

File: `pubspec.yaml`
```yaml
dependencies:
  reflection_factory: ^1.0.0

dev_dependencies:
  build_runner: ^2.1.1
```

## Building/Generating Code

To generate the reflection code just run `build_runner` in your Dart project:

```bash
$> dart run build_runner build
```

## Source

The official source code is [hosted @ GitHub][github_reflection_factory]:

- https://github.com/gmpassos/reflection_factory

[github_reflection_factory]: https://github.com/gmpassos/reflection_factory

# Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/reflection_factory/issues

# Contribution

Any help from the open-source community is always welcome and needed:

- Found an issue?
    - Please fill a bug report with details.
- Wish a feature?
    - Open a feature request with use cases.
- Are you using and liking the project?
    - Promote the project: create an article, do a post or make a donation.
- Are you a developer?
    - Fix a bug and send a pull request.
    - Implement a new feature.
    - Improve the Unit Tests.
- Have you already helped in any way?
    - **Many thanks from me, the contributors and everybody that uses this project!**

*If you donate 1 hour of your time, you can contribute a lot,
because others will do the same, just be part and start with your 1 hour.*

# Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## License

[Apache License - Version 2.0][apache_license]

[apache_license]: https://www.apache.org/licenses/LICENSE-2.0.txt
