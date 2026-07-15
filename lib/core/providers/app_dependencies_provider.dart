import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/app_dependencies.dart';

final appDependenciesProvider = Provider<AppDependencies>((ref) {
  throw StateError(
    'appDependenciesProvider must be overridden by the root ProviderScope.',
  );
});
