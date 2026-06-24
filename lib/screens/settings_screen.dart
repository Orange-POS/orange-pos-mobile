import 'package:flutter/material.dart';

import '../demo/demo_mode.dart';
import '../theme/app_brand.dart';
import '../widgets/app_chrome.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool demoModeEnabled = DemoMode.enabled;

  void updateDemoMode(bool value) {
    setState(() {
      demoModeEnabled = value;
    });

    if (value) {
      DemoMode.enable();
    } else {
      DemoMode.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppBrand.white,
      body: SafeArea(
        child: Padding(
          padding: AppChrome.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader.brand(
                onProfilePressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 31),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppBrand.textDarkGrey,
                ),
              ),
              const SizedBox(height: 72),
              if (DemoMode.available)
                Row(
                  children: [
                    const Text(
                      'Demo Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppBrand.textDarkGrey,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: demoModeEnabled,
                      activeThumbColor: AppBrand.white,
                      activeTrackColor: AppBrand.primary,
                      inactiveThumbColor: AppBrand.white,
                      inactiveTrackColor: Colors.black26,
                      onChanged: updateDemoMode,
                    ),
                  ],
                ),
              if (DemoMode.available && demoModeEnabled) ...[
                const SizedBox(height: 20),
                if (DemoMode.available && demoModeEnabled) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppBrand.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppBrand.primary),
                    ),

                    child: const Text(
                      'Demo Mode is enabled. The app will use sample products and will not connect to Odoo. Use this mode for Apple review testing without a POS server.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppBrand.textDarkGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                const AppFooter(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
