import 'package:benchmark/benchmark.dart';
import 'package:reflection_factory/builder.dart';

import '../test/src/instantiate_fixture.dart';
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

  group('reflection.createInstanceFromMap', () {
    late ClassReflection<TestAccountWithReflection> accountReflection;
    late ClassReflection<TestMemberWithReflection> memberReflection;

    final createdAt = DateTime.utc(2026, 1, 2, 3, 4, 5);

    final accountMap = <String, Object?>{
      'id': 101,
      'name': 'Joe',
      'email': 'joe@mail.com',
      'phone': '+1 555 0101',
      'age': 33,
      'score': 9.5,
      'active': true,
      'createdAt': createdAt,
    };

    final memberMap = <String, Object?>{
      'id': 102,
      'name': 'Ann',
      'email': 'ann@mail.com',
      'passwordHash': 'hash:abc',
      'age': 41,
      'score': 7.25,
      'active': false,
      'createdAt': createdAt,
    };

    setUpEach(() {
      accountReflection = TestAccountWithReflection$reflection();
      memberReflection = TestMemberWithReflection$reflection();
    });

    benchmark(
      'account (constructor)',
      () {
        accountReflection.createInstanceFromMap(accountMap);
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'member (create + setters)',
      () {
        memberReflection.createInstanceFromMap(memberMap);
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'account (constructor; valuesResolved, exactKeys)',
      () {
        accountReflection.createInstanceFromMap(
          accountMap,
          valuesResolved: true,
          exactKeys: true,
        );
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );

    benchmark(
      'member (create + setters; valuesResolved, exactKeys)',
      () {
        memberReflection.createInstanceFromMap(
          memberMap,
          valuesResolved: true,
          exactKeys: true,
        );
      },
      iterations: 1000000,
      duration: Duration(seconds: 5),
    );
  });
}
