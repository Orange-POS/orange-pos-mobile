import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/app_dependencies.dart';

final appDependenciesProvider = Provider<AppDependencies>((ref) {
  return AppDependencies();
});
