import 'package:build_test/build_test.dart';
import 'package:reflection_factory/src/reflection_factory_builder.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    // Increment this after each test so the next test has it's own package
    _pkgCacheCount++;
  });

  group('ReflectionBuilder', () {
    setUp(() {});

    test('EnableReflection', () async {
      var builder = ReflectionBuilder(verbose: true);

      var sourceAssets = {
        '$_pkgName|lib/foo.dart': '''
        
          import 'package:reflection_factory/reflection_factory.dart';
        
          part 'foo.reflection.g.dart';
          
          @EnableReflection()
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
            contains('User\$reflection'),
            contains('User\$reflectionExtension'),
          ))
        },
        onLog: (msg) {
          print(msg);
        },
        //packageConfig: packageConfig,
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
        //packageConfig: packageConfig,
      );
    });
  });
}

int _pkgCacheCount = 1;

// Ensure every test gets its own unique package name
String get _pkgName => 'pkg$_pkgCacheCount';
