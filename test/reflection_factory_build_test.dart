@TestOn('vm')
import 'package:build_test/build_test.dart';
import 'package:reflection_factory/src/reflection_factory_base.dart';
import 'package:reflection_factory/src/reflection_factory_builder.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    // Increment this after each test so the next test has it's own package
    _pkgCacheCount++;
  });

  group('ReflectionBuilder', () {
    setUp(() {});

    test('EnableReflection: User', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          enum Axis {x, y, z}
          
          @EnableReflection()
          class User {
            @TestAnnotation(['static field', 'version'])
            static final double version = 1.0; 
            
            @TestAnnotation(['static method', 'version checker'])
            static bool isVersion(double ver, [double tolerance = 0.0]) => version == ver;
            
            @TestAnnotation(['field', 'email'])
            String? email ;
            String pass ;
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
            ),
            allOf(
              contains('User\$reflection'),
              contains('User\$reflectionExtension'),
            ),
            matches(RegExp(
                r"'ignoreCase':\s*ParameterReflection\(\s*TypeReflection.tBool\s*,\s*'ignoreCase'\s*,\s*false\s*,\s*false\s*,\s*false\s*,\s*null\s*\)")),
            allOf(
                contains(
                    "TestAnnotation(['static method', 'version checker'])"),
                contains("TestAnnotation(['method', 'password checker'])"),
                contains("TestAnnotation(['static field', 'version'])"),
                contains("TestAnnotation(['field', 'email'])"),
                contains("TestAnnotation(['parameter', 'pass'])"),
                isNot(contains('Object? toJson() => reflection.toJson()')),
                contains(
                    'Map<String, dynamic>? toJsonMap() => reflection.toJsonMap()')),
            allOf(
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
        
          part 'foo.reflection.g.dart';
          
          typedef Fx = bool Function(int x);
          
          @EnableReflection()
          class Domain {
            final String name;
            final String suffix;
          
            final Fx? fx;
            final bool Function()? extra;
          
            Domain(this.name, this.suffix, [this.fx, this.extra]);
          
            Domain.named({required this.name, this.suffix = 'net', Fx? fx, this.extra}) : fx = fx;
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
              contains('Domain\$reflection'),
              contains('Domain\$reflectionExtension'),
            ),
            matches(RegExp(
                r"'suffix':\s*ParameterReflection\(\s*TypeReflection.tString\s*,\s*'suffix'\s*,\s*false\s*,\s*false\s*,\s*'net'\s*,\s*null\s*\)")),
            allOf(
                contains('Object? toJson() => reflection.toJson()'),
                contains(
                    'Map<String, dynamic>? toJsonMap() => reflection.toJsonMap()')),
          )),
        },
        onLog: (msg) {
          print(msg);
        },
      );
    });

    test('EnableReflection[super class]', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
          abstract class Op {
            final String type;
            Op(this.type);
            
            List<Set<int>> opMethod() => <Set<int>>[{1},{2}] ;
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
                contains('Object? toJson() => reflection.toJson()'),
                contains(
                    'Map<String, dynamic>? toJsonMap() => reflection.toJsonMap()')),
            allOf(
              contains("case 'type':"),
              contains("case 'value':"),
              contains("fieldsNames => const <String>['type', 'value']"),
              contains("TypeReflection(List, [TypeReflection.tSetInt])"),
              contains("TypeReflection(Set, [TypeReflection.tListDynamic])"),
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
            contains('Object? toJson() => reflection.toJson()'),
            contains(
                'Map<String, dynamic>? toJsonMap() => reflection.toJsonMap()'),
          ))
        },
        onLog: (msg) {
          print(msg);
        },
        //packageConfig: packageConfig,
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

    test('ClassProxy: SimpleAPI', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @ClassProxy('SimpleAPI')
          class SimpleAPIProxy implements ClassProxyListener {
          }
          
          class SimpleAPI {
            final String name;
            
            SimpleAPI(this.name);
            
            int computeSum(int a, int b) => a + b ;
            
            Future<int> computeMultiply(int a, int b) async => a * b ;
            
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
              contains('SimpleAPI\$reflectionProxy'),
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
  });
}

int _pkgCacheCount = 1;

// Ensure every test gets its own unique package name
String get _pkgName => 'pkg$_pkgCacheCount';
