import 'package:reflection_factory/reflection_factory.dart';

import 'user_simple.dart';

part 'user_reflection_bridge.reflection.g.dart';

@ReflectionBridge([TestUserSimple])
class TestUserReflectionBridge {}

@ClassProxy('TestUserSimple')
class TestUserSimpleProxy implements ClassProxyListener {
  final List<String> calls = <String>[];

  @override
  Object? onCall(instance, String methodName, Map<String, dynamic> parameters) {
    var call = '$instance -> $methodName( $parameters )';
    calls.add(call);
    print('CALL>> $call');
    return parameters.isNotEmpty;
  }

  @override
  String toString() {
    return 'TestUserSimpleProxy{calls: ${calls.length}}';
  }
}
