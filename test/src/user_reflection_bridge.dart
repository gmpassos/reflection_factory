import 'package:reflection_factory/reflection_factory.dart';

import 'user_simple.dart';

part 'user_reflection_bridge.reflection.g.dart';

@ReflectionBridge([TestUserSimple])
class TestUserReflectionBridge {}
