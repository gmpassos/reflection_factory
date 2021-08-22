import 'package:meta/meta_meta.dart';

/// Enables reflection for a class.
@Target({TargetKind.classType})
class EnableReflection {
  const EnableReflection();
}

/// Indicates that a class is a reflection bridge of [Type]s in [classesTypes] [List].
@Target({TargetKind.classType})
class ReflectionBridge {
  final List<Type> classesTypes;

  const ReflectionBridge(this.classesTypes);
}
