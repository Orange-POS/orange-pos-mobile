import 'package:flutter_app/core/config/app_config.dart';
import 'package:flutter_app/core/providers/app_dependencies_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('appDependenciesProvider', () {
    test('provides app dependencies with production config by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dependencies = container.read(appDependenciesProvider);

      expect(dependencies.config.environment, AppEnvironment.production);
      expect(dependencies.config.appName, 'OrangeONE');
    });
  });
}
