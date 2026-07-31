import 'package:flutter_app/core/di/app_dependencies.dart';
import 'package:flutter_app/core/providers/app_dependencies_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appDependenciesProvider', () {
    test('throws when it is not overridden', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(appDependenciesProvider),
        throwsA(
          predicate<Object>((error) {
            return error.toString().contains(
              'appDependenciesProvider must be overridden',
            );
          }, 'provider override error message'),
        ),
      );
    });

    test('uses the root ProviderScope override', () {
      final dependencies = AppDependencies();
      final container = ProviderContainer(
        overrides: [appDependenciesProvider.overrideWithValue(dependencies)],
      );
      addTearDown(container.dispose);

      expect(container.read(appDependenciesProvider), same(dependencies));
    });
  });
}
