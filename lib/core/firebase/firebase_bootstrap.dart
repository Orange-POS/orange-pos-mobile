import 'package:firebase_core/firebase_core.dart';

typedef FirebaseInitializeApp = Future<FirebaseApp> Function();

class FirebaseBootstrap {
  final FirebaseInitializeApp initializeApp;

  const FirebaseBootstrap({this.initializeApp = Firebase.initializeApp});

  Future<void> initialize() async {
    await initializeApp();
  }
}
