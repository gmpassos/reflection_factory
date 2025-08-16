import 'package:benchmark/benchmark.dart';
import 'package:reflection_factory/builder.dart';

import '../test/src/user_with_reflection.dart';

void main() {
  group('reflection.%elements', () {
    late ClassReflection<TestUserWithReflection> reflection;
    late TestUserWithReflection user;
    late ClassReflection<TestUserWithReflection> userReflection;

    setUpEach(() {
      reflection = TestUserWithReflection$reflection();
      var c = reflection.constructor('fields');
      user = c!.invoke(['Joe', 'joe@mail.com', 'pass123']);
      userReflection = user.reflection;

      reflection.staticField('version');
      reflection.staticMethod('isVersion');
      reflection.method('checkPassword');
      reflection.field('name');
    });

    benchmark(
      'reflection.constructor',
      () {
        reflection.constructor('fields')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'userReflection.constructor',
      () {
        userReflection.constructor('fields')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'reflection.staticField',
      () {
        reflection.staticField('version')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'reflection.staticMethod',
      () {
        reflection.staticMethod('isVersion')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'reflection.method',
      () {
        userReflection.method('checkPassword')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'userReflection.method',
      () {
        userReflection.method('checkPassword')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'reflection.field',
      () {
        reflection.field('name')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'userReflection.field',
      () {
        userReflection.field('name')!;
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );
  });

  group('reflection.toJson', () {
    late ClassReflection<TestUserWithReflection> reflection;
    late TestUserWithReflection user;
    late ClassReflection<TestUserWithReflection> userReflection;

    setUpEach(() {
      reflection = TestUserWithReflection$reflection();
      var c = reflection.constructor('fields');
      user = c!.invoke(['Joe', 'joe@mail.com', 'pass123']);
      userReflection = user.reflection;

      reflection.staticField('version');
      reflection.staticMethod('isVersion');
      reflection.method('checkPassword');
      reflection.field('name');
    });

    benchmark(
      'reflection.toJson',
      () {
        reflection.toJson(user);
      },
      iterations: 10,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'userReflection.toJson',
      () {
        userReflection.toJson();
      },
      iterations: 10,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'user.toJson',
      () {
        user.toJson();
      },
      iterations: 10,
      duration: Duration(seconds: 5),
    );
  });

  group('reflection.fromJson', () {
    late ClassReflection<TestFranchiseWithReflection> reflection;
    late TestFranchiseWithReflection franchise;
    late ClassReflection<TestFranchiseWithReflection> franchiseReflection;
    late Object? franchiseJson;

    setUpEach(() {
      reflection = TestFranchiseWithReflection$reflection();

      var c = reflection.constructor('');
      franchise = c!.invoke([
        'CorpX',
        {
          'a': TestAddressWithReflection.withCity('ST', city: 'city1', id: 101),
          'b': TestAddressWithReflection.simple('ST', id: 102),
          'c': TestAddressWithReflection.withCity('ST', city: 'city2', id: 103),
        },
      ]);

      franchiseReflection = franchise.reflection;
      franchiseJson = reflection.toJson(franchise);
    });

    benchmark(
      'reflection.toJson',
      () {
        reflection.fromJson(franchiseJson);
      },
      iterations: 10,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'userReflection.toJson',
      () {
        franchiseReflection.fromJson(franchiseJson);
      },
      iterations: 10,
      duration: Duration(seconds: 5),
    );
  });
}
