import 'package:flutter/material.dart';

import '../widgets/app_page.dart';
import 'qr_login_scanner_screen.dart';
import 'scanner_screen.dart';
import '../models/qr_login_data.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  QrLoginData? lastQrData;
  final AuthService authService = AuthService();
  final TokenStorage tokenStorage = TokenStorage.instance;
  bool isLoggingIn = false;
  String? authToken;
  String? errorMessage;

  Future<void> openScanner() async {
  final qrData = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const QrLoginScannerScreen(),
    ),
  );

  if (!mounted || qrData == null) {
    return;
  }

  late QrLoginData loginData;

  try {
  loginData = QrLoginData.fromRaw(qrData.toString());
} catch (error) {
  debugPrint('QR parse error: $error');

  setState(() {
    errorMessage = 'Invalid QR code. Please scan the QR code from Odoo POS.';
  });
  return;
}

  if (loginData.isExpired) {
    setState(() {
      errorMessage =
          'This QR code has expired. Please generate a new one from POS.';
    });
    return;
  }

  setState(() {
    lastQrData = loginData;
    isLoggingIn = true;
    errorMessage = null;
  });

  

  try {
    final token = await authService.loginWithQr(loginData);
    await tokenStorage.saveToken(token);
    await tokenStorage.saveBackendUrl(loginData.backendUrl);

    if (!mounted) {
      return;
    }

    setState(() {
      authToken = token;
      isLoggingIn = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          authToken: token,
          backendUrl: loginData.backendUrl,
        ),
      ),
    );
  } catch (error) {
    if (!mounted) {
      return;
    }

    setState(() {
      isLoggingIn = false;
      errorMessage = 'Login failed. Please try again.';
    });

    debugPrint('Login failed: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inventory Tracker',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: openScanner,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                size: 80,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan for Login',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
         Text(isLoggingIn ? 'Logging in with QR...' : 'Tap scanner box for now',
        style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                ),
              ),
          ],

          if (lastQrData != null) ...[
            const SizedBox(height: 24),
            const Text('Last scanned QR:',
            style: TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 8),
            Text(lastQrData!.rawValue, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),),
            ],
          
        ],
      ),
    );
  }
}