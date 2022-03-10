import 'package:reflection_factory/reflection_factory.dart';

import 'user_simple.dart';

part 'user_reflection_bridge.reflection.g.dart';

@ReflectionBridge([TestUserSimple])
class TestUserReflectionBridge {}

@ClassProxy('TestUserSimple')
class TestUserSimpleProxy implements ClassProxyListener {
  final List<String> calls = <String>[];

  @override
  Object? onCall(instance, String methodName, Map<String, dynamic> parameters,
      TypeReflection? returnType) {
    var call = '$instance -> $methodName( $parameters ) -> $returnType';
    calls.add(call);
    print('CALL>> $call');
    return parameters.isNotEmpty;
  }

  @override
  String toString() {
    return 'TestUserSimpleProxy{calls: ${calls.length}}';
  }
}

@ClassProxy('TestUserSimple', alwaysReturnFuture: true)
class TestUserSimpleProxyAsync implements ClassProxyListener {
  final List<String> calls = <String>[];

  @override
  Object? onCall(instance, String methodName, Map<String, dynamic> parameters,
      TypeReflection? returnType) {
    var call = '$instance -> $methodName( $parameters ) -> $returnType';
    calls.add(call);
    print('CALL>> $call');
    return parameters.isNotEmpty;
  }

  @override
  String toString() {
    return 'TestUserSimpleProxyAsync{calls: ${calls.length}}';
  }
}
