import 'feature_flags.dart';

abstract class FeatureFlagProvider {
  Future<FeatureFlags> loadFlags();
}

class LocalFeatureFlagProvider implements FeatureFlagProvider {
  final FeatureFlags flags;

  const LocalFeatureFlagProvider({
    this.flags = const FeatureFlags.production(),
  });

  @override
  Future<FeatureFlags> loadFlags() async {
    return flags;
  }
}
