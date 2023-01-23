/// Library for [reflection_factory]'s builder.
library reflection_factory.builder;

import 'package:build/build.dart';
import 'package:reflection_factory/reflection_factory.dart';

import 'src/reflection_factory_builder.dart';

export 'src/reflection_factory_base.dart';

Builder reflectionFactory([BuilderOptions options = BuilderOptions.empty]) {
  var verbose = options.getAsBool(['verbose']);
  var sequential = options.getAsBool(['sequential', 'serial'], true);
  var buildStepTimeout = options.getAsDuration(
      ['buildStepTimeout', 'build_step_timeout', 'timeout'],
      Duration(seconds: 30));

  var reflectionFactory = ReflectionBuilder(
      verbose: verbose,
      sequencial: sequential,
      buildStepTimeout: buildStepTimeout);

  log.info('Builder:\n\n${reflectionFactory.toString(indent: '  ')}');

  return reflectionFactory;
}

extension _BuilderOptionsExtension on BuilderOptions {
  Object? _get(String key) {
    var v = config[key];
    if (v != null) return v;

    key = key.toLowerCase().trim();

    for (var k in config.keys) {
      if (k.toLowerCase().trim() == key) {
        return config[k];
      }
    }

    return null;
  }

  String getAny(List<String> keys, [String def = '']) {
    for (var k in keys) {
      var v = _get(k);
      if (v != null) {
        return v.toString().toLowerCase().trim();
      }
    }
    return def;
  }

  bool getAsBool(List<String> keys, [bool def = false]) {
    var v = getAny(keys, '$def');
    return v != '' &&
        v != '0' &&
        v != 'f' &&
        v != 'n' &&
        v != 'false' &&
        v != 'null';
  }

  Duration getAsDuration(List<String> keys,
      [Duration def = const Duration(seconds: 30)]) {
    var v = getAny(keys, '$def');
    return tryParseDuration(v, def)!;
  }
}
