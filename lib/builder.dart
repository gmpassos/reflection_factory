/// Library for [reflection_factory]'s builder.
library reflection_factory.builder;

import 'package:build/build.dart';

import 'src/reflection_factory_builder.dart';

export 'src/reflection_factory_base.dart';

Builder reflectionFactory([BuilderOptions options = BuilderOptions.empty]) {
  var reflectionFactory = ReflectionBuilder();
  return reflectionFactory;
}
