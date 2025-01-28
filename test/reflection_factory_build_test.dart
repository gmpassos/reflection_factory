@TestOn('vm')
@Tags(['build', 'slow'])
library;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:reflection_factory/builder.dart';
import 'package:reflection_factory/src/reflection_factory_builder.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    // Increment this after each test so the next test has it's own package
    _pkgCacheCount++;
  });

  group('ReflectionBuilder', () {
    setUp(() {});

    test('EnableReflection: TestEmpty', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class TestEmpty {}
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains(
                  "Version _version = Version.parse('${ReflectionFactory.VERSION}')"),
            ),
            allOf(
              contains('TestEmpty\$reflection'),
              contains('TestEmpty\$reflectionExtension'),
              isNot(contains(
                  "Map<String, dynamic> getJsonFieldsVisibleValues(TestEmpty? obj,")),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: TestEmpty', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class \$TestSpecial {}
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains(
                  "Version _version = Version.parse('${ReflectionFactory.VERSION}')"),
            ),
            allOf(
              contains('\$TestSpecial\$reflection'),
              contains('\$TestSpecial\$reflectionExtension'),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: User', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          enum Axis {
            x, y, z;
            
            String get nameLC => name.toLowerCase();
            static int get length => values.length;
          }
          
          @EnableReflection()
          class User {
            @TestAnnotation(['static field', 'version'])
            static final double version = 1.0; 
            
            @TestAnnotation(['static method', 'version checker'])
            static bool isVersion(double ver, [double tolerance = 0.0]) => version == ver;
            
            @TestAnnotation(['field', 'email'])
            String? email ;
            @JsonField.hidden()
            String pass ;
            @JsonField.visible()
            bool enabled ;
            
            User(this.email, {required this.pass, this.enabled = true});
            
            @TestAnnotation(['field', 'eMail'])
            String? get eMail => email;
            
            bool get hasEmail => email != null;
            
            @TestAnnotation(['method', 'password checker'])
            bool checkPassword(
            @TestAnnotation(['parameter', 'pass'])
            String pass, {bool ignoreCase = false}) {
              if (ignoreCase) {
                return  this.pass.toLowerCase() == pass.toLowerCase();
              } else {
                return  this.pass == pass;
              } 
            }
            
            Map<String, dynamic> toJson() => {
              'email': email,
              'pass': pass,
            };
              
            V? getField<V extends Object>(String key, [V? def]) {
              switch (key) {
                case 'email':
                  return email as V?;
                case 'password':
                  return password as V?;
                default:
                  return null;
              }
            }
            
            void setField<V>(String key, V? value) {
              switch (key) {
                case 'email':
                  { email = value as String? ; break;}
                case 'password':
                  { password = value as String ; break;}
                default:
                  return;
              }
            }
            
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains(
                  "Version _version = Version.parse('${ReflectionFactory.VERSION}')"),
            ),
            allOf(
              contains('User\$reflection'),
              contains('User\$reflectionExtension'),
            ),
            matches(RegExp(
                r"'ignoreCase':\s*__PR\(\s*__TR.tBool\s*,\s*'ignoreCase'\s*,\s*false\s*,\s*false\s*,\s*false\s*\)")),
            allOf(
              contains("TestAnnotation(['static method', 'version checker'])"),
              contains("TestAnnotation(['method', 'password checker'])"),
              contains("TestAnnotation(['static field', 'version'])"),
              contains("TestAnnotation(['field', 'email'])"),
              contains("TestAnnotation(['parameter', 'pass'])"),
              isNot(matches(RegExp(
                  r'Object\?\s+toJson\(.*?\)\s+=>\s+reflection.toJson\('))),
              matches(RegExp(
                  r'Map<String, dynamic>\?\s+toJsonMap\(\{bool duplicatedEntitiesAsID = false\}\)\s+=>\s+reflection.toJsonMap\(duplicatedEntitiesAsID: duplicatedEntitiesAsID\)')),
            ),
            allOf(
              contains("JsonField.hidden()"),
              contains("JsonField.visible()"),
              contains(
                  "Map<String, dynamic> getJsonFieldsVisibleValues(User? obj,"),
              contains("case 'tojson':"),
              contains("case 'getfield':"),
              contains("case 'setfield':"),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: Domain', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'reflection/foo.g.dart';
          
          typedef Fx = bool Function(int x);
          
          @EnableReflection()
          class Domain {
            final String name;
            final String suffix;
          
            final Fx? fx;
            final bool Function()? extra;
          
            Domain.positional(this.name, this.suffix, [this.fx, this.extra]);
          
            Domain.named({required this.name, this.suffix = 'net', Fx? fx, this.extra}) : fx = fx;
            
            Domain.empty() : this('', '');
            
            Domain() : this('', '');
            
            bool callFx(int n, [Fx? f]) {
              f ??= fx ;
              return f(n);
            }
            
            bool callAllFx(int n, List<Fx> fxs) {
              for (var f in fxs) {
                f(n);
              }
            }
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/reflection/foo.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of '../foo.dart'"),
            ),
            allOf(
              contains('Domain\$reflection'),
              contains('Domain\$reflectionExtension'),
            ),
            allOf(
              contains('bool get hasDefaultConstructor => true;'),
              contains(
                  'Domain? createInstanceWithDefaultConstructor() => Domain();'),
              contains('bool get hasEmptyConstructor => true;'),
              contains(
                  'Domain? createInstanceWithEmptyConstructor() => Domain.empty();'),
              contains('bool get hasNoRequiredArgsConstructor => true;'),
              contains(
                  'Domain? createInstanceWithNoRequiredArgsConstructor() => Domain.empty();'),
            ),
            matches(RegExp(
                r"'suffix':\s*__PR\(\s*__TR.tString\s*,\s*'suffix'\s*,\s*false\s*,\s*false\s*,\s*'net'\s*\)")),
            allOf(
                matches(RegExp(
                    r"case 'callfx':.*?const <__PR>\[\s*__PR\(\s*__TR<Fx>\(Fx\), 'f', true, false\)\s*\]",
                    dotAll: true)),
                matches(RegExp(
                    r"case 'callallfx':.*?__PR\(\s*__TR<List<Function>>\(\s*List, <__TI>\[__TI.tFunction\]\),\s*'fxs',\s*false,\s*true\)",
                    dotAll: true)),
                matches(RegExp(
                    r'Object\?\s+toJson\(.*?\)\s+=>\s+reflection.toJson\(')),
                matches(RegExp(
                    r'Object\?\s+toJson\(\{bool duplicatedEntitiesAsID = false\}\)\s+=>\s+reflection.toJson\(null, null, duplicatedEntitiesAsID\)')),
                matches(RegExp(
                    r'Map<String, dynamic>\?\s+toJsonMap\(\{bool duplicatedEntitiesAsID = false\}\)\s+=>\s+reflection.toJsonMap\(duplicatedEntitiesAsID: duplicatedEntitiesAsID\)'))),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: [no part error]', tags: ['error'], () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
          
          @EnableReflection()
          class Domain {
            final String name;
            final String suffix;
            
            Domain(this.name, this.suffix);
            
            bool equalsName(String name) => this.name == name;
          }
        
        '''
      };

      var packageAssetReader = await PackageAssetReader.currentIsolate();

      expectLater(
          () => testBuilder(
                builder,
                sourceAssets,
                reader: packageAssetReader,
                generateFor: {'$_pkgName|lib/foo.dart'},
                onLog: (msg) {
                  print(msg);
                },
              ),
          throwsA(isA<StateError>().having((e) => e.message,
              'NO part directive', contains('NO reflection part directive '))));
    });

    test('EnableReflection[super class]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          mixin WithType {
            String get type ;
          }
          
          @EnableReflection()
          abstract class Op with WithType {
            @override
            final String type;
            
            Op(this.type);
            
            List<Set<int>> opMethod() => <Set<int>>[{1},{2}] ;
            
            List<Set<int?>> opMethodNullable() => <Set<int?>>[{1},{2,null}] ;
          }
          
          @EnableReflection()
          class OpA extends Op {
            int value;
            OpA(this.value) : super('a');
            
            Set<List<T>> opAMethod<T>() => <List<T>>{<T>[]};
          }
          
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              contains('Op\$reflection'),
              contains('Op\$reflectionExtension'),
              contains('OpA\$reflection'),
              contains('OpA\$reflectionExtension'),
            ]),
            allOf(
              matches(RegExp(
                  r'Object\?\s+toJson\(.*?\)\s+=>\s+reflection.toJson\(')),
              matches(RegExp(
                  r'Map<String, dynamic>\?\s+toJsonMap\(.*?\)\s+=>\s+reflection.toJsonMap\(')),
            ),
            allOf(
              contains("case 'type':"),
              contains("case 'value':"),
              contains("_fieldsNames = const <String>['type', 'value']"),
              contains("_supperTypes = const <Type>[Op, WithType];"),
              matches(RegExp(
                  r"__TR<List<Set<int>>>\(\s*List, <__TR>\[__TR.tSetInt\]\)")),
              matches(RegExp(
                  r"__TR<List<Set<int\?>>>\(\s*List, <__TR>\[__TR.tSetInt\]\)")),
              matches(RegExp(
                  r"__TR<Set<List>>\(\s*Set, <__TR>\[__TR.tListDynamic\]\)")),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: records', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class User {
            
            String? email ;
            String pass ;
            
            User(this.email, {required this.pass});
            
            (bool,String?) checkPassword(String pass, {bool ignoreCase = false}) {
              var ok = ignoreCase ? this.pass.toLowerCase() == pass.toLowerCase() : this.pass == pass ;
              var error = ok ? null : 'Invalid password';
              return (ok,  error);
            }
            
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains(
                  "Version _version = Version.parse('${ReflectionFactory.VERSION}')"),
            ),
            allOf(
              contains('User\$reflection'),
              contains('User\$reflectionExtension'),
            ),
            matches(RegExp(
                r"'ignoreCase':\s*__PR\(\s*__TR.tBool\s*,\s*'ignoreCase'\s*,\s*false\s*,\s*false\s*,\s*false\s*\)")),
            allOf(
              matches(RegExp(r"typedef __RCD1 = \(bool, String\?\);")),
              matches(
                  RegExp(r"MethodReflection<User,\s+\(bool, String\?\)>\(")),
              matches(RegExp(r"'checkPassword',\s+__TR<__RCD1>\(__RCD1\),")),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: records+generics', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          class BaseA {}
          
          class Info<A,B> {
            final A a;
            final B b;
            
            Info(this.a, this.b);
          }
          
          @EnableReflection()
          class User<T extends BaseA> {
            
            String? email ;
            String pass ;
            
            User(this.email, {required this.pass});
            
            (T,Info<T,B>) base1(T a) {
              return (a, Info(a,b) );
            }
            
            T base2(T a) {
              return a;
            }
            
            (A,Info<A,B>) info<A extends BaseA,B>(A a, B b) {
              return (a, Info(a,b) );
            }
            
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains(
                  "Version _version = Version.parse('${ReflectionFactory.VERSION}')"),
            ),
            allOf(
              contains('User\$reflection'),
              contains('User\$reflectionExtension'),
            ),
            allOf(
              matches(RegExp(r"typedef\s+__RCD1\s+=\s+\(dynamic,\s+Info\);")),
              matches(RegExp(
                  r"case\s+'base1':\s+return\s+MethodReflection<User,\s+\(dynamic,\s+Info\)>\(")),
              matches(RegExp(
                  r"case\s+'base2':\s+return\s+MethodReflection<User,\s+dynamic>\(")),
              matches(RegExp(
                  r"case\s+'info':\s+return\s+MethodReflection<User,\s+\(dynamic,\s+Info\)>\(")),
              matches(RegExp(r"__TR<__RCD1>\(__RCD1\),")),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection: records (named)', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class Validator {
          
            ({bool ok, String? error}) validate() => (ok: true, error: null);
          
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains(
                  "Version _version = Version.parse('${ReflectionFactory.VERSION}')"),
            ),
            allOf(
              contains('Validator\$reflection'),
              contains('Validator\$reflectionExtension'),
              contains("typedef __RCD1 = ({String? error, bool ok});"),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection(reflectionClassName, reflectionExtensionName)',
        () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection(reflectionClassName: 'RefUser', reflectionExtensionName: 'RefUserExt')
          class User {
            static final double version = 1.0; 
            
            static bool isVersion(double ver) => version == ver;
            
            String? email ;
            String pass ;
            
            User(this.email, this.pass);
            
            String? get eMail => email;
            
            bool get hasEmail => email != null;
            
            bool checkPassword(String pass) {
              return this.pass == pass;
            }
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
            contains("part of 'foo.dart'"),
            contains('RefUser'),
            contains('RefUserExt'),
            matches(
                RegExp(r'Object\?\s+toJson\(.*?\)\s+=>\s+reflection.toJson\(')),
            matches(RegExp(
                r'Map<String, dynamic>\?\s+toJsonMap\(.*?\)\s+=>\s+reflection.toJsonMap\(')),
          ))
        },
        onLog: (msg) {
          print(msg);
        },
        //packageConfig: packageConfig,
      );
    });

    test('EnableReflection + source with part file', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo_extra.dart': '''

          part of 'foo.dart';

          @EnableReflection()
          class FooExtra extends Foo {
            int c ;

            FooExtra(super.a, super.b, this.c);
          }

        ''',
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          part 'foo_extra.dart';
          
          @EnableReflection()
          class Foo {
            int a ;
            int b ;
            Foo(this.a, this.b);
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart', '$_pkgName|lib/foo_extra.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
            contains("part of 'foo.dart'"),
            contains('Foo\$reflection'),
            contains('FooExtra\$reflection'),
          ))
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection[optimizeReflectionInstances: true]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection(optimizeReflectionInstances: true)
          enum Status {a,b}
          
          @EnableReflection(optimizeReflectionInstances: true)
          class Foo {
            int n;
            Status s;
            Foo(this.n, {this.status = Status.a});
          }

        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              contains('Status\$reflection'),
              contains('Status\$reflectionExtension'),
              contains('Foo\$reflection'),
              contains('Foo\$reflectionExtension'),
            ]),
            allOf([
              contains('final Expando<Status\$reflection> _objectReflections'),
              contains('factory Status\$reflection([Status? object]) {'),
              contains('final Expando<Foo\$reflection> _objectReflections'),
              contains('factory Foo\$reflection([Foo? object]) {'),
            ]),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection[optimizeReflectionInstances: false]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection(optimizeReflectionInstances: false)
          enum Status {a,b}
          
          @EnableReflection(optimizeReflectionInstances: false)
          class Foo {
            int n;
            Status s;
            Foo(this.n, {this.status = Status.a});
          }

        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              contains('Status\$reflection'),
              contains('Status\$reflectionExtension'),
              contains('Foo\$reflection'),
              contains('Foo\$reflectionExtension'),
            ]),
            isNot(anyOf([
              contains('final Expando<Status\$reflection> _objectReflections'),
              contains('factory Status\$reflection([Status? object]) {'),
              contains('final Expando<Foo\$reflection> _objectReflections'),
              contains('factory Foo\$reflection([Foo? object]) {'),
              isNot(contains('// Dependency reflections:')),
            ])),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection + import [2 source files]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/status.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'status.reflection.g.dart';
          
          @EnableReflection()
          enum Status {a,b}
          
        ''',
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
          
          import './status.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class Foo {
            int n;
            Status s;
            Foo(this.n, {this.status = Status.a});
          }
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/status.dart', '$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/status.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'status.dart'"),
            ),
            allOf([
              contains('Status\$reflection extends'),
              contains('Status\$reflectionExtension'),
              isNot(contains('Foo\$reflection extends')),
              isNot(contains('Foo\$reflectionExtension')),
            ]),
            allOf([
              contains('final Expando<Status\$reflection> _objectReflections'),
              contains('factory Status\$reflection([Status? object]) {'),
            ]),
          )),
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              isNot(contains('Status\$reflection extends')),
              isNot(contains('Status\$reflectionExtension')),
              contains('Foo\$reflection extends'),
              contains('Foo\$reflectionExtension'),
            ]),
            allOf([
              contains('final Expando<Foo\$reflection> _objectReflections'),
              contains('factory Foo\$reflection([Foo? object]) {'),
            ]),
            allOf([
              contains('Foo\$reflection()'),
              contains('// Dependency reflections:'),
              contains('Status\$reflection()'),
            ]),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection + generics + import [2 source files]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/status.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'status.reflection.g.dart';
          
          @EnableReflection()
          enum Status {a,b}
          
        ''',
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
          
          import './status.dart';
        
          part 'foo.reflection.g.dart';
          
          class Wrapper<T> {
            final T o;
            
            Wrapper(this.o);
          }
          
          @EnableReflection()
          class Foo {
            int n;
            Wrapper<Status> s;
            Foo(this.n, {this.status = Status.a});
          }
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/status.dart', '$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/status.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'status.dart'"),
            ),
            allOf([
              contains('Status\$reflection extends'),
              contains('Status\$reflectionExtension'),
              isNot(contains('Foo\$reflection extends')),
              isNot(contains('Foo\$reflectionExtension')),
            ]),
            allOf([
              contains('final Expando<Status\$reflection> _objectReflections'),
              contains('factory Status\$reflection([Status? object]) {'),
            ]),
          )),
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              isNot(contains('Status\$reflection extends')),
              isNot(contains('Status\$reflectionExtension')),
              contains('Foo\$reflection extends'),
              contains('Foo\$reflectionExtension'),
            ]),
            allOf([
              contains('final Expando<Foo\$reflection> _objectReflections'),
              contains('factory Foo\$reflection([Foo? object]) {'),
            ]),
            allOf([
              contains('Foo\$reflection()'),
              contains('// Dependency reflections:'),
              contains('Status\$reflection()'),
            ]),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection + import + static [2 source files]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/status.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'status.reflection.g.dart';
          
          @EnableReflection()
          enum Status {a,b}
          
        ''',
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
          
          import './status.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class Foo {
            static Status? s;
            
            int n;
            
            Foo(this.n);
          }
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/status.dart', '$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/status.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'status.dart'"),
            ),
            allOf([
              contains('Status\$reflection extends'),
              contains('Status\$reflectionExtension'),
              isNot(contains('Foo\$reflection extends')),
              isNot(contains('Foo\$reflectionExtension')),
            ]),
            allOf([
              contains('final Expando<Status\$reflection> _objectReflections'),
              contains('factory Status\$reflection([Status? object]) {'),
            ]),
          )),
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              isNot(contains('Status\$reflection extends')),
              isNot(contains('Status\$reflectionExtension')),
              contains('Foo\$reflection extends'),
              contains('Foo\$reflectionExtension'),
            ]),
            allOf([
              contains('final Expando<Foo\$reflection> _objectReflections'),
              contains('factory Foo\$reflection([Foo? object]) {'),
            ]),
            allOf([
              contains('Foo\$reflection()'),
              contains('// Dependency reflections:'),
              contains('Status\$reflection()'),
            ]),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection + import + type recursion [2 source files]',
        () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/status.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'status.reflection.g.dart';
          
          @EnableReflection()
          enum Status {a,b}
          
          @EnableReflection()
          class Wrapper1<T> {
            final T o ;
            final Wrapper2<T> w ;
            
            Wrapper1(this.o, this.w);
          }
          
          @EnableReflection()
          class Wrapper2<T> {
            final T o ;
            final Wrapper1<T> w ;
            
            Wrapper2(this.o,this.w);
          }
          
        ''',
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
          
          import './status.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          class Foo {
            int n;
            Status s;
            Wrapper1<T>? w ;
            
            Foo(this.n, {this.status = Status.a, this.w});
          }
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/status.dart', '$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/status.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'status.dart'"),
            ),
            allOf([
              contains('Status\$reflection extends'),
              contains('Status\$reflectionExtension'),
              isNot(contains('Foo\$reflection extends')),
              isNot(contains('Foo\$reflectionExtension')),
            ]),
            allOf([
              contains('final Expando<Status\$reflection> _objectReflections'),
              contains('factory Status\$reflection([Status? object]) {'),
            ]),
          )),
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf([
              isNot(contains('Status\$reflection extends')),
              isNot(contains('Status\$reflectionExtension')),
              contains('Foo\$reflection extends'),
              contains('Foo\$reflectionExtension'),
            ]),
            allOf([
              contains('final Expando<Foo\$reflection> _objectReflections'),
              contains('factory Foo\$reflection([Foo? object]) {'),
            ]),
            allOf([
              contains('Foo\$reflection()'),
              contains('// Dependency reflections:'),
              contains('Status\$reflection()'),
            ]),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('ReflectionBridge', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ReflectionBridge([User])
          class UserReflection {}
          
          class User {
            String? email ;
            String pass ;
            
            User(this.email, this.pass);
            
            bool get hasEmail => email != null;
            
            bool checkPassword(String pass) {
              return this.pass == pass;
            }
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
            contains("part of 'foo.dart'"),
            contains('User\$reflection'),
            contains('User\$reflectionExtension'),
            contains('UserReflection\$reflectionExtension'),
          ))
        },
        onLog: (msg) {
          print(msg);
        },
        //packageConfig: packageConfig,
      );
    });

    test('ReflectionBridge(reflectionBridgeExtensionName)', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ReflectionBridge(
            [User],
            bridgeExtensionName: 'BridgeExt',
            reflectionClassNames: {User: 'UserRef'},
            reflectionExtensionNames: {User: 'UserRefExt'},
          )
          class UserReflection {}
          
          class User {
            String? email ;
            String pass ;
            
            User(this.email, this.pass);
            
            bool get hasEmail => email != null;
            
            bool checkPassword(String pass) {
              return this.pass == pass;
            }
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
            contains("part of 'foo.dart'"),
            contains('UserRef'),
            contains('UserRefExt'),
            contains('BridgeExt'),
          ))
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    void testClassProxyLlibraryPath(bool sequential) async {
      var builder = reflectionFactory(BuilderOptions({
        'verbose': true,
        'sequential': sequential,
        'timeout': '45 sec',
      }));

      expect(builder.verbose, isTrue);
      expect(builder.sequential, equals(sequential));
      expect(builder.buildStepTimeout, equals(Duration(seconds: 45)));

      expect(
          builder.toString(),
          allOf(
            contains('verbose: true'),
            contains('sequential: $sequential'),
            contains('buildStepTimeout: 45 sec'),
          ));

      var sourceAssets = {
        '$_pkgName|lib/simple_api.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'reflection/simple_api.g.dart';
          
          @EnableReflection()
          class SimpleAPI {
            final String name;
            
            SimpleAPI(this.name);
            
            void nothing() {}
            
            @IgnoreClassProxyMethod()
            void ignore1() {}
            
            int compute() => 1;
            
            int computeSum(int a, int? b) => a + (b ?? 0) ;
            
            Future<int?>? computeMultiply(int a, int b) async => a * b ;
            
            FutureOr<int?>? computeDivide(int a, int b, Future future) => a / b ;
            
            int computeSum3(int a, {int? b, int? c}) => a + (b ?? 0) + (c ?? 0) ;
            
            R computeFunction<R>( R Function() callback ) => callback();
            
            Future<R> computeFunctionAsync<R>( FutureOr<R> Function() callback ) => callback(); 
            
            @override
            String toString() => 'SimpleAPI{ name: \$name }';
          }
        ''',
        '$_pkgName|lib/extra_api.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'reflection/extra_api.g.dart';
          
          @EnableReflection()
          class ExtraAPI {
            final String name;
            
            ExtraAPI(this.name);
            
            void nothing2() {}
          }
        ''',
        '$_pkgName|lib/nothing_api.dart': '''
        
          class NothingAPI {
            final String name;
            
            NothingAPI(this.name);
            
            void nothing2() {}
          }
        ''',
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ClassProxy('SimpleAPI', libraryPath: 'package:$_pkgName/simple_api.dart')
          class SimpleAPIProxy implements ClassProxyListener {
          }
        ''',
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {
          '$_pkgName|lib/simple_api.dart',
          '$_pkgName|lib/foo.dart',
          '$_pkgName|lib/extra_api.dart',
        },
        outputs: {
          '$_pkgName|lib/reflection/simple_api.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of '../simple_api.dart'"),
              contains('SimpleAPI\$reflection'),
            ),
          )),
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains('SimpleAPIProxy\$reflectionProxy'),
            ),
            allOf(
              contains('void nothing() {'),
              isNot(contains('void ignore1() {')),
              contains('int compute() {'),
              contains('int computeSum(int a, int? b) {'),
              contains('Future<int?>? computeMultiply(int a, int b) {'),
              contains(
                  'FutureOr<int?>? computeDivide(int a, int b, Future<dynamic> future) {'),
            ),
            allOf(
              contains('int computeSum3(int a, {int? b, int? c}) {'),
              contains(
                  'Future<R> computeFunctionAsync<R>(FutureOr<R> Function() callback) {'),
              matches(RegExp(
                  "onCall(\nthis,\n'computeSum3',\n<String, dynamic>{\n'a': a,\n'b': b,\n'c': c,\n},"
                      .replaceAll('\n', r'\s+')
                      .replaceAll('(', r'\(')
                      .replaceAll(')', r'\)'))),
            ),
          )),
          '$_pkgName|lib/reflection/extra_api.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of '../extra_api.dart'"),
              contains('ExtraAPI\$reflection'),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    }

    test('ClassProxy: SimpleAPI (through libraryPath) +sequential',
        () => testClassProxyLlibraryPath(true));

    test('ClassProxy: SimpleAPI (through libraryPath) -sequential',
        () => testClassProxyLlibraryPath(false));

    test('ClassProxy: SimpleAPI', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ClassProxy('SimpleAPI', ignoreParametersTypes: {Future})
          class SimpleAPIProxy implements ClassProxyListener {
          }
          
          @EnableReflection()
          class SimpleAPI {
            final String name;
            
            SimpleAPI(this.name);
            
            void nothing() {}
            
            int compute() => 1;
            
            int computeSum(int a, int? b) => a + (b ?? 0) ;
            
            Future<int?>? computeMultiply(int a, int b) async => a * b ;
            
            FutureOr<int?>? computeDivide(int a, int b, Future future) => a / b ;
            
            int computeSum3(int a, {int? b, int? c}) => a + (b ?? 0) + (c ?? 0) ;
            
            R computeFunction<R>( R Function() callback ) => callback();
            
            Future<R> computeFunctionAsync<R>( FutureOr<R> Function() callback ) => callback(); 
            
            @override
            String toString() => 'SimpleAPI{ name: \$name }';
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
              contains('SimpleAPIProxy\$reflectionProxy'),
            ),
            allOf(
              contains('void nothing() {'),
              contains('int compute() {'),
              contains('int computeSum(int a, int? b) {'),
              contains('Future<int?>? computeMultiply(int a, int b) {'),
              contains('FutureOr<int?>? computeDivide(int a, int b) {'),
            ),
            allOf(
              contains('int computeSum3(int a, {int? b, int? c}) {'),
              contains(
                  'Future<R> computeFunctionAsync<R>(FutureOr<R> Function() callback) {'),
              matches(RegExp(
                  "onCall(\nthis,\n'computeSum3',\n<String, dynamic>{\n'a': a,\n'b': b,\n'c': c,\n},"
                      .replaceAll('\n', r'\s+')
                      .replaceAll('(', r'\(')
                      .replaceAll(')', r'\)'))),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('ClassProxy: SimpleAPI (alwaysReturnFuture)', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ClassProxy('SimpleAPI', alwaysReturnFuture: true)
          class SimpleAPIProxy implements ClassProxyListener {
          }
          
          class SimpleAPI {
            final String name;
            
            SimpleAPI(this.name);
            
            void nothing() {}
            
            int compute() => 1;
            
            int computeSum(int a, int b) => a + b ;
            
            Future<int?>? computeMultiply(int a, int b) async => a * b ;
            
            FutureOr<int?> computeDivide(int a, int b) => a / b ;
            
            @override
            String toString() => 'SimpleAPI{ name: \$name }';
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf(
              contains('SimpleAPIProxy\$reflectionProxy'),
              contains('Future<void> nothing() {'),
              contains('Future<int> compute() {'),
              contains('Future<int> computeSum(int a, int b) {'),
              contains('Future<int?>? computeMultiply(int a, int b) {'),
              contains('Future<int?> computeDivide(int a, int b) {'),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('ClassProxy: SimpleAPI (traverseReturnTypes)', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ClassProxy('SimpleAPI', traverseReturnTypes: {Wrapper})
          class SimpleAPIProxy implements ClassProxyListener {
          }
          
          class SimpleAPI {
            final String name;
            
            SimpleAPI(this.name);
            
            void nothing() {}
            
            Wrapper<int> compute() => 1;
            
            int computeSum(int a, int b) => a + b ;
            
            Future<Wrapper<int>>? computeMultiply(int a, int b) async => a * b ;
            
            @override
            String toString() => 'SimpleAPI{ name: \$name }';
          }
          
          class Wrapper<T> {
            final T value ;
            Wrapper(this.value);
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf(
              contains('SimpleAPIProxy\$reflectionProxy'),
              contains('void nothing() {'),
              contains('int compute() {'),
              contains('int computeSum(int a, int b) {'),
              contains('Future<int> computeMultiply(int a, int b) {'),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('ClassProxy: SimpleAPI (alwaysReturnFuture+traverseReturnTypes)',
        () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ClassProxy('SimpleAPI', alwaysReturnFuture: true, traverseReturnTypes: {Wrapper})
          class SimpleAPIProxy implements ClassProxyListener {
          }
          
          class SimpleAPI {
            final String name;
            
            SimpleAPI(this.name);
            
            void nothing() {}
            
            Wrapper<int> compute() => 1;
            
            int computeSum(int a, int b) => a + b ;
            
            Future<Wrapper<int>>? computeMultiply(int a, int b) async => a * b ;
            
            @override
            String toString() => 'SimpleAPI{ name: \$name }';
          }
          
          class Wrapper<T> {
            final T value ;
            Wrapper(this.value);
          }
        
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf(
              contains('SimpleAPIProxy\$reflectionProxy'),
              contains('Future<void> nothing() {'),
              contains('Future<int> compute() {'),
              contains('Future<int> computeSum(int a, int b) {'),
              contains('Future<int> computeMultiply(int a, int b) {'),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test(
        'ClassProxy: MimeTypeResolverProxy (libraryPath: package:mime/mime.dart)',
        () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';

          @ClassProxy('MimeTypeResolver', libraryPath: 'package:mime/mime.dart')
          class MimeTypeResolverProxy implements ClassProxyListener {
          }
          
        '''
      };

      await testBuilder(
        builder,
        sourceAssets,
        reader: await PackageAssetReader.currentIsolate(),
        generateFor: {'$_pkgName|lib/foo.dart'},
        outputs: {
          '$_pkgName|lib/foo.reflection.g.dart': decodedMatches(allOf(
            allOf(
              contains('GENERATED CODE - DO NOT MODIFY BY HAND'),
              contains(
                  'BUILDER: reflection_factory/${ReflectionFactory.VERSION}'),
              contains("part of 'foo.dart'"),
            ),
            allOf(
              contains('MimeTypeResolverProxy\$reflectionProxy'),
              contains(
                  'String? lookup(String path, {List<int>? headerBytes}) {'),
              contains(
                  'void addExtension(String extension, String mimeType) {'),
            ),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });
  });
}

int _pkgCacheCount = 1;

// Ensure every test gets its own unique package name
String get _pkgName => 'pkg$_pkgCacheCount';
